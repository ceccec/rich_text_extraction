# Rich Text Extraction

## Mission Statement

**Rich Text Extraction** is a universal, DRY, documentation-driven, cache-optimized validation and extraction platform. Our mission is to empower developers and organizations to build robust, accessible, and future-proof applications by providing a single source of truth for validation, documentation, testing, and UI—across all interfaces and languages.

## Main Features

- **Single Source of Truth:**
  - All validation logic, patterns, examples, ARIA labels, and content are defined in YAML/JSON, ensuring DRYness and consistency across code, docs, and tests.
- **Doc-Driven Testing & Automation:**
  - Test scenarios, API docs, and UI are auto-generated from documentation, with CI enforcing drift/gap detection.
- **Universal API & Multi-Interface Support:**
  - Exposes all validation, batch validation, metadata, and examples via HTTP, JS, CLI, and Ruby APIs.
- **Interactive, Responsive PWA UI:**
  - Modern, installable, offline-capable UI with live validation, batch validation, and dynamic docs.
- **Accessibility & Internationalization:**
  - All UI is accessible, ARIA-compliant, and fully i18n-ready, with translations and a11y labels managed centrally.
- **Security & Privacy:**
  - Strict Content Security Policy, input sanitation, HTTPS, and privacy-respecting analytics with opt-out.
- **Automated CI/CD & Quality Gates:**
  - Linting, spellcheck, accessibility, SEO, visual regression, and scenario coverage are enforced in CI.
- **Extensible & Future-Proof:**
  - Easily add new validators, scenarios, languages, or UI features by updating a single YAML/JSON file.
- **Self-Documenting:**
  - Every feature, test, and doc references its own source, ensuring transparency and maintainability.

---

For full documentation, see the [docs/](docs/) directory and the in-app interactive documentation.

# RichTextExtraction

[![Tests](https://github.com/ceccec/rich_text_extraction/actions/workflows/main.yml/badge.svg)](https://github.com/ceccec/rich_text_extraction/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/rich_text_extraction.svg)](https://badge.fury.io/rb/rich_text_extraction)
[![Documentation](https://img.shields.io/badge/docs-YARD-blue.svg)](https://ceccec.github.io/rich_text_extraction/)

Professional rich text, Markdown, and OpenGraph extraction for Ruby and Rails applications.

## Features
- Extract links, tags, mentions, emails, attachments, phone numbers, and more
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

## How to Add or Update a Validator (DRY, Doc-Driven)

RichTextExtraction is fully DRY and doc-driven. To add or update a validator:

1. **Edit `VALIDATOR_EXAMPLES` in `lib/rich_text_extraction/constants.rb`:**
   - Add or update the validator entry with its name, description, regex (if pattern-based), valid/invalid examples, and schema.org metadata.
2. **Input Normalization:**
   - All validator input is automatically normalized: values are converted to string and whitespace is stripped before validation. This ensures consistent, user-friendly validation across all interfaces.
3. **(If needed) Add a custom validator class:**
   - For custom logic (not regex-based), add a validator class in `lib/rich_text_extraction/validators/`.
4. **Everything else is automatic!**
   - Tests, documentation, and API endpoints are auto-generated from `VALIDATOR_EXAMPLES`.
   - Run the doc-driven test runner and documentation generator to ensure everything is in sync.

**Tip:** If you see a drift warning in the docs or CI, it means a validator is missing a class or regex. Just update `VALIDATOR_EXAMPLES` and the relevant class or pattern.

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

## Standards-Based Document Extraction (DRY Approach)

`rich_text_extraction` can extract links, tags, mentions, and more from a variety of document standards, using a unified API.

### Supported Formats

| Format         | Standard         | Ruby Gem Needed      | Example Extraction Approach         |
|----------------|------------------|----------------------|-------------------------------------|
| Plain Text     | -                | None                 | Use directly                        |
| HTML           | W3C HTML5        | Nokogiri             | Extract text, then use extractor    |
| Markdown       | CommonMark       | None                 | Use directly                        |
| DOCX           | ISO/IEC 29500    | `docx`               | Extract text, then use extractor    |
| ODT            | ISO/IEC 26300    | `odf-report`/`odf`   | Extract text, then use extractor    |
| PDF            | ISO 32000        | `pdf-reader`         | Extract text, then use extractor    |

### DRY Example

```ruby
require 'rich_text_extraction'

def extract_from_text(text)
  extractor = RichTextExtraction::Extractor.new(text)
  {
    links: extractor.links,
    tags: extractor.tags,
    mentions: extractor.mentions
  }
end

# DOCX
require 'docx'
doc = Docx::Document.open('example.docx')
text = doc.paragraphs.map(&:text).join("\n")
puts extract_from_text(text)

# PDF
require 'pdf-reader'
reader = PDF::Reader.new('example.pdf')
text = reader.pages.map(&:text).join("\n")
puts extract_from_text(text)

# HTML
require 'nokogiri'
html = File.read('example.html')
text = Nokogiri::HTML(html).text
puts extract_from_text(text)

# ODT (if using odf-report or odf gem)
# ...similar approach...
```

---

## Unified DRY Extraction API

You can extract links, tags, mentions, and more from any supported file format with a single method:

```ruby
result = RichTextExtraction.extract_from_file('path/to/file')
puts result[:links]
puts result[:tags]
puts result[:mentions]
```

### Supported Formats

| Format     | Extension(s)      | Ruby Gem Needed      |
|------------|-------------------|----------------------|
| Plain Text | .txt, (none)      | None                 |
| Markdown   | .md               | None                 |
| HTML       | .html, .htm       | nokogiri             |
| DOCX       | .docx             | docx                 |
| PDF        | .pdf              | pdf-reader           |
| CSV/TSV    | .csv, .tsv        | csv                  |
| JSON       | .json             | json                 |
| ODT        | .odt              | odf-report           |
| EPUB       | .epub             | epub-parser          |
| RTF        | .rtf              | rtf                  |
| XLSX       | .xlsx             | roo                  |
| PPTX       | .pptx             | roo                  |
| XML        | .xml              | nokogiri             |
| YAML       | .yml, .yaml       | yaml                 |
| LaTeX      | .tex              | None                 |

More formats can be added easily by extending the `extract_from_file` method.

---

## Identifier and Code Extraction

You can extract barcodes, UUIDs, credit cards, hex colors, IPs, and more:

```ruby
extractor = RichTextExtraction::Extractor.new("EAN: 9781234567897, UUID: 123e4567-e89b-12d3-a456-426614174000, Card: 4111 1111 1111 1111, Color: #fff, IP: 192.168.1.1")
puts extractor.extract(:ean13)        # => ["9781234567897"]
puts extractor.extract(:uuid)         # => ["123e4567-e89b-12d3-a456-426614174000"]
puts extractor.extract(:credit_cards) # => ["4111 1111 1111 1111"]
puts extractor.extract(:hex_colors)   # => ["#fff"]
puts extractor.extract(:ips)          # => ["192.168.1.1"]
```

### Supported Identifiers

- EAN-13 barcodes (`:ean13`)
- UPC-A barcodes (`:upca`)
- ISBN-10/13 (`:isbn`)
- UUID/GUID (`:uuid`)
- Credit card numbers (`:credit_cards`)
- Hex colors (`:hex_colors`)
- IP addresses (`:ips`)

Add your own by registering a custom extractor!

### More Supported Identifiers

- VIN (`:vin`, with check digit validation)
- IMEI (`:imei`, with Luhn validation)
- ISSN (`:issn`, with checksum validation)
- MAC address (`:mac`)
- IBAN (`:iban`)

Validation is improved for credit cards, ISBN, IMEI, VIN, ISSN, and IBAN (official mod-97 check).

#### Example: IBAN Validation

```ruby
extractor = RichTextExtraction::Extractor.new("Valid: GB82WEST12345698765432 Invalid: GB82WEST12345698765431")
puts extractor.extract(:iban) # => ["GB82WEST12345698765432"]
```

### Validation Details

| Identifier   | Validation Type         | Notes/Standard                |
|--------------|------------------------|-------------------------------|
| EAN-13       | Pattern only            | No checksum                   |
| UPC-A        | Pattern only            | No checksum                   |
| ISBN         | Checksum (10/13)        | ISO 2108                      |
| UUID         | Pattern only            | RFC 4122                      |
| Credit Card  | Luhn algorithm          | ISO/IEC 7812                  |
| Hex Color    | Pattern only            | CSS spec                      |
| IP Address   | Pattern only            | IPv4 only                     |
| VIN          | Check digit (ISO 3779)  | 9th char, mod-11              |
| IMEI         | Luhn algorithm          | 3GPP TS 23.003                |
| ISSN         | Checksum (mod-11)       | ISO 3297                      |
| MAC Address  | Pattern only            | Colon or dash separated       |
| IBAN         | Mod-97 (official)       | ISO 13616                     |

- **Pattern only**: Only the format is checked (length, allowed chars).
- **Checksum/Luhn/Mod-97**: The code is mathematically validated.
- **Standard**: The relevant international standard.

#### Example: Credit Card Validation

```ruby
extractor = RichTextExtraction::Extractor.new("Valid: 4111 1111 1111 1111 Invalid: 4111 1111 1111 1112")
puts extractor.extract(:credit_cards) # => ["4111 1111 1111 1111"]
```

#### Example: ISBN Validation

```ruby
extractor = RichTextExtraction::Extractor.new("Valid: 978-3-16-148410-0 Invalid: 978-3-16-148410-1")
puts extractor.extract(:isbn) # => ["978-3-16-148410-0"]
```

#### Example: VIN Validation

```ruby
extractor = RichTextExtraction::Extractor.new("Valid: 1HGCM82633A004352 Invalid: 1HGCM82633A004353")
puts extractor.extract(:vin) # => ["1HGCM82633A004352"]
```

---

## Rails Model Integration

All extractors are available as ActiveModel/ActiveRecord validators. Just add them to your model:

```ruby
class Book < ApplicationRecord
  validates :isbn, isbn: true
  validates :vin, vin: true
  validates :issn, issn: true
  validates :iban, iban: true
  validates :credit_card, luhn: true
  validates :ean, ean13: true
  validates :upc, upca: true
  validates :uuid, uuid: true
  validates :imei, luhn: true
  validates :mac, mac_address: true
  validates :color, hex_color: true
  validates :ip, ip: true
  validates :hashtag, hashtag: true
  validates :mention, mention: true
  validates :twitter, twitter_handle: true
  validates :instagram, instagram_handle: true
  validates :website, url: true
end
```

- No extra setup is needed—just require the gem in your Rails app.
- All validators are available automatically.
- See `spec/integration/rails_model_validators_spec.rb` for a working integration test.

### Advanced Validator Usage

- **Custom error message:**
  ```ruby
  validates :isbn, isbn: { message: 'must be a valid ISBN-10 or ISBN-13' }
  ```
- **Conditional validation:**
  ```ruby
  validates :vin, vin: true, if: -> { vin.present? }
  ```
- **Multiple fields:**
  ```ruby
  validates :primary_email, :secondary_email, email: true, allow_blank: true
  ```
- **Custom validator with validates_with:**
  ```ruby
  class CustomValidator < ActiveModel::Validator
    def validate(record)
      record.errors.add(:base, 'Custom error') unless record.isbn.present? || record.vin.present?
    end
  end
  validates_with CustomValidator
  ```

## Generator Support

You can generate an example model with all validator usages:

```sh
bin/rails generate rich_text_extraction:install
```

See `lib/generators/rich_text_extraction/install/templates/example_model.rb` for a full example.

## Internationalization (I18n) for Validator Error Messages

You can override all validator error messages using Rails I18n. Add a file like `config/locales/rich_text_extraction.en.yml`:

```yaml
en:
  errors:
    messages:
      isbn: "is not a valid ISBN"
      vin: "is not a valid VIN"
      issn: "is not a valid ISSN"
      iban: "is not a valid IBAN"
      luhn: "is not a valid number (Luhn check failed)"
      ean13: "is not a valid EAN-13 barcode"
      upca: "is not a valid UPC-A barcode"
      uuid: "is not a valid UUID"
      hex_color: "is not a valid hex color"
      ip: "is not a valid IPv4 address"
      mac_address: "is not a valid MAC address"
      hashtag: "is not a valid hashtag"
      mention: "is not a valid mention"
      twitter_handle: "is not a valid Twitter handle"
      instagram_handle: "is not a valid Instagram handle"
      url: "is not a valid URL"
```

Rails will use these messages automatically if present.

---

## Custom Validator Classes

You can create your own custom validators using the gem's logic:

```ruby
class MyCustomValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless RichTextExtraction::Extractors::Validators.valid_isbn?(value) || RichTextExtraction::Extractors::Validators.valid_vin?(value)
      record.errors.add(attribute, options[:message] || 'must be a valid ISBN or VIN')
    end
  end
end

class Book < ApplicationRecord
  validates :code, my_custom: true
end
```

---

## Generator Options

You can extend the generator to create custom model or validator templates. For example, you can add your own templates to `lib/generators/rich_text_extraction/install/templates/` and modify the generator to use them.

To generate the example model with all validator usages:

```sh
bin/rails generate rich_text_extraction:install
```

See the example model template for advanced usage and customization.

## Configurable API Features

### CORS
- Configure allowed origins, headers, and methods:

```ruby
config.api_cors_origins = ['https://myfrontend.com', 'https://admin.myapp.com']
config.api_cors_headers = ['Origin', 'Content-Type', 'Accept', 'Authorization', 'X-Custom-Header']
config.api_cors_methods = ['GET', 'POST', 'OPTIONS', 'PUT']
```

### Distributed Rate Limiting (with Redis)
- Configure global, per-user, and per-endpoint limits:

```ruby
config.api_rate_limit = { limit: 60, period: 1.minute }
config.api_rate_limit_per_user = { limit: 100, period: 1.hour }
config.api_rate_limit_per_endpoint = {
  '/validators/validate' => { limit: 10, period: 1.minute }
}
```
- Requires Redis. In production, use a shared Redis instance.

### Example Initializer

```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  config.api_cors_origins = ['https://myfrontend.com']
  config.api_cors_headers = ['Origin', 'Content-Type', 'Accept']
  config.api_cors_methods = ['GET', 'POST', 'OPTIONS']
  config.api_rate_limit = { limit: 60, period: 1.minute }
  config.api_rate_limit_per_user = { limit: 100, period: 1.hour }
  config.api_rate_limit_per_endpoint = {
    '/validators/validate' => { limit: 10, period: 1.minute }
  }
end
```

### Notes
- CORS and rate limiting are enforced on all validator API endpoints.
- Per-user limits require a `current_user` method in your controller.
- For distributed rate limiting, ensure Redis is available and configured.

## DRY Metaprogramming for Extractors & Validators

RichTextExtraction now uses metaprogramming to automatically generate extraction methods and validator classes for all pattern-based types. This means:

- **No need to manually define extractors or validator classes** for simple regex-based types (e.g., UUID, MAC address, hashtag, mention, etc.).
- **Custom logic types** (e.g., ISBN, VIN, ISSN, IBAN, Luhn, URL) are still implemented manually to preserve their advanced validation.
- **Error messages** for pattern-based validators are centralized in `VALIDATOR_EXAMPLES` and can be overridden via I18n as before.
- **Automatic registration**: All generated extractors are available in the extractor registry and API.

### Adding a New Pattern-Based Extractor/Validator

1. Add an entry to `VALIDATOR_EXAMPLES` in `lib/rich_text_extraction/constants.rb` with:
   - `regex`: The name of the regex constant in `ExtractionPatterns` (as a string)
   - `error_message`: The default error message
   - (Optionally) `valid`, `invalid`, `schema_type`, etc.
2. That's it! The extractor and validator will be available automatically.
3. If you need custom logic (e.g., checksum), implement the extractor/validator manually and add the key to the skip list in the metaprogramming block.

### Example: Adding a New Validator

```ruby
# In lib/rich_text_extraction/constants.rb
VALIDATOR_EXAMPLES[:foo_code] = {
  valid: ['FOO123'],
  invalid: ['BAR456'],
  regex: 'FOO_CODE_REGEX',
  error_message: 'is not a valid FOO code',
  schema_type: 'Thing',
  schema_property: 'identifier',
  description: 'FOO code (custom example)'
}

# In lib/rich_text_extraction/extraction_patterns.rb
FOO_CODE_REGEX = /FOO\d{3}/
```

Now you can use:

```ruby
extract_foo_codes('My code is FOO123') # => ['FOO123']
validates :foo, foo_code: true
```

### Custom Logic Validators

For types like ISBN, VIN, ISSN, IBAN, Luhn, and URL, custom logic is preserved. These are not auto-generated and must be implemented manually as before.

---

## DRY Documentation for Validators & Extractors

All validator and extractor documentation in RichTextExtraction is DRY and auto-generated from the `VALIDATOR_EXAMPLES` hash in `lib/rich_text_extraction/constants.rb`.

- **Consistency:** The same source powers the code, API, and documentation.
- **Easy to extend:** To add a new validator or extractor, just update the hash and (optionally) add a regex. The docs, API, and code will all reflect the change automatically.
- **No duplication:** There is no need to manually update multiple places when adding or changing a validator/extractor.

This approach ensures that your documentation is always up-to-date and matches the actual code and API behavior.

## Doc-Driven Testing

Validator specs are automatically generated from the `VALIDATOR_EXAMPLES` hash. This means:

- All valid/invalid examples in the documentation are tested against the actual validator classes.
- To run these tests, use:

```sh
rake test:scenarios_from_docs
```

This ensures your code, documentation, and tests are always DRY and in sync.

## Universal Caching Proxy & Multi-Interface Validation

All validation requests—whether from Ruby, HTTP, or JavaScript—are automatically cached for maximum efficiency and scalability.

- **Ruby:**
  ```ruby
  RichTextExtraction::ValidatorAPI.validate(:isbn, value, cache: Rails.cache, cache_options: { expires_in: 1.hour })
  RichTextExtraction::ValidatorAPI.batch_validate(:isbn, ["978-3-16-148410-0", "123"], cache: Rails.cache)
  ```

- **HTTP API:**
  All `/validate` and `/batch_validate` endpoints use server-side cache.
  ```http
  POST /validators/isbn/validate
  { "value": "978-3-16-148410-0" }
  
  POST /validators/isbn/batch_validate
  { "values": ["978-3-16-148410-0", "123"] }
  ```

- **JavaScript (Docs/Widget):**
  Docs widgets and apps fetch from the API and cache results in the browser. See the live demo in the docs.

- **CLI/Batch:**
  Scripts and pipelines can use the same API and cache for efficient batch validation.

**Configure cache backend and options in your initializer:**
```ruby
RichTextExtraction.configure do |config|
  config.cache_options = { expires_in: 1.hour, compress: true }
end
```

**Adding a new validator or scenario in `VALIDATOR_EXAMPLES` makes it available everywhere (Ruby, API, JS, CLI) with caching.**

## 🚦 Getting Started (Onboarding)

1. **Install dependencies and generate docs/tests:**
   ```sh
   bin/setup
   ```
2. **Run tests:**
   ```sh
   bundle exec rspec
   ```
3. **Edit only YAML/JSON or constants** (e.g., `lib/rich_text_extraction/constants.rb`, `docs/_data/test_scenarios.yml`).
   - Do **not** edit generated files directly.
   - After changes, re-run `bin/setup` to update docs/tests.
4. **Health check:**
   - Visit [http://localhost:3000/health](http://localhost:3000/health) to verify the app is running.
5. **OpenAPI spec for self-updating UI:**
   - Visit [http://localhost:3000/openapi.json](http://localhost:3000/openapi.json) for the latest API schema.
6. **Error reporting:**
   - Set the `SENTRY_DSN` environment variable to enable Sentry error reporting.
7. **Automate minimalism and deployment readiness:**
   - Run the full swallow procedure with:
     ```sh
     bin/swallow
     ```
   - This script installs dependencies, generates docs/tests, runs tests, checks health and OpenAPI endpoints, and ensures the app is always minimal and self-sufficient.