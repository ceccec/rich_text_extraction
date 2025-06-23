---
layout: page
title: API Reference
permalink: /api/
---

# API Reference

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