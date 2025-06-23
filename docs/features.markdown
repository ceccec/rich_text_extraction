---
layout: page
title: "Features"
permalink: /features.html
---

# RichTextExtraction Features

RichTextExtraction is a comprehensive Ruby gem that provides powerful tools for extracting and processing rich text content. Here's a complete overview of all available features.

## 🔗 Link Extraction

### URL Extraction
Extract all types of URLs from text content with advanced validation and normalization.

```ruby
extractor = RichTextExtraction::Extractor.new("Visit https://example.com and http://test.org")
extractor.links
# => ["https://example.com", "http://test.org"]
```

**Features:**
- **Protocol validation** - Supports HTTP, HTTPS, FTP, and other protocols
- **URL normalization** - Converts relative URLs to absolute URLs
- **Duplicate removal** - Automatically removes duplicate URLs
- **Malformed URL filtering** - Filters out invalid URLs

### Markdown Link Extraction
Extract links from Markdown syntax with text and URL separation.

```ruby
text = "Check out [our website](https://example.com) and [docs](https://docs.example.com)"
extractor = RichTextExtraction::Extractor.new(text)
extractor.markdown_links
# => [{ text: "our website", url: "https://example.com" }, { text: "docs", url: "https://docs.example.com" }]
```

### Image URL Extraction
Extract image URLs from various formats.

```ruby
text = "![Alt text](https://example.com/image.jpg) and <img src='https://example.com/photo.png'>"
extractor = RichTextExtraction::Extractor.new(text)
extractor.image_urls
# => ["https://example.com/image.jpg", "https://example.com/photo.png"]
```

### Attachment URL Extraction
Extract file attachment URLs with type detection.

```ruby
text = "Download [document.pdf](https://example.com/files/document.pdf)"
extractor = RichTextExtraction::Extractor.new(text)
extractor.attachment_urls
# => ["https://example.com/files/document.pdf"]
```

## 🏷️ Social Content Extraction

### Hashtag Extraction
Extract hashtags from text with context preservation.

```ruby
extractor = RichTextExtraction::Extractor.new("Check out #ruby #rails #programming")
extractor.tags
# => ["ruby", "rails", "programming"]
```

**Features:**
- **Multi-language support** - Works with Unicode characters
- **Context preservation** - Maintains hashtag position in text
- **Case sensitivity** - Preserves original case
- **Special character handling** - Handles underscores, hyphens, and numbers

### Mention Extraction
Extract user mentions from various platforms.

```ruby
extractor = RichTextExtraction::Extractor.new("Hello @alice and @bob!")
extractor.mentions
# => ["alice", "bob"]
```

### Platform-Specific Handles
Extract handles for specific social media platforms.

```ruby
extractor = RichTextExtraction::Extractor.new("Follow @username on Twitter and @instagram_user on Instagram")
extractor.twitter_handles
# => ["username"]
extractor.instagram_handles
# => ["instagram_user"]
```

## 📝 Markdown Rendering

### Safe HTML Rendering
Convert Markdown to safe HTML with built-in sanitization.

```ruby
markdown_service = RichTextExtraction::MarkdownService.new
html = markdown_service.render("**Bold text** and [links](https://example.com)")
# => "<p><strong>Bold text</strong> and <a href=\"https://example.com\" target=\"_blank\" rel=\"noopener noreferrer\">links</a></p>"
```

**Security Features:**
- **XSS Protection** - Automatic HTML sanitization
- **Script removal** - Removes `<script>` tags and JavaScript
- **Attribute filtering** - Filters dangerous HTML attributes
- **Link security** - Adds `target="_blank"` and `rel="noopener noreferrer"`

### Multiple Renderer Support
Support for multiple Markdown renderers with fallback options.

```ruby
# Redcarpet (default)
service = RichTextExtraction::MarkdownService.new(renderer: :redcarpet)

# Kramdown
service = RichTextExtraction::MarkdownService.new(renderer: :kramdown)

# CommonMarker
service = RichTextExtraction::MarkdownService.new(renderer: :commonmarker)
```

### Custom Renderer Options
Configure renderer behavior with custom options.

```ruby
service = RichTextExtraction::MarkdownService.new(
  renderer_options: {
    hard_wrap: true,
    autolink: true,
    tables: true,
    fenced_code_blocks: true,
    strikethrough: true
  }
)
```

## 🌐 OpenGraph Metadata

### Automatic Metadata Fetching
Fetch OpenGraph metadata from URLs with intelligent caching.

```ruby
og_service = RichTextExtraction::OpenGraphService.new
metadata = og_service.extract('https://example.com')
# => { title: "Example Site", description: "...", image: "...", url: "..." }
```

**Extracted Data:**
- **Title** - Page title from OpenGraph or HTML
- **Description** - Page description
- **Image** - Featured image URL
- **URL** - Canonical URL
- **Site name** - Website name
- **Type** - Content type (article, website, etc.)

### Intelligent Caching
Built-in caching system for performance optimization.

```ruby
# Use Rails cache
metadata = og_service.extract('https://example.com', cache: :rails)

# Custom cache options
metadata = og_service.extract('https://example.com',
  cache: :rails,
  cache_options: { expires_in: 10.minutes, key_prefix: 'myapp' }
)
```

### Error Handling
Graceful error handling with fallback options.

```ruby
metadata = og_service.extract('https://example.com')
if metadata[:error]
  Rails.logger.warn "OpenGraph error: #{metadata[:error]}"
  # Use fallback data
end
```

## 📱 Rails Integration

### ActionText Support
Seamless integration with Rails ActionText.

```ruby
class Post < ApplicationRecord
  include RichTextExtraction::ExtractsRichText
  has_rich_text :body
end

# Extract content from ActionText
post = Post.find(1)
links = post.body.extract_links
tags = post.body.extract_tags
```

### View Helpers
Built-in view helpers for rendering OpenGraph previews.

```erb
<!-- Render OpenGraph preview -->
<%= render_opengraph_preview(@post.body) %>

<!-- Custom format -->
<%= render_opengraph_preview(@post.body, format: :markdown) %>
```

### Background Job Support
Process OpenGraph data in background jobs for better performance.

```ruby
class ExtractLinksJob < ApplicationJob
  def perform(post_id)
    post = Post.find(post_id)
    post.body.link_objects(with_opengraph: true)
  end
end
```

## ⚙️ Configuration System

### Global Configuration
Centralized configuration with sensible defaults.

```ruby
RichTextExtraction.configure do |config|
  # Caching
  config.cache_enabled = true
  config.cache_prefix = 'rte'
  config.cache_ttl = 1.hour
  
  # OpenGraph
  config.opengraph_timeout = 5.seconds
  config.opengraph_user_agent = 'RichTextExtraction/1.0'
  
  # Markdown
  config.markdown_renderer = :redcarpet
  config.markdown_options = { hard_wrap: true }
end
```

### Environment-Specific Settings
Different configurations for different environments.

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

## 🔧 Advanced Features

### Custom Extractors
Extend functionality with custom extractors.

```ruby
module CustomExtractor
  def extract_emails(text)
    text.scan(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/)
  end
end

class RichTextExtraction::Extractor
  include CustomExtractor
end
```

### Custom Cache Backends
Use custom cache implementations.

```ruby
class RedisCache
  def initialize(redis_client)
    @redis = redis_client
  end
  
  def read(key)
    @redis.get(key)
  end
  
  def write(key, value, options = {})
    @redis.setex(key, options[:expires_in] || 3600, value)
  end
end

og_service = RichTextExtraction::OpenGraphService.new
metadata = og_service.extract('https://example.com', cache: RedisCache.new(Redis.new))
```

### Batch Processing
Process multiple URLs efficiently.

```ruby
urls = ['https://example1.com', 'https://example2.com', 'https://example3.com']
og_service = RichTextExtraction::OpenGraphService.new

results = urls.map do |url|
  og_service.extract(url, cache: :rails)
end
```

## 🧪 Testing Support

### Comprehensive Test Suite
Extensive test coverage with 35+ examples.

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/extractor_spec.rb
bundle exec rspec spec/opengraph_helpers_spec.rb
```

### Test Utilities
Built-in testing utilities and shared contexts.

```ruby
RSpec.describe RichTextExtraction::Extractor do
  include_context 'with sample text'
  include_context 'with OpenGraph service'
  
  it 'extracts links from text' do
    extractor = described_class.new(sample_text)
    expect(extractor.links).to eq(sample_links)
  end
end
```

## 🚀 Performance Features

### Lazy Loading
OpenGraph data is fetched only when requested.

```ruby
# No network request until OpenGraph is requested
extractor = RichTextExtraction::Extractor.new("Visit https://example.com")
links = extractor.links  # No network request
opengraph_links = extractor.link_objects(with_opengraph: true)  # Network request here
```

### Memory Optimization
Efficient memory usage with streaming and batching.

```ruby
# Process large datasets in batches
posts.find_in_batches(batch_size: 100) do |batch|
  batch.each do |post|
    post.body.extract_links
  end
  GC.start  # Force garbage collection
end
```

### Thread Safety
Designed for concurrent use in Rails applications.

```ruby
# Safe for concurrent access
Thread.new do
  extractor = RichTextExtraction::Extractor.new("https://example1.com")
  extractor.link_objects(with_opengraph: true)
end

Thread.new do
  extractor = RichTextExtraction::Extractor.new("https://example2.com")
  extractor.link_objects(with_opengraph: true)
end
```

## 🔒 Security Features

### Input Validation
Comprehensive input validation and sanitization.

```ruby
# URL validation
extractor = RichTextExtraction::Extractor.new("https://example.com")
extractor.valid_urls  # Only returns valid URLs

# HTML sanitization
html = markdown_service.render("**Bold** <script>alert('xss')</script>")
# Script tags are automatically removed
```

### Safe Defaults
Secure by default with configurable security levels.

```ruby
# All HTML is sanitized by default
html = markdown_service.render(content)

# Only disable sanitization for trusted content
html = markdown_service.render(trusted_content, sanitize: false)
```

## 📊 Monitoring and Debugging

### Debug Mode
Enable detailed logging for troubleshooting.

```ruby
RichTextExtraction.configure do |config|
  config.debug = true
end

# Detailed logs in development.log
```

### Health Checks
Built-in health check utilities.

```ruby
# Check service health
health = RichTextExtraction::OpenGraphService.new.health_check
# => { cache_working: true, service_working: true, response_time: 150 }
```

### Performance Monitoring
Track performance metrics.

```ruby
ActiveSupport::Notifications.subscribe 'opengraph.extract' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.info "OpenGraph extraction took #{event.duration}ms"
end
```

---

Ready to get started? Check out our [Getting Started Guide]({{ site.baseurl }}/_posts/2025-06-24-getting-started.html) or jump straight to the [API Reference]({{ site.baseurl }}/api-reference/).

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀 