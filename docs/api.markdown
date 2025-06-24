---
layout: page
title: "API Reference"
permalink: /api.html
---

# API Reference

This page provides a comprehensive reference for all RichTextExtraction classes, methods, and configuration options.

## 📚 Quick Navigation

- **[Class List]({{ site.baseurl }}/api/class_list.html)** - All classes and modules
- **[Method List]({{ site.baseurl }}/api/method_list.html)** - All public methods
- **[File List]({{ site.baseurl }}/api/file_list.html)** - All source files

## 🏗️ Core Classes

### RichTextExtraction::Extractor

The main class for extracting content from text.

```ruby
extractor = RichTextExtraction::Extractor.new("Visit https://example.com and check out #ruby")
```

**Key Methods:**
- `#links` - Extract URLs
- `#tags` - Extract hashtags
- `#mentions` - Extract mentions
- `#link_objects` - Get rich link objects with OpenGraph data

### RichTextExtraction::OpenGraphService

Service for fetching and caching OpenGraph metadata.

```ruby
og_service = RichTextExtraction::OpenGraphService.new
metadata = og_service.extract('https://example.com')
```

**Key Methods:**
- `#extract(url, options = {})` - Extract OpenGraph data
- `#clear_cache(url, options = {})` - Clear cached data

### RichTextExtraction::MarkdownService

Service for rendering Markdown to HTML.

```ruby
md_service = RichTextExtraction::MarkdownService.new
html = md_service.render('**Bold text**')
```

**Key Methods:**
- `#render(text, options = {})` - Render Markdown to HTML

## 🔧 Configuration

### Global Configuration

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

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `cache_enabled` | Boolean | `true` | Enable/disable caching |
| `cache_prefix` | String | `'rte'` | Cache key prefix |
| `cache_ttl` | Duration | `1.hour` | Cache time-to-live |
| `opengraph_timeout` | Duration | `5.seconds` | OpenGraph request timeout |
| `opengraph_user_agent` | String | `'RichTextExtraction/1.0'` | User agent for requests |
| `markdown_renderer` | Symbol | `:redcarpet` | Markdown renderer to use |
| `markdown_options` | Hash | `{}` | Markdown renderer options |

## 📖 Guides and Tutorials

- [Getting Started Guide]({{ site.baseurl }}/blog/2025-06-24-getting-started.html)
- [How to Add Link Previews]({{ site.baseurl }}/blog/2025-06-24-link-previews.html)
- [Advanced Usage]({{ site.baseurl }}/blog/2025-06-24-advanced-usage.html)

## 🔗 External Links

- **[GitHub Repository](https://github.com/ceccec/rich_text_extraction)** - Source code and issues
- **[RubyGems](https://rubygems.org/gems/rich_text_extraction)** - Gem installation
- **[Documentation Site](https://ceccec.github.io/rich_text_extraction/)** - Full documentation

## Validators API

- [Validator Reference](validator_reference.md)

# For each endpoint, add a note like:
# See also: [validator reference](validator_reference.md#isbn) (for /validators/isbn/validate)

## Doc-Driven Testing & API Consistency

All validator API endpoints and their test scenarios are **automatically tested and kept in sync with documentation**. This is achieved through a doc-driven, DRY workflow:

- **Single Source of Truth:** All validator logic, examples, and metadata are defined in `VALIDATOR_EXAMPLES` in the codebase.
- **Automated Test Generation:**
  - The script [`bin/doc_driven_validator_spec.rb`](../bin/doc_driven_validator_spec.rb) reads all valid/invalid examples from the documentation source and runs them as tests against the actual validator classes.
  - If a validator is missing, a stub is auto-generated (for regex-based types), or a clear error is reported for custom logic types.
- **Drift/Gap Detection:**
  - If any validator is missing, or if the docs, code, and tests are out of sync, a warning banner appears in the generated documentation and the CI build will fail.
- **Rake Tasks:**
  - `rake test:scenarios_from_docs` — Runs all doc-driven validator tests.
  - `rake docs:all` — Regenerates documentation and drift warnings.
  - `rake` or `rake test` — Runs all quality checks and tests.

### Example Workflow

1. Add or update a validator in `VALIDATOR_EXAMPLES`.
2. Run `rake docs:all` and `rake test:scenarios_from_docs`.
3. All API scenarios (valid/invalid) are tested automatically.
4. If anything is missing or out of sync, you'll see a warning in the docs and a failed CI build.

**This ensures the API, documentation, and tests are always DRY, robust, and in sync.**

## 🧪 API Testing Scenarios: What's Automatically Tested

All validator API endpoints are covered by **doc-driven, automated tests**. The following scenarios are (or should be) executed for every validator, ensuring the API, documentation, and implementation are always in sync and robust.

### 1. Metadata Endpoints

- **GET `/validators`**
  - Returns a list of all validators with their metadata.
  - **Test:** Response includes all symbols in `VALIDATOR_EXAMPLES` and all requested fields.

- **GET `/validators/fields`**
  - Returns a list of all available metadata fields.
  - **Test:** Response matches the documented fields.

- **GET `/validators/:id`**
  - Returns metadata for a specific validator.
  - **Test:** Response matches the entry in `VALIDATOR_EXAMPLES` for the given symbol.
  - **Test:** Returns 404 for unknown validator.

- **GET `/validators/:id/regex`**
  - Returns the regex for a validator (if applicable).
  - **Test:** Response matches the regex in `VALIDATOR_EXAMPLES`.
  - **Test:** Returns 404 for unknown validator.

- **GET `/validators/:id/examples`**
  - Returns valid and invalid examples for a validator.
  - **Test:** Response matches the examples in `VALIDATOR_EXAMPLES`.
  - **Test:** Returns 404 for unknown validator.

- **GET `/validators/:id/jsonld?value=...`**
  - Returns schema.org JSON-LD for a value.
  - **Test:** Response matches the schema_type and schema_property in `VALIDATOR_EXAMPLES`.
  - **Test:** Returns 404 for unknown validator.

---

### 2. Validation Endpoints

- **POST `/validators/:id/validate`**
  - Validates a single value.
  - **Test:** For each `valid` example in `VALIDATOR_EXAMPLES`, the response is `{ valid: true, errors: [] }`.
  - **Test:** For each `invalid` example, the response is `{ valid: false, errors: [...] }`.
  - **Test:** Returns 404 for unknown validator.
  - **Test:** Returns error for missing or malformed input.

- **POST `/validators/:id/batch_validate`**
  - Validates an array of values.
  - **Test:** For each value, response matches the single validate endpoint.
  - **Test:** Returns 404 for unknown validator.
  - **Test:** Returns error for missing or malformed input.

---

### 3. Error Handling & Edge Cases

- **Unknown Validator**
  - All endpoints return 404 and a clear error message if the validator does not exist.

- **Malformed Input**
  - Validation endpoints return a clear error if required fields are missing or input is not a string/array as expected.

- **Rate Limiting**
  - Exceeding the configured rate limit returns a 429 error with a clear message.

- **CORS**
  - All endpoints respond with correct CORS headers for allowed origins, methods, and headers.

---

### 4. Security & Sanitation

- **No Arbitrary Code Execution**
  - Only documented, whitelisted scenarios are tested.
  - No `eval` or dynamic code execution is allowed.

- **Strict Input Validation**
  - Only values and types documented in `VALIDATOR_EXAMPLES` are accepted for automated tests.

---

### 5. Drift & Coverage Detection

- **Drift Detection**
  - If any validator is missing a class or regex, or if docs/tests/code are out of sync, a warning is shown in the docs and CI fails.

- **Coverage Reporting**
  - After running tests, a summary is printed listing any missing or untested features.

---

### 6. Extensibility

- **Adding New Scenarios**
  - To add a new test scenario, simply add it to the `valid` or `invalid` array in `VALIDATOR_EXAMPLES`. The system will automatically test it and update the docs.

---

## Example Table: Test Scenarios for a Validator

| Input                | Expected Result | Example API Request         | Example API Response                |
|----------------------|----------------|----------------------------|-------------------------------------|
| `978-3-16-148410-0`  | ✅ valid       | `{ "value": "978-3-16-148410-0" }` | `{ "valid": true, "errors": [] }` |
| `978-3-16-148410-1`  | ❌ invalid     | `{ "value": "978-3-16-148410-1" }` | `{ "valid": false, "errors": ["is not a valid ISBN"] }` |

---

## How to Run All Tests

- `rake test:scenarios_from_docs` — Runs all doc-driven validator tests.
- `rake` or `rake test` — Runs all quality checks and tests.
- See the [Contributing Guide](CONTRIBUTING.md) for more details.

**This approach ensures that every documented scenario is tested, every API endpoint is robust, and the system is always DRY, secure, and in sync.**

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀 

## ⚡ Request→Response Caching

All validation requests (both via the public API and the HTTP API) support request→response caching to reduce system load and improve performance.

- **How it works:**
  - Every validation request (symbol + value) is cached using a configurable cache (defaults to `Rails.cache`).
  - Cache keys are based on the validator symbol and value.
  - Cache options (e.g., `expires_in`) are configurable via Rails/RichTextExtraction config or per-request.

### **API Controller**
- All `/validators/:id/validate` and `/validators/:id/batch_validate` requests are cached by default using `Rails.cache` and your configured cache options.
- You can configure cache TTL and other options in your initializer:
  ```ruby
  # config/initializers/rich_text_extraction.rb
  RichTextExtraction.configure do |config|
    config.cache_options = { expires_in: 1.hour, compress: true }
  end
  ```

### **Public API Usage**
- You can use caching in your own scripts:
  ```ruby
  # Use Rails.cache (default)
  RichTextExtraction::ValidatorAPI.validate(:isbn, "978-3-16-148410-0")

  # Use a custom cache and options
  require 'active_support/cache'
  cache = ActiveSupport::Cache::MemoryStore.new
  RichTextExtraction::ValidatorAPI.validate(:isbn, "978-3-16-148410-0", cache: cache, cache_options: { expires_in: 600 })
  ```
- The result will be cached and reused for identical requests, reducing repeated computation.

### **Benefits**
- Reduces system load for repeated or batch validations.
- Makes the API and public methods more scalable and responsive.
- Fully user-configurable and works out of the box with Rails. 