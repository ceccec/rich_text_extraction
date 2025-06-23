---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: page
title: "RichTextExtraction Documentation"
permalink: /
---

# RichTextExtraction Documentation

Welcome to the comprehensive documentation for RichTextExtraction, a professional Ruby gem for extracting rich text, Markdown, and OpenGraph metadata from content in Ruby and Rails applications.

## 🚀 Quick Start

Get up and running with RichTextExtraction in minutes:

```ruby
# Add to your Gemfile
gem 'rich_text_extraction'

# Basic usage
extractor = RichTextExtraction::Extractor.new("Visit https://example.com and check out #ruby")
extractor.links        # => ["https://example.com"]
extractor.tags         # => ["ruby"]
extractor.mentions     # => []

# Get rich link objects with OpenGraph data
link_objects = extractor.link_objects(with_opengraph: true)
# => [{ url: "https://example.com", opengraph: { title: "Example Site", ... } }]
```

## 📚 Documentation Sections

### Getting Started
- **[Getting Started]({{ site.baseurl }}/_posts/2025-06-24-getting-started.html)** - Quick setup and basic usage
- **[ActionText Integration]({{ site.baseurl }}/_posts/2025-06-24-actiontext-integration.html)** - Rails and ActionText integration
- **[Markdown Rendering]({{ site.baseurl }}/_posts/2025-06-24-markdown-rendering.html)** - Safe markdown rendering
- **[Advanced Usage]({{ site.baseurl }}/_posts/2025-06-24-advanced-usage.html)** - Customization and extension
- **[Troubleshooting]({{ site.baseurl }}/_posts/2025-06-24-troubleshooting.html)** - Common issues and solutions

### API Reference
- **[API Documentation]({{ site.baseurl }}/api/)** - Complete API reference
- **[Class List]({{ site.baseurl }}/api/class_list.html)** - All classes and modules
- **[Method List]({{ site.baseurl }}/api/method_list.html)** - All public methods

### Guides and Tutorials
- **[Features Overview]({{ site.baseurl }}/features.html)** - Complete feature list
- **[Testing Guide]({{ site.baseurl }}/testing.html)** - Test suite organization and best practices
- **[Contributing]({{ site.baseurl }}/../CONTRIBUTING.html)** - How to contribute to the project

## 🏗️ Architecture Overview

RichTextExtraction is built with a modular architecture:

```
lib/rich_text_extraction/
├── services/                    # Service classes
│   ├── opengraph_service.rb    # OpenGraph operations
│   └── markdown_service.rb     # Markdown rendering
├── extractors/                  # Focused extractors
│   ├── link_extractor.rb       # Link extraction
│   └── social_extractor.rb     # Social content
├── helpers.rb                  # View and instance helpers
├── configuration.rb            # Configuration system
└── railtie.rb                 # Rails integration
```

## ✨ Key Features

### 🔗 Link Extraction
Extract URLs, markdown links, images, and attachments from text with advanced validation and normalization.

### 🏷️ Social Content
Extract hashtags (#), mentions (@), Twitter/Instagram handles, and other social media content.

### 📝 Markdown Rendering
Safe HTML output with sanitization, customizable renderers (Redcarpet, Kramdown, CommonMarker), and security features.

### 🌐 OpenGraph Metadata
Automatic fetching and caching of OpenGraph data from external URLs with configurable timeouts and error handling.

### 📱 Rails Integration
Seamless integration with Rails and ActionText, including background job support and view helpers.

### ⚙️ Modular Architecture
Service classes and focused extractors for better separation of concerns and extensibility.

### 🔧 Configuration System
Centralized configuration with sensible defaults and environment-specific options.

## 🧪 Testing

The project includes a comprehensive test suite:

```bash
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run RuboCop for code quality
bundle exec rubocop
```

**Current Status**: ✅ All tests pass (35 examples, 0 failures)

See the [Testing Guide]({{ site.baseurl }}/testing.html) for detailed information about the test suite organization, best practices, and CI/CD integration.

## 🔧 Configuration

Configure RichTextExtraction in your Rails application:

```ruby
# config/initializers/rich_text_extraction.rb
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
  config.markdown_options = { hard_wrap: true, link_attributes: { target: '_blank' } }
end
```

## 🚀 Performance

- **Fast Execution**: Test suite runs in ~1.23 seconds
- **Efficient Caching**: Configurable caching with TTL support
- **Background Processing**: Support for background jobs to avoid blocking
- **Memory Efficient**: Minimal memory footprint with lazy loading

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md]({{ site.baseurl }}/../CONTRIBUTING.html) for guidelines.

### Development Setup

```bash
git clone https://github.com/ceccec/rich_text_extraction.git
cd rich_text_extraction
bundle install
bundle exec rspec
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.txt]({{ site.baseurl }}/../LICENSE.txt) file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/ceccec/rich_text_extraction/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ceccec/rich_text_extraction/discussions)
- **Documentation**: [API Reference]({{ site.baseurl }}/api/)

---

**RichTextExtraction** – Professional rich text extraction for Ruby and Rails applications. 🚀
