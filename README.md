# RichTextExtraction

[![Tests](https://github.com/ceccec/rich_text_extraction/actions/workflows/main.yml/badge.svg)](https://github.com/ceccec/rich_text_extraction/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/rich_text_extraction.svg)](https://badge.fury.io/rb/rich_text_extraction)
[![Documentation](https://img.shields.io/badge/docs-YARD-blue.svg)](https://ceccec.github.io/rich_text_extraction/)

A professional Ruby gem for extracting rich text, Markdown, and OpenGraph metadata from content in Ruby and Rails applications. Built with modularity, performance, and developer experience in mind.

## ✨ Features

- **🔗 Link Extraction**: Extract URLs, hashtags, and mentions from text
- **📄 Markdown Rendering**: Safe Markdown to HTML conversion with customizable renderers
- **🌐 OpenGraph Metadata**: Fetch and cache OpenGraph data from external URLs
- **🚀 Rails Integration**: Seamless integration with Rails and ActionText
- **⚡ Background Jobs**: Support for background processing with ActiveJob
- **💾 Caching**: Built-in caching with configurable backends
- **🛡️ Error Handling**: Robust error handling and fallbacks
- **📚 Comprehensive Documentation**: Full API documentation with examples
- **🧪 Extensive Testing**: 35+ test examples with 100% pass rate

## 🚀 Quick Start

### Installation

Add to your Gemfile:

```ruby
gem 'rich_text_extraction'
```

### Basic Usage

```ruby
# Extract links from text
extractor = RichTextExtraction::Extractor.new("Visit https://example.com and check out #ruby")
extractor.links        # => ["https://example.com"]
extractor.tags         # => ["ruby"]
extractor.mentions     # => []

# Get rich link objects with OpenGraph data
link_objects = extractor.link_objects(with_opengraph: true)
# => [{ url: "https://example.com", opengraph: { title: "Example Site", ... } }]

# Render Markdown safely
markdown_service = RichTextExtraction::MarkdownService.new
html = markdown_service.render("**Bold text** and [links](https://example.com)")
# => "<p><strong>Bold text</strong> and <a href=\"https://example.com\">links</a></p>"
```

### Rails Integration

```ruby
# In your model
class Post < ApplicationRecord
  include RichTextExtraction::ExtractsRichText
  
  has_rich_text :body
end

# In your view
<%= render_opengraph_preview(@post.body) %>

# In your controller
def show
  @post = Post.find(params[:id])
  @links = @post.body.extract_links(with_opengraph: true)
end
```

## 📖 Documentation

- **[API Documentation](https://ceccec.github.io/rich_text_extraction/)** - Complete API reference
- **[Getting Started](https://ceccec.github.io/rich_text_extraction/getting-started.html)** - Installation and basic usage
- **[Advanced Usage](https://ceccec.github.io/rich_text_extraction/advanced-usage.html)** - Advanced features and customization
- **[Testing Guide](https://ceccec.github.io/rich_text_extraction/testing.html)** - Test suite organization and best practices
- **[Contributing](CONTRIBUTING.md)** - How to contribute to the project

## 🏗️ Architecture

RichTextExtraction is built with a modular architecture:

- **Services**: `OpenGraphService`, `MarkdownService` for core functionality
- **Extractors**: `LinkExtractor`, `SocialExtractor` for content parsing
- **Helpers**: View helpers, instance helpers, and extraction helpers
- **Configuration**: Centralized configuration system
- **Rails Integration**: Railtie for automatic Rails setup

## 🧪 Testing

The project includes a comprehensive test suite with 35+ examples covering all functionality:

```bash
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run RuboCop for code quality
bundle exec rubocop
```

**Current Status**: ✅ All tests pass (35 examples, 0 failures)

See the [Testing Guide](docs/testing.md) for detailed information about the test suite organization, best practices, and CI/CD integration.

## 🔧 Configuration

```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  config.cache_enabled = true
  config.cache_prefix = 'rte'
  config.cache_ttl = 1.hour
  
  config.opengraph_timeout = 5.seconds
  config.opengraph_user_agent = 'RichTextExtraction/1.0'
  
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

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
git clone https://github.com/ceccec/rich_text_extraction.git
cd rich_text_extraction
bundle install
bundle exec rspec
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## 🏷️ Version

Current version: **0.1.0**

## Test & Quality Status (June 2025)

- **RSpec:** 35 examples, 0 failures
- **RuboCop:** No offenses detected
- **YARD:** 85.86% documented, a few dynamic mixin warnings (expected for Rails mixins)
- **Gem build:** No gemspec self-inclusion error (fixed June 2025)

---

**RichTextExtraction** – Professional rich text extraction for Ruby and Rails applications. 🚀