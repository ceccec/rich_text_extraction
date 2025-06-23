# RichTextExtraction

[![Ruby](https://img.shields.io/badge/Ruby-3.1+-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-6.1+-blue.svg)](https://rubyonrails.org/)
[![Gem](https://img.shields.io/gem/v/rich_text_extraction.svg)](https://rubygems.org/gems/rich_text_extraction)
[![Tests](https://github.com/ceccec/rich_text_extraction/workflows/Tests/badge.svg)](https://github.com/ceccec/rich_text_extraction/actions)
[![Docs](https://github.com/ceccec/rich_text_extraction/workflows/Docs/badge.svg)](https://ceccec.github.io/rich_text_extraction/)

A professional Ruby gem for extracting rich text, Markdown, and OpenGraph metadata in Ruby and Rails applications. Features a modular architecture with service classes, focused extractors, and comprehensive configuration options.

## 🚀 Features

- **🔗 Link Extraction**: URLs, markdown links, images, attachments
- **🏷️ Social Content**: Tags (#), mentions (@), Twitter/Instagram handles
- **📝 Markdown Rendering**: Safe HTML output with sanitization
- **🌐 OpenGraph Metadata**: Automatic fetching and caching
- **📱 Rails Integration**: ActionText support with background jobs
- **⚙️ Modular Architecture**: Service classes and focused extractors
- **🔧 Configuration System**: Centralized settings with defaults

## 📦 Installation

Add this line to your application's Gemfile:

```ruby
gem 'rich_text_extraction'
```

And then execute:

```bash
bundle install
```

## 🎯 Quick Start

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

# In a controller or background job:
@post.body.link_objects(with_opengraph: true, cache: :rails)

# In a view:
<% @post.body.link_objects(with_opengraph: true, cache: :rails).each do |link| %>
  <%= opengraph_preview_for(link[:opengraph]) %>
<% end %>
```

## 🏗️ Modular Architecture

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

# Per-instance options
html = RichTextExtraction.render_markdown(text, sanitize: false)
```

## 🔧 Advanced Usage

### Custom Cache Options

```ruby
extractor = RichTextExtraction::Extractor.new("https://example.com")
extractor.link_objects(
  with_opengraph: true, 
  cache: :rails, 
  cache_options: { expires_in: 10.minutes, key_prefix: 'custom' }
)
```

### View Helper with Different Formats

```erb
<%= opengraph_preview_for("https://example.com", format: :markdown) %>
<%= opengraph_preview_for("https://example.com", format: :text) %>
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

## 🧪 Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/extractor_spec.rb
bundle exec rspec spec/opengraph_helpers_spec.rb
```

## 📚 Documentation

- **[Full Documentation](https://ceccec.github.io/rich_text_extraction/)**
- **[API Reference](https://ceccec.github.io/rich_text_extraction/api-reference/)**
- **[Test Suite Guide](docs/testing.md)**

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
└── ... (other modules)
```

## 🔒 Security & Performance

- **Safe Markdown**: All rendered HTML is sanitized for XSS protection
- **Caching**: OpenGraph metadata is cached for performance
- **Thread-safe**: Designed for concurrent use in Rails apps
- **No external calls unless needed**: OpenGraph fetches only when requested

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/ceccec/rich_text_extraction/issues)
- **Documentation**: [Docs Site](https://ceccec.github.io/rich_text_extraction/)
- **API Reference**: [API Docs](https://ceccec.github.io/rich_text_extraction/api-reference/)

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀