---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
title: RichTextExtraction: Ruby & Rails Gem for Rich Text, Markdown, and OpenGraph Extraction
description: Extract links, tags, mentions, emails, phone numbers, and OpenGraph metadata from rich text, Markdown, or ActionText in Ruby and Rails. Safe Markdown rendering, link previews, and structured data extraction.
---

# RichTextExtraction

> The all-in-one Ruby & Rails gem for rich text extraction, Markdown rendering, and OpenGraph link previews.

![Screenshot or GIF coming soon](assets/screenshot-placeholder.png)

## Features
- Extract links, tags, mentions, emails, phone numbers, dates, Twitter handles, and OpenGraph metadata
- Safe Markdown rendering (Redcarpet, Kramdown, CommonMarker)
- ActionText & Rails integration for link preview and structured data
- Background job support for prefetching/caching link metadata
- Highly customizable and extendable

## Quick Start

```ruby
gem 'rich_text_extraction', github: 'ceccec/rich_text_extraction'
```

```bash
bundle install
```

## Usage Example

```ruby
require 'rich_text_extraction'

body = "Hello @alice! Check out https://example.com #welcome"
extractor = RichTextExtraction::Extractor.new(body)
extractor.link_objects(with_opengraph: true)
# => [{ url: "https://example.com", opengraph: { "title" => "Example Domain", ... } }]
```

## More Examples & Documentation
See the [README](https://github.com/ceccec/rich_text_extraction#readme) for full documentation, advanced usage, and Rails/ActionText integration.

## Blog & Guides
- [Getting Started with RichTextExtraction](./blog/2024-06-24-getting-started.html) (coming soon)
- [How to Add Link Previews to Rails with ActionText](./blog/2024-06-24-link-previews.html) (coming soon)

---

*Want to contribute a guide or showcase your use case? [Open an issue or PR!](https://github.com/ceccec/rich_text_extraction/issues)*
