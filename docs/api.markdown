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

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀 