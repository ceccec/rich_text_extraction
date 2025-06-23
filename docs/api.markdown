---
layout: api
title: API Reference
permalink: /api-reference/
---

# API Reference

Welcome to the RichTextExtraction API documentation. This documentation is automatically generated from the source code using YARD.

## Quick Navigation

- **[RichTextExtraction]({{ site.baseurl }}/api/classes/RichTextExtraction.html)** - Main module with version and configuration
- **[Extractor]({{ site.baseurl }}/api/classes/RichTextExtraction/Extractor.html)** - Core extraction functionality for links, tags, and mentions
- **[Helpers]({{ site.baseurl }}/api/classes/RichTextExtraction/Helpers.html)** - View helpers for rendering OpenGraph previews
- **[ExtractsRichText]({{ site.baseurl }}/api/classes/RichTextExtraction/ExtractsRichText.html)** - Rails concern for ActionText integration
- **[Error]({{ site.baseurl }}/api/classes/RichTextExtraction/Error.html)** - Error handling classes
- **[Railtie]({{ site.baseurl }}/api/classes/RichTextExtraction/Railtie.html)** - Rails integration and configuration

## Getting Started

The main entry point is the `RichTextExtraction` module. For basic usage, see the [Extractor]({{ site.baseurl }}/api/classes/RichTextExtraction/Extractor.html) class.

For Rails integration, check out the [ExtractsRichText]({{ site.baseurl }}/api/classes/RichTextExtraction/ExtractsRichText.html) concern and [Helpers]({{ site.baseurl }}/api/classes/RichTextExtraction/Helpers.html) module.

## Documentation Coverage

This documentation is automatically generated and updated on every push to the main branch. The current coverage is **75.93%** documented.

For more information about contributing and improving documentation, see our [Contributing Guide]({{ site.baseurl }}/contributing/).

## Main Classes & Modules

### `RichTextExtraction::Extractor`

- `initialize(text : String)` — Create an extractor for a string
- `links() : Array<String>` — Extract all URLs
- `tags() : Array<String>` — Extract all tags (without #)
- `mentions() : Array<String>` — Extract all mentions (without @)
- `emails() : Array<String>` — Extract all emails
- `phone_numbers() : Array<String>` — Extract all phone numbers
- `dates() : Array<String>` — Extract all dates
- `link_objects(with_opengraph: false, cache: nil, cache_options: {}) : Array<Hash>` — Array of hashes for each link, with optional OpenGraph data
- `clear_link_cache(cache: nil, cache_options: {})` — Clear OpenGraph cache for all links

### `RichTextExtraction.render_markdown(text : String) : String`
- Render Markdown to HTML (safe, sanitized)

### `RichTextExtraction.opengraph_preview(og_data : Hash, format: :html|:markdown|:text) : String`
- Render OpenGraph data as HTML, Markdown, or text preview

## Rails/ActionText Integration
- `ActionText::RichText#links`, `#tags`, `#mentions`, etc. — Extraction methods available on rich text
- `opengraph_preview_for(url_or_og_data, format: :html|:markdown|:text)` — Rails view helper for OpenGraph previews
- Model concern: `RichTextExtraction::ExtractsRichText` — Automatic cache management

## Background Jobs
- Prefetch OpenGraph data for all posts:

```ruby
class PrefetchOpenGraphJob < ApplicationJob
  queue_as :default
  def perform(post_id)
    post = Post.find(post_id)
    post.body.link_objects(with_opengraph: true, cache: :rails)
  end
end
```

## See Also
- [Full README & Guides](https://github.com/ceccec/rich_text_extraction#readme)
- [Getting Started Guide]({{ site.baseurl }}/blog/2024-06-24-getting-started.html)
- [How to Add Link Previews]({{ site.baseurl }}/blog/2024-06-24-link-previews.html)
- [Advanced Usage]({{ site.baseurl }}/blog/2024-06-24-advanced-usage.html)
- [Features]({{ site.baseurl }}/features/) 