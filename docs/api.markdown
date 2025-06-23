---
layout: page
title: API Reference
permalink: /api/
---

# API Reference

## Main Classes & Modules

### `RichTextExtraction::Extractor`
- `.new(text)` — Create an extractor for a string
- `#links` — Array of URLs
- `#tags` — Array of tags
- `#mentions` — Array of mentions
- `#emails` — Array of emails
- `#phone_numbers` — Array of phone numbers
- `#dates` — Array of dates
- `#link_objects(with_opengraph: false, cache: nil, cache_options: {})` — Array of hashes for each link, with optional OpenGraph data
- `#clear_link_cache` — Clear OpenGraph cache for all links

### `RichTextExtraction.render_markdown(text)`
- Render Markdown to HTML (safe, sanitized)

### `RichTextExtraction.opengraph_preview(og_data, format: :html)`
- Render OpenGraph data as HTML, Markdown, or text preview

### Rails/ActionText Integration
- `ActionText::RichText#links`, `#tags`, `#mentions`, etc.
- `opengraph_preview_for` Rails view helper
- Model concern: `RichTextExtraction::ExtractsRichText`

## See Also
- [Full README & Guides](https://github.com/ceccec/rich_text_extraction#readme)
- [Getting Started Guide]({{ site.baseurl }}/blog/2024-06-24-getting-started.html)
- [Features]({{ site.baseurl }}/features/) 