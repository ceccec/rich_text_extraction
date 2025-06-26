---
layout: page
title: Documentation
permalink: /documentation/
---

# RichTextExtraction Documentation

Welcome to the comprehensive documentation for RichTextExtraction, a professional Ruby gem for extracting rich text, Markdown, and OpenGraph metadata in Ruby and Rails applications.

## 🚀 Quick Start

### Installation

Add to your Gemfile:

```ruby
gem 'rich_text_extraction'
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
```

## 🏗️ Modular Architecture

RichTextExtraction features a modern modular architecture designed for maintainability, testability, and extensibility.

### Service Classes

Service classes handle external operations and complex business logic:

#### OpenGraphService

Handles fetching and caching OpenGraph metadata:

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

Extractor modules provide specialized functionality for different content types:

#### LinkExtractor

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
# Global configuration
RichTextExtraction.configure do |config|
  config.opengraph_timeout = 15
  config.sanitize_html = true
  config.default_excerpt_length = 300
  config.default_cache_options = { expires_in: 1.hour }
  config.debug = false
  config.user_agent = 'MyApp/1.0'
end

# Per-instance options (merge with global config)
html = RichTextExtraction.render_markdown(text, sanitize: false)
```

## 📱 Rails Integration

### ActionText Integration

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  include RichTextExtraction::ExtractsRichText
end

# Extract links with OpenGraph data
@post.body.link_objects(with_opengraph: true, cache: :rails)

# Clear cache for all links
@post.clear_rich_text_link_cache
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

## 🔧 Advanced Usage

### Custom Cache Options

```ruby
extractor = RichTextExtraction::Extractor.new("https://example.com")
extractor.link_objects(
  with_opengraph: true, 
  cache: :rails, 
  cache_options: { 
    expires_in: 10.minutes, 
    key_prefix: 'myapp' 
  }
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
  # Handle error gracefully
  Rails.logger.warn "OpenGraph error: #{result.first[:opengraph][:error]}"
end
```

## 🧪 Testing

The test suite is organized by feature for maximum clarity and maintainability:

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/extractor_spec.rb
bundle exec rspec spec/opengraph_helpers_spec.rb
bundle exec rspec spec/advanced_cache_spec.rb
```

### Test Organization

- **Feature-focused files**: Each major module has its own spec file
- **Shared contexts**: Reusable test setup in `spec/support/shared_contexts.rb`
- **Advanced usage**: Split into granular files for complex scenarios
- **Placeholders**: Every module has a placeholder spec for future tests

## 📚 API Documentation

For detailed API reference documentation, see our [API Reference]({{ site.baseurl }}/api-reference/) page. The API documentation is automatically generated from the source code using YARD and includes:

- Complete class and module documentation
- Method signatures and parameters
- Usage examples
- Error handling information

The API docs are updated automatically on every push to the main branch.

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
├── extractors.rb                # Main Extractor class
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

## Deployment

### Deploying to GitHub Pages

1. Push all changes to the `main` branch.
2. In your repository settings, go to **Pages** and set the source to the `/docs` folder on `main`.
3. Visit your site at `https://yourusername.github.io/yourrepo/`.

### Custom Domain

- Add your custom domain in the Pages settings and create a `CNAME` file in `docs/`.
- Update your DNS provider to point to GitHub Pages.
- Enable **Enforce HTTPS** in the Pages settings.

### Continuous Deployment & PWA Audits

- Every push to `main` triggers a GitHub Actions workflow that runs a Lighthouse PWA audit.
- The audit report is available in the Actions tab as an artifact.

### Testing & Verification

- See [testing.md](testing.md) for a full checklist and troubleshooting guide.

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀 