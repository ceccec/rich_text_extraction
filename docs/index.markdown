---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: page
title: RichTextExtraction
permalink: /
---

# RichTextExtraction

[![Ruby](https://img.shields.io/badge/Ruby-3.1+-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-6.1+-blue.svg)](https://rubyonrails.org/)
[![Gem](https://img.shields.io/gem/v/rich_text_extraction.svg)](https://rubygems.org/gems/rich_text_extraction)
[![Tests](https://github.com/ceccec/rich_text_extraction/workflows/Tests/badge.svg)](https://github.com/ceccec/rich_text_extraction/actions)
[![Docs](https://github.com/ceccec/rich_text_extraction/workflows/Docs/badge.svg)](https://ceccec.github.io/rich_text_extraction/)

A professional Ruby gem for extracting rich text, Markdown, and OpenGraph metadata in Ruby and Rails applications. Features a modern modular architecture with service classes, focused extractors, and comprehensive configuration options.

## 🚀 What is RichTextExtraction?

RichTextExtraction is an all-in-one solution for extracting structured data (links, tags, mentions, emails, phone numbers, dates, Twitter handles, and OpenGraph metadata) from any text, Markdown, or ActionText content. It is designed for Ruby and Rails developers who want to:

- **🔗 Extract Links**: URLs, markdown links, images, attachments
- **🏷️ Process Social Content**: Tags (#), mentions (@), Twitter/Instagram handles
- **📝 Render Markdown**: Safe HTML output with sanitization
- **🌐 Fetch OpenGraph**: Automatic metadata fetching and caching
- **📱 Integrate with Rails**: ActionText support with background jobs
- **⚙️ Use Modular Architecture**: Service classes and focused extractors

## 🎯 Quick Start

### Installation

```ruby
# Gemfile
gem 'rich_text_extraction'
```

```bash
bundle install
```

### Basic Usage

```ruby
require 'rich_text_extraction'

# Extract links from text
text = "Visit https://example.com and check out #ruby"
extractor = RichTextExtraction::Extractor.new(text)

extractor.links      # => ["https://example.com"]
extractor.tags       # => ["ruby"]
extractor.mentions   # => []

# Render markdown
html = RichTextExtraction.render_markdown("**Bold** [link](https://example.com)")
# => "<p><strong>Bold</strong> <a href=\"https://example.com\" target=\"_blank\" rel=\"noopener noreferrer\">link</a></p>"
```

### Rails & ActionText Integration

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  include RichTextExtraction::ExtractsRichText
end

# Extract links with OpenGraph data
@post.body.link_objects(with_opengraph: true, cache: :rails)

# In a view
<% @post.body.link_objects(with_opengraph: true).each do |link| %>
  <%= opengraph_preview_for(link[:opengraph]) %>
<% end %>
```

## 🏗️ Modular Architecture

RichTextExtraction features a modern modular architecture designed for maintainability, testability, and extensibility:

### Service Classes

```ruby
# OpenGraph Service
og_service = RichTextExtraction::OpenGraphService.new
og_data = og_service.extract('https://example.com', cache: :rails)

# Markdown Service
md_service = RichTextExtraction::MarkdownService.new
html = md_service.render('**Bold text**', sanitize: true)
```

### Focused Extractors

```ruby
include RichTextExtraction::LinkExtractor
include RichTextExtraction::SocialExtractor

# Link extraction
extract_links(text)           # URLs
extract_markdown_links(text)  # Markdown links
extract_image_urls(text)      # Image URLs
extract_attachment_urls(text) # Attachment URLs

# Social extraction
extract_tags(text)            # Hashtags
extract_mentions(text)        # Mentions
extract_twitter_handles(text) # Twitter handles
extract_instagram_handles(text) # Instagram handles
```

### Configuration System

```ruby
# Global configuration
RichTextExtraction.configure do |config|
  config.opengraph_timeout = 15
  config.sanitize_html = true
  config.default_excerpt_length = 300
  config.default_cache_options = { expires_in: 1.hour }
end
```

## 📚 Documentation

### Guides

- **[Getting Started]({{ site.baseurl }}/_posts/2024-06-24-getting-started.html)** - Quick setup and basic usage
- **[ActionText Integration]({{ site.baseurl }}/_posts/2024-06-24-actiontext-integration.html)** - Rails and ActionText integration
- **[Markdown Rendering]({{ site.baseurl }}/_posts/2024-06-24-markdown-rendering.html)** - Safe markdown rendering
- **[Advanced Usage]({{ site.baseurl }}/_posts/2024-06-24-advanced-usage.html)** - Customization and extension
- **[Troubleshooting]({{ site.baseurl }}/_posts/2024-06-24-troubleshooting.html)** - Common issues and solutions

### Reference

- **[Features]({{ site.baseurl }}/features/)** - Complete feature overview
- **[API Reference]({{ site.baseurl }}/api-reference/)** - Full API documentation
- **[Test Suite Guide]({{ site.baseurl }}/testing.html)** - Testing best practices

## 🔧 Advanced Features

### Custom Cache Options

```ruby
extractor = RichTextExtraction::Extractor.new("https://example.com")
extractor.link_objects(
  with_opengraph: true, 
  cache: :rails, 
  cache_options: { expires_in: 10.minutes, key_prefix: 'custom' }
)
```

### Direct Service Usage

```ruby
# OpenGraph with custom options
og_service = RichTextExtraction::OpenGraphService.new
og_data = og_service.extract('https://example.com', 
  cache: custom_cache, 
  cache_options: { key_prefix: 'myapp' }
)

# Markdown with custom renderer
md_service = RichTextExtraction::MarkdownService.new
html = md_service.render('**Bold**', 
  sanitize: true, 
  renderer_options: { custom_option: true }
)
```

### Error Handling

```ruby
# OpenGraph errors are captured
result = extractor.link_objects(with_opengraph: true)
if result.first[:opengraph][:error]
  Rails.logger.warn "OpenGraph error: #{result.first[:opengraph][:error]}"
end
```

## 🧪 Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/extractor_spec.rb
bundle exec rspec spec/opengraph_helpers_spec.rb
```

The test suite is organized by feature for maximum clarity and maintainability, with shared contexts and comprehensive coverage.

## 🏗️ Architecture Overview

```
lib/rich_text_extraction/
├── services/                    # Service classes
│   ├── opengraph_service.rb    # OpenGraph operations
│   └── markdown_service.rb     # Markdown rendering
├── extractors/                  # Focused extractors
│   ├── link_extractor.rb       # Link extraction
│   └── social_extractor.rb     # Social content
├── configuration.rb            # Configuration system
├── error.rb                    # Error handling
├── extractor.rb                # Main Extractor class
├── extracts_rich_text.rb       # Rails concern
├── helpers.rb                  # View helpers
├── instance_helpers.rb         # Instance helpers
├── markdown_helpers.rb         # Markdown helpers
├── opengraph_helpers.rb        # OpenGraph helpers
├── railtie.rb                  # Rails integration
└── version.rb                  # Version info
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

## 🚀 Getting Help

- **Documentation**: [Full docs site]({{ site.baseurl }}/)
- **API Reference**: [API docs]({{ site.baseurl }}/api-reference/)
- **Issues**: [GitHub Issues](https://github.com/ceccec/rich_text_extraction/issues)
- **Contributing**: [CONTRIBUTING.md](https://github.com/ceccec/rich_text_extraction/blob/main/CONTRIBUTING.md)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.txt](https://github.com/ceccec/rich_text_extraction/blob/main/LICENSE.txt) file for details.

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀
