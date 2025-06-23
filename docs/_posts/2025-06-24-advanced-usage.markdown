---
layout: post
title: "Advanced Usage of RichTextExtraction"
date: 2025-06-24
categories: [tutorials, advanced, customization]
tags: [advanced-usage, customization, performance, caching, background-jobs]
author: RichTextExtraction Team
---

# Advanced Usage of RichTextExtraction

RichTextExtraction offers extensive customization and advanced features for power users. This guide covers advanced configuration, performance optimization, and custom implementations.

## Advanced Configuration

### Comprehensive Configuration

```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  # Caching configuration
  config.cache_enabled = true
  config.cache_prefix = 'rte'
  config.cache_ttl = 1.hour
  
  # OpenGraph configuration
  config.opengraph_timeout = 5.seconds
  config.opengraph_user_agent = 'RichTextExtraction/1.0'
  config.opengraph_max_redirects = 3
  
  # Markdown configuration
  config.markdown_renderer = :redcarpet
  config.markdown_options = {
    hard_wrap: true,
    link_attributes: { target: '_blank', rel: 'noopener noreferrer' },
    autolink: true,
    tables: true,
    fenced_code_blocks: true
  }
  
  # Debug mode
  config.debug = false
end
```

### Environment-Specific Configuration

```ruby
# config/environments/production.rb
RichTextExtraction.configure do |config|
  config.cache_ttl = 24.hours
  config.opengraph_timeout = 10.seconds
end

# config/environments/development.rb
RichTextExtraction.configure do |config|
  config.cache_ttl = 5.minutes
  config.debug = true
end
```

## Custom Extractors

### Creating Custom Extractors

```ruby
# lib/extractors/custom_extractor.rb
module RichTextExtraction
  module CustomExtractor
    def extract_custom_patterns(text)
      # Extract custom patterns from text
      text.scan(/\[\[([^\]]+)\]\]/).flatten
    end
    
    def extract_emails(text)
      # Extract email addresses
      text.scan(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/)
    end
    
    def extract_phone_numbers(text)
      # Extract phone numbers
      text.scan(/\b\d{3}[-.]?\d{3}[-.]?\d{4}\b/)
    end
  end
end

# Include in your extractor
class RichTextExtraction::Extractor
  include RichTextExtraction::CustomExtractor
end
```

### Using Custom Extractors

```ruby
extractor = RichTextExtraction::Extractor.new("Contact [[John]] at john@example.com or call 555-123-4567")

extractor.extract_custom_patterns  # => ["John"]
extractor.extract_emails           # => ["john@example.com"]
extractor.extract_phone_numbers    # => ["555-123-4567"]
```

## Advanced Caching Strategies

### Custom Cache Backends

```ruby
# Custom Redis cache implementation
class RedisCache
  def initialize(redis_client)
    @redis = redis_client
  end
  
  def read(key)
    @redis.get(key)
  end
  
  def write(key, value, options = {})
    ttl = options[:expires_in] || 3600
    @redis.setex(key, ttl, value)
  end
  
  def delete(key)
    @redis.del(key)
  end
end

# Use custom cache
redis_cache = RedisCache.new(Redis.new)
og_service = RichTextExtraction::OpenGraphService.new
metadata = og_service.extract('https://example.com', cache: redis_cache)
```

### Cache Key Strategies

```ruby
# Custom cache key generation
class CustomCacheKey
  def self.generate(url, options = {})
    digest = Digest::MD5.hexdigest(url)
    prefix = options[:prefix] || 'rte'
    version = options[:version] || 'v1'
    
    "#{prefix}:#{version}:#{digest}"
  end
end

# Use custom cache keys
metadata = og_service.extract('https://example.com',
  cache: :rails,
  cache_options: {
    key_generator: CustomCacheKey.method(:generate),
    prefix: 'myapp',
    version: 'v2'
  }
)
```

## Performance Optimization

### Batch Processing

```ruby
# Process multiple URLs efficiently
class BatchOpenGraphProcessor
  def initialize
    @og_service = RichTextExtraction::OpenGraphService.new
  end
  
  def process_urls(urls, options = {})
    urls.map do |url|
      begin
        @og_service.extract(url, options)
      rescue RichTextExtraction::Error => e
        Rails.logger.error "Failed to extract #{url}: #{e.message}"
        nil
      end
    end.compact
  end
  
  def process_in_parallel(urls, options = {})
    urls.map do |url|
      Thread.new do
        begin
          @og_service.extract(url, options)
        rescue RichTextExtraction::Error => e
          Rails.logger.error "Failed to extract #{url}: #{e.message}"
          nil
        end
      end
    end.map(&:value).compact
  end
end

# Usage
processor = BatchOpenGraphProcessor.new
urls = ['https://example1.com', 'https://example2.com', 'https://example3.com']
results = processor.process_urls(urls, cache: :rails)
```

### Memory Optimization

```ruby
# Stream processing for large datasets
class StreamProcessor
  def process_large_dataset(posts, batch_size: 100)
    posts.find_in_batches(batch_size: batch_size) do |batch|
      batch.each do |post|
        process_post(post)
        GC.start if batch.index(post) % 50 == 0
      end
    end
  end
  
  private
  
  def process_post(post)
    links = post.body.extract_links
    links.each do |url|
      metadata = RichTextExtraction::OpenGraphService.new.extract(url, cache: :rails)
      # Process metadata
    end
  end
end
```

## Advanced Background Jobs

### Sophisticated Job Implementation

```ruby
# app/jobs/advanced_opengraph_job.rb
class AdvancedOpenGraphJob < ApplicationJob
  queue_as :opengraph
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  def perform(post_id, options = {})
    post = Post.find(post_id)
    og_service = RichTextExtraction::OpenGraphService.new
    
    # Extract links with custom options
    links = post.body.extract_links
    metadata_batch = process_links(links, og_service, options)
    
    # Store results
    post.update(
      opengraph_metadata: metadata_batch,
      processed_at: Time.current
    )
    
    # Trigger follow-up jobs if needed
    trigger_follow_up_jobs(post, metadata_batch)
  end
  
  private
  
  def process_links(links, og_service, options)
    links.map do |url|
      begin
        og_service.extract(url, options.merge(cache: :rails))
      rescue RichTextExtraction::Error => e
        Rails.logger.error "Failed to extract #{url}: #{e.message}"
        { url: url, error: e.message }
      end
    end
  end
  
  def trigger_follow_up_jobs(post, metadata_batch)
    # Trigger image processing jobs
    metadata_batch.each do |metadata|
      next unless metadata[:image]
      ProcessImageJob.perform_later(metadata[:image], post.id)
    end
    
    # Trigger notification jobs
    NotifyOpengraphCompleteJob.perform_later(post.id)
  end
end
```

### Job Scheduling and Monitoring

```ruby
# app/jobs/scheduled_opengraph_job.rb
class ScheduledOpenGraphJob < ApplicationJob
  queue_as :scheduled
  
  def perform
    # Process posts that haven't been updated recently
    posts = Post.where('updated_at < ?', 1.day.ago)
                .where(opengraph_metadata: nil)
                .limit(100)
    
    posts.each do |post|
      AdvancedOpenGraphJob.perform_later(post.id)
    end
  end
end

# Schedule with cron or whenever gem
# config/schedule.rb
every 1.hour do
  runner "ScheduledOpenGraphJob.perform_later"
end
```

## Custom View Helpers

### Advanced View Helpers

```ruby
# app/helpers/advanced_opengraph_helper.rb
module AdvancedOpengraphHelper
  def render_enhanced_preview(content, options = {})
    return unless content.present?
    
    links = content.link_objects(with_opengraph: true, cache: :rails)
    return if links.empty?
    
    render partial: 'shared/enhanced_preview',
           locals: { links: links, options: options }
  end
  
  def render_preview_grid(content, columns: 2)
    links = content.link_objects(with_opengraph: true, cache: :rails)
    return if links.empty?
    
    render partial: 'shared/preview_grid',
           locals: { links: links, columns: columns }
  end
  
  def render_preview_carousel(content)
    links = content.link_objects(with_opengraph: true, cache: :rails)
    return if links.empty?
    
    render partial: 'shared/preview_carousel',
           locals: { links: links }
  end
end
```

### Custom Preview Templates

```erb
<!-- app/views/shared/_enhanced_preview.html.erb -->
<div class="enhanced-preview">
  <% links.each do |link| %>
    <div class="preview-item" data-url="<%= link[:url] %>">
      <% if link[:opengraph][:image].present? %>
        <div class="preview-image">
          <%= image_tag link[:opengraph][:image], 
                        alt: link[:opengraph][:title],
                        loading: 'lazy',
                        class: 'preview-img' %>
        </div>
      <% end %>
      
      <div class="preview-content">
        <h4 class="preview-title">
          <%= link_to link[:opengraph][:title], 
                      link[:url], 
                      target: '_blank',
                      rel: 'noopener noreferrer' %>
        </h4>
        
        <% if link[:opengraph][:description].present? %>
          <p class="preview-description">
            <%= truncate(link[:opengraph][:description], length: 150) %>
          </p>
        <% end %>
        
        <div class="preview-meta">
          <span class="preview-domain"><%= URI.parse(link[:url]).host %></span>
          <span class="preview-timestamp"><%= time_ago_in_words(link[:cached_at]) %> ago</span>
        </div>
      </div>
    </div>
  <% end %>
</div>
```

## Error Handling and Monitoring

### Comprehensive Error Handling

```ruby
# app/services/opengraph_monitor.rb
class OpengraphMonitor
  def self.track_extraction(url, metadata, error = nil)
    if error
      Rails.logger.error "OpenGraph extraction failed for #{url}: #{error.message}"
      increment_failure_count(url)
      notify_team(url, error) if should_notify?(url)
    else
      Rails.logger.info "OpenGraph extraction successful for #{url}"
      increment_success_count(url)
    end
  end
  
  private
  
  def self.increment_failure_count(url)
    Rails.cache.increment("opengraph_failures:#{Digest::MD5.hexdigest(url)}", 1, expires_in: 1.hour)
  end
  
  def self.increment_success_count(url)
    Rails.cache.increment("opengraph_successes:#{Digest::MD5.hexdigest(url)}", 1, expires_in: 1.hour)
  end
  
  def self.should_notify?(url)
    failures = Rails.cache.read("opengraph_failures:#{Digest::MD5.hexdigest(url)}") || 0
    failures >= 3
  end
  
  def self.notify_team(url, error)
    # Send notification to team (Slack, email, etc.)
    NotificationService.notify(
      channel: '#alerts',
      message: "OpenGraph extraction failing for #{url}: #{error.message}"
    )
  end
end
```

### Health Checks

```ruby
# app/services/opengraph_health_check.rb
class OpengraphHealthCheck
  def self.run
    {
      cache_status: check_cache_status,
      service_status: check_service_status,
      performance_metrics: collect_performance_metrics
    }
  end
  
  private
  
  def self.check_cache_status
    test_url = 'https://example.com'
    cache_key = "rte:opengraph:#{Digest::MD5.hexdigest(test_url)}"
    
    Rails.cache.write(cache_key, 'test', expires_in: 1.minute)
    result = Rails.cache.read(cache_key)
    
    { working: result == 'test', key: cache_key }
  end
  
  def self.check_service_status
    begin
      og_service = RichTextExtraction::OpenGraphService.new
      metadata = og_service.extract('https://httpbin.org/html', timeout: 5.seconds)
      { working: true, response_time: metadata[:response_time] }
    rescue => e
      { working: false, error: e.message }
    end
  end
  
  def self.collect_performance_metrics
    {
      cache_hit_rate: calculate_cache_hit_rate,
      average_response_time: calculate_average_response_time,
      error_rate: calculate_error_rate
    }
  end
end
```

## Testing Advanced Features

### Comprehensive Test Suite

```ruby
# spec/services/advanced_opengraph_spec.rb
RSpec.describe 'Advanced OpenGraph Features' do
  let(:og_service) { RichTextExtraction::OpenGraphService.new }
  let(:test_url) { 'https://httpbin.org/html' }
  
  describe 'custom cache backends' do
    it 'works with custom cache implementation' do
      custom_cache = double('CustomCache')
      allow(custom_cache).to receive(:read).and_return(nil)
      allow(custom_cache).to receive(:write)
      
      metadata = og_service.extract(test_url, cache: custom_cache)
      
      expect(custom_cache).to have_received(:write)
      expect(metadata[:title]).to be_present
    end
  end
  
  describe 'batch processing' do
    it 'processes multiple URLs efficiently' do
      urls = [test_url, 'https://httpbin.org/json']
      processor = BatchOpenGraphProcessor.new
      
      results = processor.process_urls(urls, cache: :rails)
      
      expect(results.length).to eq(2)
      expect(results.first[:title]).to be_present
    end
  end
  
  describe 'error handling' do
    it 'handles network errors gracefully' do
      allow(Net::HTTP).to receive(:get_response).and_raise(Net::TimeoutError)
      
      metadata = og_service.extract('https://invalid-url.com')
      
      expect(metadata[:error]).to be_present
    end
  end
end
```

## Deployment Considerations

### Production Configuration

```ruby
# config/environments/production.rb
RichTextExtraction.configure do |config|
  # Optimize for production
  config.cache_ttl = 24.hours
  config.opengraph_timeout = 10.seconds
  config.opengraph_max_redirects = 5
  config.debug = false
  
  # Use Redis for caching
  config.cache_backend = :redis
  config.redis_url = ENV['REDIS_URL']
end
```

### Monitoring and Alerting

```ruby
# config/initializers/opengraph_monitoring.rb
if Rails.env.production?
  ActiveSupport::Notifications.subscribe 'opengraph.extract' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    
    if event.duration > 5000 # 5 seconds
      Rails.logger.warn "Slow OpenGraph extraction: #{event.payload[:url]} took #{event.duration}ms"
    end
    
    if event.payload[:error]
      Rails.logger.error "OpenGraph extraction failed: #{event.payload[:error]}"
    end
  end
end
```

## Next Steps

- Check out [Troubleshooting]({{ site.baseurl }}/_posts/2025-06-24-troubleshooting.html) for common issues
- Explore the [API Reference]({{ site.baseurl }}/api-reference/) for complete documentation
- Visit the [GitHub Repository](https://github.com/ceccec/rich_text_extraction) for source code

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀 