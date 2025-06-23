---
layout: page
title: Features
permalink: /features/
---

# RichTextExtraction Features

RichTextExtraction is a comprehensive Ruby gem that provides professional-grade rich text extraction, Markdown rendering, and OpenGraph metadata handling. Built with a modern modular architecture for maximum flexibility and maintainability.

## 🔗 Link Extraction

Extract various types of links from any text content:

### URL Extraction
```ruby
extractor = RichTextExtraction::Extractor.new("Visit https://example.com and http://test.org")
extractor.links
# => ["https://example.com", "http://test.org"]
```

### Markdown Link Extraction
```ruby
text = "Check out [our site](https://example.com) and ![image](https://example.com/image.jpg)"
extractor = RichTextExtraction::Extractor.new(text)
extractor.markdown_links
# => ["https://example.com", "https://example.com/image.jpg"]
```

### Image URL Extraction
```ruby
extractor = RichTextExtraction::Extractor.new("Image: https://example.com/photo.jpg")
extractor.image_urls
# => ["https://example.com/photo.jpg"]
```

### Attachment URL Extraction
```ruby
extractor = RichTextExtraction::Extractor.new("Download: https://example.com/file.pdf")
extractor.attachment_urls
# => ["https://example.com/file.pdf"]
```

## 🏷️ Social Content Extraction

Extract social media content and metadata:

### Hashtag Extraction
```ruby
extractor = RichTextExtraction::Extractor.new("Check out #ruby #rails #programming")
extractor.tags
# => ["ruby", "rails", "programming"]
```

### Mention Extraction
```ruby
extractor = RichTextExtraction::Extractor.new("Hello @alice and @bob!")
extractor.mentions
# => ["alice", "bob"]
```

### Social Media Handles
```ruby
extractor = RichTextExtraction::Extractor.new("Follow @twitter_handle and @instagram_user")
extractor.twitter_handles
# => ["twitter_handle"]
extractor.instagram_handles
# => ["instagram_user"]
```

## 📝 Markdown Rendering

Safe and flexible Markdown rendering with multiple options:

### Basic Rendering
```ruby
html = RichTextExtraction.render_markdown("**Bold** and *italic* text")
# => "<p><strong>Bold</strong> and <em>italic</em> text</p>"
```

### With Link Processing
```ruby
html = RichTextExtraction.render_markdown("[Link](https://example.com)")
# => "<p><a href=\"https://example.com\" target=\"_blank\" rel=\"noopener noreferrer\">Link</a></p>"
```

### Custom Options
```ruby
html = RichTextExtraction.render_markdown(
  "**Bold** text", 
  sanitize: true, 
  renderer_options: { hard_wrap: true }
)
```

## 🌐 OpenGraph Metadata

Fetch and cache OpenGraph metadata for any URL:

### Basic OpenGraph Extraction
```ruby
extractor = RichTextExtraction::Extractor.new("https://example.com")
og_data = extractor.link_objects(with_opengraph: true).first[:opengraph]
# => { title: "Example Site", description: "...", image: "..." }
```

### Cached OpenGraph
```ruby
og_data = extractor.link_objects(
  with_opengraph: true, 
  cache: :rails
).first[:opengraph]
```

### Direct Service Usage
```ruby
og_service = RichTextExtraction::OpenGraphService.new
og_data = og_service.extract('https://example.com', cache: :rails)
```

## 📱 Rails & ActionText Integration

Seamless integration with Rails and ActionText:

### ActionText Models
```ruby
class Post < ApplicationRecord
  has_rich_text :body
  include RichTextExtraction::ExtractsRichText
end

# Extract links with OpenGraph data
@post.body.link_objects(with_opengraph: true, cache: :rails)
```

### View Helpers
```erb
<!-- OpenGraph preview -->
<% @post.body.link_objects(with_opengraph: true).each do |link| %>
  <%= opengraph_preview_for(link[:opengraph]) %>
<% end %>

<!-- Different formats -->
<%= opengraph_preview_for(og_data, format: :markdown) %>
<%= opengraph_preview_for(og_data, format: :text) %>
```

### Background Jobs
```ruby
class LinkPreviewJob < ApplicationJob
  def perform(post)
    post.body.link_objects(with_opengraph: true, cache: :rails)
  end
end
```

## 🏗️ Modular Architecture

RichTextExtraction features a modern modular architecture designed for maintainability and extensibility:

### Service Classes

#### OpenGraphService
Handles all OpenGraph operations with caching:
```ruby
og_service = RichTextExtraction::OpenGraphService.new
og_data = og_service.extract('https://example.com', cache: :rails)
og_service.clear_cache('https://example.com', cache: :rails)
```

#### MarkdownService
Handles markdown rendering with sanitization:
```ruby
md_service = RichTextExtraction::MarkdownService.new
html = md_service.render('**Bold text**', sanitize: true)
```

### Focused Extractors

#### LinkExtractor
Specialized link extraction functionality:
```ruby
include RichTextExtraction::LinkExtractor

extract_links(text)           # URLs
extract_markdown_links(text)  # Markdown links
extract_image_urls(text)      # Image URLs
extract_attachment_urls(text) # Attachment URLs
valid_url?(url)              # URL validation
normalize_url(url)           # URL normalization
```

#### SocialExtractor
Social content extraction:
```ruby
include RichTextExtraction::SocialExtractor

extract_tags(text)            # Hashtags
extract_mentions(text)        # Mentions
extract_twitter_handles(text) # Twitter handles
extract_instagram_handles(text) # Instagram handles
extract_tags_with_context(text) # Tags with surrounding text
valid_hashtag?(tag)          # Hashtag validation
```

### Configuration System

Centralized configuration with sensible defaults:
```ruby
RichTextExtraction.configure do |config|
  config.opengraph_timeout = 15
  config.sanitize_html = true
  config.default_excerpt_length = 300
  config.default_cache_options = { expires_in: 1.hour }
  config.debug = false
  config.user_agent = 'MyApp/1.0'
end
```

## 🔧 Advanced Features

### Custom Cache Options
```ruby
extractor.link_objects(
  with_opengraph: true, 
  cache: :rails, 
  cache_options: { 
    expires_in: 10.minutes, 
    key_prefix: 'myapp' 
  }
)
```

### Error Handling
```ruby
result = extractor.link_objects(with_opengraph: true)
if result.first[:opengraph][:error]
  Rails.logger.warn "OpenGraph error: #{result.first[:opengraph][:error]}"
end
```

### URL Validation & Normalization
```ruby
include RichTextExtraction::LinkExtractor

valid_url?('https://example.com')  # => true
valid_url?('not-a-url')           # => false
normalize_url('example.com')      # => 'https://example.com'
```

### Context-Aware Extraction
```ruby
include RichTextExtraction::SocialExtractor

extract_tags_with_context("Check out #ruby programming")
# => [{ tag: "ruby", context: "Check out #ruby programming" }]
```

## 🔒 Security & Performance

### Security Features
- **Safe Markdown**: All rendered HTML is sanitized for XSS protection
- **Input Validation**: URL and content validation
- **Error Handling**: Graceful fallbacks for failed requests

### Performance Optimizations
- **Caching**: OpenGraph metadata is cached (Rails.cache or custom cache)
- **Lazy Loading**: OpenGraph fetches only when requested
- **Thread-safe**: Designed for concurrent use in Rails apps

## 🧪 Testing & Quality

### Comprehensive Test Suite
- Feature-focused test organization
- Shared contexts for reusable setup
- Advanced usage scenarios
- Placeholder specs for all modules

### Code Quality
- RuboCop compliance
- YARD documentation
- RSpec best practices
- Continuous integration

## 🚀 Getting Started

Ready to get started? Check out our [Getting Started Guide]({{ site.baseurl }}/_posts/2024-06-24-getting-started.html) or jump straight to the [API Reference]({{ site.baseurl }}/api-reference/).

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀 