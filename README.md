# RichTextExtraction

[![Tests](https://github.com/ceccec/rich_text_extraction/actions/workflows/main.yml/badge.svg)](https://github.com/ceccec/rich_text_extraction/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/rich_text_extraction.svg)](https://badge.fury.io/rb/rich_text_extraction)
[![Documentation](https://img.shields.io/badge/docs-YARD-blue.svg)](https://ceccec.github.io/rich_text_extraction/)

Professional rich text, Markdown, and OpenGraph extraction for Ruby and Rails applications.

## Features
- Extract links, tags, mentions, emails, attachments, phone numbers, dates, and more
- Safe Markdown rendering (Redcarpet, Kramdown, CommonMarker)
- OpenGraph metadata extraction with intelligent caching
- Rails and ActionText integration
- Background jobs and cache invalidation
- **DRY architecture:** Centralized extraction patterns, regexes, and cache operations
- Security-focused: output sanitization, dependency pinning, and safe defaults

## Architecture

RichTextExtraction is designed for maintainability and extensibility:
- **Centralized Patterns:** All regexes and extraction logic are in `lib/rich_text_extraction/constants.rb` and `extraction_patterns.rb`.
- **Cache Operations:** All cache logic (Rails and custom) is in `lib/rich_text_extraction/cache_operations.rb`.
- **Instance Helpers:** All instance-level methods use these shared modules.
- **Rails Integration:** Auto-includes helpers and concerns for Rails apps.
- **Specs:** DRY, shared contexts, and verifying doubles.

## Usage

See [`docs/usage.md`](docs/usage.md) and [`docs/quick-reference.md`](docs/quick-reference.md) for full usage examples.

## Contributing

- **Add new patterns or logic** to the shared modules in `lib/rich_text_extraction/constants.rb`, `extraction_patterns.rb`, or `cache_operations.rb`.
- **Mirror the directory structure** in `spec/` for tests.
- **Use shared contexts** for DRY tests (see `spec/support/shared_contexts.rb`).
- **Run tests and RuboCop** before submitting PRs.

## Test & Quality Status (January 2025)
- **RSpec:** 44 examples, 0 failures
- **RuboCop:** No offenses detected
- **YARD:** 90.91% documented
- **Gem build:** No errors

## License
MIT

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

RichTextExtraction is designed for seamless Rails integration:

- **Railtie**: Auto-loads configuration and allows custom options via `Rails.application.config.rich_text_extraction`.
- **Model Concern**: Use `include RichTextExtraction::ExtractsRichText` for automatic cache management.
- **View Helper**: Use `opengraph_preview_for` in your views.
- **Background Job**: Use the provided job template for async link processing.

### Example Usage

**config/initializers/rich_text_extraction.rb**
```ruby
RichTextExtraction.configure do |config|
  config.cache_enabled = true
  config.cache_ttl = 1.hour
end
Rails.application.config.rich_text_extraction.cache_options = { expires_in: 1.hour }
```

**app/models/post.rb**
```ruby
class Post < ApplicationRecord
  include RichTextExtraction::ExtractsRichText
  has_rich_text :content
end
```

**app/views/posts/show.html.erb**
```erb
<%= opengraph_preview_for(@post.content.link_objects(with_opengraph: true).first[:opengraph]) %>
```

**app/jobs/process_links_job.rb**
```ruby
class ProcessLinksJob < ApplicationJob
  def perform(post)
    links = post.content.links
    # ...
  end
end
```

### Troubleshooting
- **Missing ActionText?** Add `has_rich_text :content` to your model and ensure ActionText is installed.
- **Cache not working?** Check your Rails cache store and initializer settings.
- **View helper missing?** Ensure the gem is loaded and you are using ERB or a compatible template engine.
- **Generator not found?** Run `bundle exec rails generate rich_text_extraction:install` and check your Gemfile for the gem entry.

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

**Current Status**: ✅ All tests pass (44 examples, 0 failures)

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

## Test & Quality Status (January 2025)

- **RSpec:** 44 examples, 0 failures
- **RuboCop:** No offenses detected
- **YARD:** 90.91% documented, a few dynamic mixin warnings (expected for Rails mixins)
- **Gem build:** No gemspec self-inclusion error (fixed January 2025)

## Generator Test Organization

Each generated file (initializer, configuration, model, controller, view, job, routes, README) has its own dedicated test in `test/generators/rich_text_extraction/install/`.

- To add a test for a new generator feature, create a new test file in this directory.
- Each test file should focus on a single generated file or feature.
- Run all generator tests with:
  ```sh
  bundle exec rake test
  ```

This structure makes it easy to maintain and extend generator tests as the gem evolves.

## Static Analysis Exclusions

Generator templates in `lib/generators/rich_text_extraction/install/templates/` are excluded from RuboCop and YARD checks because they are ERB templates, not valid Ruby until rendered. This prevents false syntax and style errors in lint and documentation tools.

- See `.rubocop.yml` and `.yardopts` for exclusion rules.

## Universal Extraction API

RichTextExtraction provides a universal extraction API for all document types (plain, Markdown, HTML/ActionText) and elements (links, emails, phones, hashtags, mentions, images, attachments, dates, and more).

### Usage Examples

```ruby
# Extract by type
text = "Contact me at alice@example.com or visit https://example.com #rails @alice"
text.extract(:links)      # => ["https://example.com"]
text.extract(:emails)     # => ["alice@example.com"]
text.extract(:hashtags)   # => ["#rails"]
text.extract(:mentions)   # => ["@alice"]

# Extract all known types
text.extract(:all)
# => { links: [...], emails: [...], phones: [...], hashtags: [...], mentions: [...], ... }

# Extract with a custom pattern
text.extract(/ID-\d{6}/) # => ["ID-123456"]

# In ActionText::RichText
post.content.extract(:links)
```

### Extraction by Type, Element, and Standard

| Type         | Method/Key      | Pattern/Standard      | Example Output                |
|--------------|-----------------|-----------------------|-------------------------------|
| Links        | `:links`        | RFC 3986, Markdown    | `["https://...", ...]`        |
| Emails       | `:emails`       | RFC 5322              | `["foo@bar.com", ...]        |
| Phones       | `:phones`       | E.164                 | `["+1234567890", ...]        |
| Hashtags     | `:hashtags`     | `#\w+`                | `["#rails", ...]             |
| Mentions     | `:mentions`     | `@\w+`                | `[@alice, ...]`               |
| Images       | `:images`       | Markdown/HTML         | `["https://img...", ...]`     |
| Attachments  | `:attachments`  | ActionText            | `[ActiveStorage::Attachment]` |
| Dates        | `:dates`        | ISO 8601, RFC, NLP    | `[Time, ...]`                 |
| Custom       | `:custom_id`    | User regex            | `["ID-123456", ...]          |

### Custom Extractor Registration (DSL)

You can register your own extractors:

```ruby
RichTextExtraction.register_extractor(:custom_id) do |text|
  text.scan(/ID-\d{6}/)
end

"Order ID-123456 and ID-654321".extract(:custom_id)
# => ["ID-123456", "ID-654321"]
```

### Extending Extraction

- Add new extractors for any pattern or document element.
- Use the universal `extract` method on String, ActionText, or directly via `RichTextExtraction.extract`.

### More Built-in Extractors

| Type             | Method/Key         | Pattern/Standard         | Example Output                |
|------------------|--------------------|--------------------------|-------------------------------|
| UUIDs            | `:uuids`           | RFC 4122                 | `["123e4567-e89b-12d3-a456-426614174000"]` |
| Hex Colors       | `:hex_colors`      | CSS                      | `["#fff", "#123abc"]`         |
| IP Addresses     | `:ips`             | IPv4                     | `["192.168.1.1"]`             |
| Credit Cards     | `:credit_cards`    | Luhn (basic)             | `["4111 1111 1111 1111"]`     |
| Markdown Tables  | `:markdown_tables` | Markdown                 | `["| a | b | c | ..."]`        |
| Markdown Code    | `:markdown_code`   | Markdown                 | `["`code`", "```block```"]`    |
| Twitter Handles  | `:twitter_handles` | Twitter                  | `["@alice"]`                  |
| Instagram Handles| `:instagram_handles`| Instagram                | `["@insta.user"]`             |

### Advanced DSL Features

**Post-processing:**
```ruby
RichTextExtraction.register_extractor(:downcase_emails, postprocess: ->(arr) { arr.map(&:downcase) }) do |text|
  text.scan(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/)
end
"Alice@Example.com".extract(:downcase_emails) # => ["alice@example.com"]
```

**Composition:**
```ruby
RichTextExtraction.register_extractor(:emails_in_links, compose: [:links, :emails])
"Contact: https://foo.com?email=alice@example.com".extract(:emails_in_links)
```

### Advanced Use Cases

- **Extract all social handles:**
  ```ruby
  text.extract(:twitter_handles) + text.extract(:instagram_handles)
  ```
- **Extract and normalize all emails:**
  ```ruby
  text.extract(:emails).map(&:downcase).uniq
  ```
- **Extract all code blocks from Markdown:**
  ```ruby
  markdown.extract(:markdown_code)
  ```
- **Extract all UUIDs and validate:**
  ```ruby
  text.extract(:uuids).select { |uuid| uuid.match?(/[0-9a-fA-F\-]{36}/) }
  ```
- **Batch extraction in background jobs:**
  ```ruby
  class ExtractJob < ApplicationJob
    def perform(text)
      results = text.extract(:all)
      # process results...
    end
  end
  ```

## Non-Rails Usage and Cache Compatibility

This gem works in any Ruby environment. Rails is **not required**.

### Example (Plain Ruby, No Rails)

```ruby
require 'rich_text_extraction'
extractor = RichTextExtraction::Extractor.new("Check out https://example.com #ruby @alice")
puts extractor.links      # => ["https://example.com"]
puts extractor.tags       # => ["ruby"]
puts extractor.mentions   # => ["alice"]

# Caching with a hash
cache = {}
RichTextExtraction.extract_opengraph('https://example.com', cache: cache)

# Passing cache: :rails (no Rails loaded) is safe and does nothing
RichTextExtraction.extract_opengraph('https://example.com', cache: :rails)

# Passing an invalid cache object (string, nil, or object without []=) is safe and bypasses caching
RichTextExtraction.extract_opengraph('https://example.com', cache: "not_a_cache")
```

### Cache Behavior Table

| Cache Param      | Rails Present? | Behavior                        |
|------------------|---------------|---------------------------------|
| `nil`            | Any           | No caching                      |
| Ruby Hash        | Any           | Uses the hash for caching       |
| `:rails`         | Yes           | Uses Rails.cache                |
| `:rails`         | No            | No caching, no error            |
| Not hash/rails   | Any           | No caching, no error            |

> **Note:** The gem will attempt to use any cache object you provide (anything that responds to `[]=`), but if an error occurs (e.g., the object is not actually usable as a cache), it will handle the error gracefully and bypass caching. This ensures maximum compatibility and safety in all Ruby environments.

---

If you want to use advanced caching, pass any object that responds to `[]` and `[]=` (e.g., a custom cache, Redis, etc.).

---

**RichTextExtraction** – Professional rich text extraction for Ruby and Rails applications. 🚀