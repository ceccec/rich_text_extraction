# RichTextExtraction: Ruby & Rails Rich Text, Markdown, and OpenGraph Extraction

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.txt)
[![Build Status](https://github.com/ceccec/rich_text_extraction/actions/workflows/main.yml/badge.svg)](https://github.com/ceccec/rich_text_extraction/actions)

<!--
SEO: Ruby rich text extraction, Rails Markdown, OpenGraph link preview, ActionText integration, safe Markdown rendering, link metadata, Rails gem
-->

**RichTextExtraction** is a Ruby and Rails gem for extracting links, tags, mentions, emails, phone numbers, and OpenGraph metadata from rich text, Markdown, or ActionText content. It provides safe Markdown rendering, link previews, and seamless integration with Rails and ActionText. Perfect for developers who need robust, secure, and flexible text extraction and preview features in Ruby and Rails apps.

---

## What is RichTextExtraction?
RichTextExtraction is an all-in-one solution for extracting structured data (links, tags, mentions, emails, phone numbers, dates, Twitter handles, and OpenGraph metadata) from any text, Markdown, or ActionText content. It is designed for Ruby and Rails developers who want to:
- Add link previews to blogs, forums, or chat apps
- Safely render user-generated Markdown
- Extract and analyze content for search, notifications, or analytics
- Integrate with ActionText and Rails background jobs

---

## 🚀 Quick Links
- [Full Documentation & Guides](https://ceccec.github.io/rich_text_extraction/)
- [API Reference](docs/api.markdown)
- [Features Overview](docs/features.markdown)
- [Getting Started](docs/_posts/2024-06-24-getting-started.html)
- [ActionText Integration](docs/_posts/2024-06-24-actiontext-integration.html)
- [Safe Markdown Rendering](docs/_posts/2024-06-24-markdown-rendering.html)

---

## How it Works
1. **Extract**: Use the Extractor or ActionText extension to extract links, tags, mentions, and more from any text.
2. **Preview**: Fetch OpenGraph metadata for links and generate HTML, Markdown, or text previews.
3. **Integrate**: Use in Rails models, views, background jobs, or plain Ruby scripts.

![Architecture Diagram](docs/assets/diagram-rich-text-extraction.mmd)

---

## Features
- Extract links, tags, mentions, emails, phone numbers, dates, Twitter handles, and OpenGraph metadata
- Safe Markdown rendering (Redcarpet, Kramdown, CommonMarker)
- OpenGraph link previews for any URL
- Rails & ActionText integration for rich text and link preview
- Background job support for link metadata caching
- Highly customizable and extendable

---

## Installation
Add to your Gemfile:

```ruby
gem 'rich_text_extraction', github: 'ceccec/rich_text_extraction'
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install rich_text_extraction
```

---

## Basic Usage

```ruby
require 'rich_text_extraction'

body = "Hello @alice! Check out https://example.com #welcome"
extractor = RichTextExtraction::Extractor.new(body)

extractor.links      # => ["https://example.com"]
extractor.tags       # => ["welcome"]
extractor.mentions   # => ["alice"]
extractor.emails     # => []

# Markdown rendering
html = RichTextExtraction.render_markdown("**Bold** [link](https://example.com)")
```

---

## Test Suite

See [docs/testing.md](docs/testing.md) for full details on test suite organization, running tests, and adding new tests.

---

## Rails & ActionText Integration

```