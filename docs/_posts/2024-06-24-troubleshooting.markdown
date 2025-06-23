---
layout: post
title: "Troubleshooting RichTextExtraction"
date: 2025-06-24
categories: [tutorials, troubleshooting, debugging]
tags: [troubleshooting, debugging, common-issues, error-handling]
author: RichTextExtraction Team
---

# Troubleshooting RichTextExtraction

This guide helps you resolve common issues and debug problems with RichTextExtraction. From installation problems to performance issues, we've got you covered.

## Common Installation Issues

### Gem Installation Problems

**Problem**: `gem install rich_text_extraction` fails

**Solutions**:
```bash
# Update RubyGems
gem update --system

# Install with specific Ruby version
rbenv exec gem install rich_text_extraction

# Install with bundler
bundle add rich_text_extraction
```

**Problem**: Dependency conflicts

**Solutions**:
```bash
# Check for conflicts
bundle check

# Update dependencies
bundle update

# Install with specific version
gem 'rich_text_extraction', '~> 0.1.0'
```

### Rails Integration Issues

**Problem**: ActionText not working

**Solutions**:
```ruby
# Ensure ActionText is installed
rails action_text:install

# Check if ActionText is properly configured
# config/application.rb
require "action_text/engine"
```

**Problem**: View helpers not available

**Solutions**:
```ruby
# Ensure the gem is properly required
require 'rich_text_extraction'

# Check if helpers are included
# app/helpers/application_helper.rb
include RichTextExtraction::Helpers
```

## OpenGraph Extraction Issues

### Network and Timeout Problems

**Problem**: OpenGraph extraction times out

**Solutions**:
```ruby
# Increase timeout
RichTextExtraction.configure do |config|
  config.opengraph_timeout = 15.seconds
end

# Or per-request
metadata = og_service.extract('https://example.com', timeout: 15.seconds)
```

**Problem**: SSL certificate errors

**Solutions**:
```ruby
# Configure SSL verification
RichTextExtraction.configure do |config|
  config.opengraph_ssl_verify = false  # Use with caution
end
```

**Problem**: Rate limiting

**Solutions**:
```ruby
# Add delays between requests
def extract_with_delay(urls)
  urls.each_with_index do |url, index|
    metadata = og_service.extract(url)
    sleep(1) if index < urls.length - 1  # 1 second delay
  end
end
```

### Missing or Incorrect OpenGraph Data

**Problem**: No OpenGraph data returned

**Debugging**:
```ruby
# Enable debug mode
RichTextExtraction.configure do |config|
  config.debug = true
end

# Check raw HTML response
og_service = RichTextExtraction::OpenGraphService.new
html = og_service.send(:fetch_html, 'https://example.com')
puts html
```

**Problem**: Incorrect metadata

**Solutions**:
```ruby
# Verify the URL is accessible
require 'net/http'
response = Net::HTTP.get_response(URI('https://example.com'))
puts response.code  # Should be 200

# Check if the site has OpenGraph tags
html = og_service.send(:fetch_html, 'https://example.com')
puts html.scan(/<meta property="og:.*?>/)
```

## Caching Issues

### Cache Not Working

**Problem**: OpenGraph data not being cached

**Debugging**:
```ruby
# Check cache configuration
puts RichTextExtraction.configuration.cache_enabled
puts RichTextExtraction.configuration.cache_ttl

# Test cache manually
cache_key = "rte:opengraph:#{Digest::MD5.hexdigest('https://example.com')}"
Rails.cache.write(cache_key, 'test', expires_in: 1.hour)
puts Rails.cache.read(cache_key)  # Should return 'test'
```

**Problem**: Cache keys not matching

**Solutions**:
```ruby
# Use consistent cache options
metadata = og_service.extract('https://example.com',
  cache: :rails,
  cache_options: { key_prefix: 'myapp' }
)

# Clear specific cache
og_service.clear_cache('https://example.com', cache: :rails)
```

### Cache Performance Issues

**Problem**: Slow cache operations

**Solutions**:
```ruby
# Use Redis for better performance
RichTextExtraction.configure do |config|
  config.cache_backend = :redis
  config.redis_url = ENV['REDIS_URL']
end

# Optimize cache TTL
RichTextExtraction.configure do |config|
  config.cache_ttl = 24.hours  # Longer TTL for better performance
end
```

## Markdown Rendering Issues

### HTML Sanitization Problems

**Problem**: Content not rendering properly

**Debugging**:
```ruby
# Check if sanitization is too strict
service = RichTextExtraction::MarkdownService.new(sanitize_html: false)
html = service.render('**Bold** <span>content</span>')
puts html
```

**Problem**: Links not working

**Solutions**:
```ruby
# Check link attributes
service = RichTextExtraction::MarkdownService.new(
  renderer_options: { link_attributes: { target: '_blank' } }
)
html = service.render('[Link](https://example.com)')
puts html
```

### Renderer Compatibility

**Problem**: Markdown renderer not available

**Solutions**:
```ruby
# Install required gems
gem 'redcarpet'
gem 'kramdown'
gem 'commonmarker'

# Or use fallback renderer
service = RichTextExtraction::MarkdownService.new(
  renderer_options: { fallback: true }
)
```

## Performance Issues

### Slow Extraction

**Problem**: OpenGraph extraction is slow

**Solutions**:
```ruby
# Use background jobs
class ExtractLinksJob < ApplicationJob
  def perform(post_id)
    post = Post.find(post_id)
    post.body.link_objects(with_opengraph: true)
  end
end

# Batch processing
urls = ['https://example1.com', 'https://example2.com']
results = urls.map { |url| og_service.extract(url, cache: :rails) }
```

**Problem**: Memory usage is high

**Solutions**:
```ruby
# Process in batches
posts.find_in_batches(batch_size: 50) do |batch|
  batch.each do |post|
    post.body.extract_links
  end
  GC.start  # Force garbage collection
end
```

### Database Performance

**Problem**: Database queries are slow

**Solutions**:
```ruby
# Add database indexes
add_index :posts, :updated_at
add_index :posts, :opengraph_metadata

# Use counter cache
add_column :posts, :links_count, :integer, default: 0
```

## Error Handling

### Common Error Messages

**Error**: `RichTextExtraction::Error: Failed to extract OpenGraph data`

**Solutions**:
```ruby
# Add error handling
begin
  metadata = og_service.extract('https://example.com')
rescue RichTextExtraction::Error => e
  Rails.logger.error "OpenGraph extraction failed: #{e.message}"
  metadata = { title: 'Link Preview Unavailable' }
end
```

**Error**: `Net::TimeoutError`

**Solutions**:
```ruby
# Increase timeout
metadata = og_service.extract('https://example.com', timeout: 30.seconds)

# Use background job for slow sites
ExtractLinksJob.perform_later(post.id)
```

**Error**: `ActionView::Template::Error: undefined method 'extract_links'`

**Solutions**:
```ruby
# Ensure the concern is included
class Post < ApplicationRecord
  include RichTextExtraction::ExtractsRichText
  has_rich_text :body
end

# Check if ActionText is properly set up
rails action_text:install:migrations
rails db:migrate
```

## Debugging Tools

### Debug Mode

```ruby
# Enable debug logging
RichTextExtraction.configure do |config|
  config.debug = true
end

# Check logs for detailed information
tail -f log/development.log
```

### Health Checks

```ruby
# Create a health check endpoint
class HealthController < ApplicationController
  def opengraph
    og_service = RichTextExtraction::OpenGraphService.new
    
    begin
      metadata = og_service.extract('https://httpbin.org/html')
      render json: { status: 'healthy', metadata: metadata }
    rescue => e
      render json: { status: 'unhealthy', error: e.message }, status: 500
    end
  end
end
```

### Performance Monitoring

```ruby
# Add performance monitoring
ActiveSupport::Notifications.subscribe 'opengraph.extract' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  
  if event.duration > 5000  # 5 seconds
    Rails.logger.warn "Slow OpenGraph extraction: #{event.payload[:url]} took #{event.duration}ms"
  end
end
```

## Testing Issues

### Test Failures

**Problem**: Tests failing due to network dependencies

**Solutions**:
```ruby
# Mock external requests in tests
RSpec.describe RichTextExtraction::OpenGraphService do
  before do
    allow(Net::HTTP).to receive(:get_response).and_return(
      double('response', body: '<html><title>Test</title></html>')
    )
  end
  
  it 'extracts OpenGraph data' do
    service = described_class.new
    metadata = service.extract('https://example.com')
    expect(metadata[:title]).to eq('Test')
  end
end
```

**Problem**: Cache interfering with tests

**Solutions**:
```ruby
# Clear cache in test setup
RSpec.configure do |config|
  config.before(:each) do
    Rails.cache.clear
  end
end
```

## Getting Help

### Logs and Debugging

```ruby
# Enable verbose logging
Rails.logger.level = Logger::DEBUG

# Add custom logging
Rails.logger.info "Extracting links from post #{post.id}"
Rails.logger.error "Failed to extract: #{e.message}" if e
```

### Community Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/ceccec/rich_text_extraction/issues)
- **GitHub Discussions**: [Ask questions and share solutions](https://github.com/ceccec/rich_text_extraction/discussions)
- **Documentation**: [Complete API reference](https://ceccec.github.io/rich_text_extraction/)

### Creating Bug Reports

When reporting issues, include:

1. **Ruby version**: `ruby -v`
2. **Rails version**: `rails -v`
3. **Gem version**: `bundle list | grep rich_text_extraction`
4. **Error message**: Complete error stack trace
5. **Reproduction steps**: How to reproduce the issue
6. **Expected behavior**: What you expected to happen
7. **Actual behavior**: What actually happened

## Next Steps

- Learn about [Advanced Usage]({{ site.baseurl }}/blog/2025-06-24-advanced-usage.html) for more customization
- Explore [ActionText Integration]({{ site.baseurl }}/blog/2025-06-24-actiontext-integration.html)
- Check the [API Reference]({{ site.baseurl }}/api-reference/) for complete documentation

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀 