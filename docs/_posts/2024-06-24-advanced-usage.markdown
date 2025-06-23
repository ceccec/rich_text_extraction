---
layout: post
title: "Advanced Usage & Customization"
date: 2024-06-24
categories: guides
---

# Advanced Usage & Customization

RichTextExtraction provides extensive customization options through its modular architecture. This guide covers advanced usage patterns, custom configurations, and extending the gem's functionality.

## 🏗️ Modular Architecture Overview

RichTextExtraction is built with a modern modular architecture that separates concerns and provides clear interfaces:

```
lib/rich_text_extraction/
├── services/                    # Service classes
│   ├── opengraph_service.rb    # OpenGraph operations
│   └── markdown_service.rb     # Markdown rendering
├── extractors/                  # Focused extractors
│   ├── link_extractor.rb       # Link extraction
│   └── social_extractor.rb     # Social content
├── configuration.rb            # Configuration system
└── ... (other modules)
```

## 🔧 Service Classes

### OpenGraphService

The `OpenGraphService` handles all OpenGraph operations with advanced caching and error handling:

```ruby
# Basic usage
og_service = RichTextExtraction::OpenGraphService.new
og_data = og_service.extract('https://example.com', cache: :rails)

# Custom cache options
og_data = og_service.extract('https://example.com', 
  cache: custom_cache,
  cache_options: { 
    expires_in: 10.minutes, 
    key_prefix: 'myapp' 
  }
)

# Clear cache
og_service.clear_cache('https://example.com', cache: :rails)

# Batch operations
urls = ['https://example1.com', 'https://example2.com']
results = urls.map { |url| og_service.extract(url, cache: :rails) }
```

### MarkdownService

The `MarkdownService` provides flexible markdown rendering with sanitization:

```ruby
# Basic rendering
md_service = RichTextExtraction::MarkdownService.new
html = md_service.render('**Bold text**', sanitize: true)

# Custom renderer options
html = md_service.render('**Bold** text', 
  sanitize: true,
  renderer_options: { 
    hard_wrap: true,
    autolink: true,
    tables: true
  }
)

# Without sanitization (use with caution)
html = md_service.render('**Bold** text', sanitize: false)
```

## 🎯 Focused Extractors

### LinkExtractor

Include the `LinkExtractor` module for specialized link extraction:

```ruby
class MyCustomClass
  include RichTextExtraction::LinkExtractor
  
  def process_links(text)
    links = extract_links(text)
    markdown_links = extract_markdown_links(text)
    image_urls = extract_image_urls(text)
    attachment_urls = extract_attachment_urls(text)
    
    {
      links: links,
      markdown_links: markdown_links,
      images: image_urls,
      attachments: attachment_urls
    }
  end
  
  def validate_and_normalize(url)
    return nil unless valid_url?(url)
    normalize_url(url)
  end
end
```

### SocialExtractor

Include the `SocialExtractor` module for social content extraction:

```ruby
class SocialMediaProcessor
  include RichTextExtraction::SocialExtractor
  
  def analyze_social_content(text)
    {
      tags: extract_tags(text),
      mentions: extract_mentions(text),
      twitter_handles: extract_twitter_handles(text),
      instagram_handles: extract_instagram_handles(text),
      tags_with_context: extract_tags_with_context(text)
    }
  end
  
  def validate_hashtag(tag)
    valid_hashtag?(tag)
  end
end
```

## ⚙️ Configuration System

### Global Configuration

Configure RichTextExtraction globally in your Rails application:

```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  # OpenGraph settings
  config.opengraph_timeout = 15
  config.user_agent = 'MyApp/1.0'
  
  # Markdown settings
  config.sanitize_html = true
  config.default_excerpt_length = 300
  
  # Cache settings
  config.default_cache_options = { 
    expires_in: 1.hour,
    key_prefix: 'rte'
  }
  
  # Debug mode
  config.debug = Rails.env.development?
end
```

### Per-Instance Configuration

Override global settings for specific operations:

```ruby
# Override sanitization for trusted content
html = RichTextExtraction.render_markdown(trusted_content, sanitize: false)

# Custom cache options for specific URLs
extractor = RichTextExtraction::Extractor.new("https://example.com")
og_data = extractor.link_objects(
  with_opengraph: true,
  cache: :rails,
  cache_options: { expires_in: 5.minutes }
)
```

## 🔄 Custom Cache Implementations

### Custom Cache Adapter

Implement a custom cache adapter for your specific needs:

```ruby
class RedisCacheAdapter
  def initialize(redis_client)
    @redis = redis_client
  end
  
  def read(key)
    @redis.get(key)
  end
  
  def write(key, value, options = {})
    expires_in = options[:expires_in] || 1.hour
    @redis.setex(key, expires_in.to_i, value)
  end
  
  def delete(key)
    @redis.del(key)
  end
end

# Usage
redis_cache = RedisCacheAdapter.new(Redis.new)
og_service = RichTextExtraction::OpenGraphService.new
og_data = og_service.extract('https://example.com', cache: redis_cache)
```

### Rails Cache with Custom Options

```ruby
# Custom cache key generation
class CustomCache
  def self.fetch(key, options = {})
    Rails.cache.fetch("rich_text_extraction:#{key}", options) do
      yield
    end
  end
end

# Usage
og_data = og_service.extract('https://example.com', cache: CustomCache)
```

## 🎨 Custom View Helpers

### Custom OpenGraph Preview

Create custom view helpers for your specific needs:

```ruby
# app/helpers/custom_opengraph_helper.rb
module CustomOpengraphHelper
  def custom_opengraph_preview(og_data, options = {})
    return unless og_data && !og_data[:error]
    
    render partial: 'shared/custom_opengraph_preview', 
           locals: { og_data: og_data, options: options }
  end
  
  def opengraph_preview_card(og_data)
    return unless og_data && !og_data[:error]
    
    content_tag :div, class: 'og-card' do
      concat image_tag(og_data[:image]) if og_data[:image]
      concat content_tag(:h3, og_data[:title]) if og_data[:title]
      concat content_tag(:p, og_data[:description]) if og_data[:description]
    end
  end
end
```

### Custom Markdown Renderer

```ruby
# app/helpers/custom_markdown_helper.rb
module CustomMarkdownHelper
  def custom_markdown_render(text, options = {})
    html = RichTextExtraction.render_markdown(text, options)
    
    # Add custom CSS classes
    html.gsub(/<(\w+)/, '<\1 class="markdown-\1"')
  end
  
  def markdown_with_highlights(text)
    html = RichTextExtraction.render_markdown(text, sanitize: true)
    
    # Add syntax highlighting
    html.gsub(/```(\w+)\n(.*?)\n```/m) do |match|
      language = $1
      code = $2
      "<pre><code class=\"language-#{language}\">#{code}</code></pre>"
    end
  end
end
```

## 🔧 Error Handling

### Graceful Error Handling

```ruby
class SafeOpenGraphExtractor
  def extract_with_fallback(url)
    begin
      og_service = RichTextExtraction::OpenGraphService.new
      og_data = og_service.extract(url, cache: :rails)
      
      if og_data[:error]
        Rails.logger.warn "OpenGraph error for #{url}: #{og_data[:error]}"
        return fallback_data(url)
      end
      
      og_data
    rescue => e
      Rails.logger.error "OpenGraph extraction failed for #{url}: #{e.message}"
      fallback_data(url)
    end
  end
  
  private
  
  def fallback_data(url)
    {
      title: "Link",
      description: "Visit this link for more information",
      url: url,
      error: true
    }
  end
end
```

### Custom Error Classes

```ruby
class OpenGraphExtractionError < StandardError
  attr_reader :url, :original_error
  
  def initialize(url, original_error = nil)
    @url = url
    @original_error = original_error
    super("Failed to extract OpenGraph data from #{url}: #{original_error&.message}")
  end
end

# Usage in custom service
def safe_extract(url)
  og_service = RichTextExtraction::OpenGraphService.new
  og_data = og_service.extract(url, cache: :rails)
  
  if og_data[:error]
    raise OpenGraphExtractionError.new(url, og_data[:error])
  end
  
  og_data
rescue => e
  raise OpenGraphExtractionError.new(url, e)
end
```

## 🚀 Performance Optimization

### Batch Processing

```ruby
class BatchOpenGraphProcessor
  def process_urls(urls, batch_size: 10)
    results = []
    
    urls.each_slice(batch_size) do |batch|
      batch_results = batch.map do |url|
        Thread.new do
          og_service = RichTextExtraction::OpenGraphService.new
          og_service.extract(url, cache: :rails)
        end
      end.map(&:value)
      
      results.concat(batch_results)
    end
    
    results
  end
end
```

### Caching Strategies

```ruby
class SmartCacheStrategy
  def initialize
    @og_service = RichTextExtraction::OpenGraphService.new
  end
  
  def extract_with_smart_cache(url)
    # Try memory cache first
    cached = Rails.cache.read("og_memory:#{url}")
    return cached if cached
    
    # Try persistent cache
    cached = Rails.cache.read("og_persistent:#{url}")
    return cached if cached
    
    # Fetch and cache
    og_data = @og_service.extract(url, cache: false)
    
    # Cache in both layers
    Rails.cache.write("og_memory:#{url}", og_data, expires_in: 5.minutes)
    Rails.cache.write("og_persistent:#{url}", og_data, expires_in: 1.hour)
    
    og_data
  end
end
```

## 🧪 Testing Advanced Usage

### Testing Custom Extractors

```ruby
# spec/lib/custom_extractor_spec.rb
RSpec.describe CustomExtractor do
  let(:extractor) { CustomExtractor.new }
  
  describe '#process_links' do
    it 'extracts different types of links' do
      text = "Visit https://example.com and ![image](https://example.com/img.jpg)"
      result = extractor.process_links(text)
      
      expect(result[:links]).to include('https://example.com')
      expect(result[:images]).to include('https://example.com/img.jpg')
    end
  end
end
```

### Testing Custom Services

```ruby
# spec/services/custom_opengraph_service_spec.rb
RSpec.describe CustomOpenGraphService do
  let(:service) { CustomOpenGraphService.new }
  
  describe '#safe_extract' do
    it 'raises custom error on failure' do
      expect {
        service.safe_extract('invalid-url')
      }.to raise_error(OpenGraphExtractionError)
    end
  end
end
```

## 📚 Next Steps

- Explore the [API Reference]({{ site.baseurl }}/api-reference/) for complete method documentation
- Check out [Troubleshooting]({{ site.baseurl }}/_posts/2024-06-24-troubleshooting.html) for common issues
- Review the [Test Suite Guide]({{ site.baseurl }}/testing.html) for testing best practices

---

**RichTextExtraction** provides the flexibility you need for complex applications while maintaining simplicity for basic use cases. The modular architecture ensures that you can use only what you need and extend functionality as required. 
- [Full README & Guides](https://github.com/ceccec/rich_text_extraction#readme) 