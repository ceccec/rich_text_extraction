---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
title: RichTextExtraction: Ruby & Rails Rich Text, Markdown, and OpenGraph Extraction
description: Ruby and Rails gem for extracting links, tags, mentions, emails, phone numbers, and OpenGraph metadata from rich text, Markdown, or ActionText. Safe Markdown rendering, link previews, and ActionText integration.
---

# RichTextExtraction

**The all-in-one Ruby & Rails gem for rich text extraction, Markdown rendering, and OpenGraph link previews.**

---

## What is RichTextExtraction?
RichTextExtraction is a Ruby and Rails gem for extracting links, tags, mentions, emails, phone numbers, and OpenGraph metadata from rich text, Markdown, or ActionText. It is ideal for blogs, forums, chat apps, and any app that needs robust text extraction and preview features.

---

## 🚀 Quick Start

```ruby
gem 'rich_text_extraction', github: 'ceccec/rich_text_extraction'
```

```bash
bundle install
```

```ruby
require 'rich_text_extraction'
body = "Hello @alice! Check out https://example.com #welcome"
extractor = RichTextExtraction::Extractor.new(body)
extractor.link_objects(with_opengraph: true)
# => [{ url: "https://example.com", opengraph: { "title" => "Example Domain", ... } }]
```

---

## How it Works
1. **Extract**: Use the Extractor or ActionText extension to extract links, tags, mentions, and more from any text.
2. **Preview**: Fetch OpenGraph metadata for links and generate HTML, Markdown, or text previews.
3. **Integrate**: Use in Rails models, views, background jobs, or plain Ruby scripts.

---

## Features
- Extract links, tags, mentions, emails, phone numbers, dates, Twitter handles, and OpenGraph metadata
- Safe Markdown rendering (Redcarpet, Kramdown, CommonMarker)
- ActionText & Rails integration for link preview and structured data
- Background job support for prefetching/caching link metadata
- Highly customizable and extendable

---

## Security & Performance
- All rendered HTML is sanitized for XSS protection
- OpenGraph metadata is cached for performance
- Thread-safe and production-ready

---

## FAQ
**Q: Does it work with Rails 7?**
A: Yes, fully tested with Rails 7.0 and 7.1.

**Q: How do I customize extraction?**
A: Extend the ExtractionHelpers module or monkey-patch the Extractor class.

**Q: Is it safe for user input?**
A: Yes, all Markdown rendering is sanitized. You can also add your own sanitization logic.

**Q: Can I use it outside Rails?**
A: Yes, all core features work in plain Ruby.

**Q: How do I generate API docs?**
A: Run `yard doc` and open `doc/index.html` in your browser.

---

## Why use RichTextExtraction?
- **All-in-one**: Extract everything you need from rich text, Markdown, or ActionText.
- **Rails & ActionText ready**: Seamless integration for link previews and metadata.
- **Safe Markdown**: Secure, flexible rendering for user content.
- **Customizable**: Extend extraction logic, configure caching, and use in any Ruby or Rails project.

---

## Rails & ActionText Integration

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  include RichTextExtraction::ExtractsRichText
end

# In a controller or background job:
@post.body.link_objects(with_opengraph: true, cache: :rails)

# In a view:
<% @post.body.link_objects(with_opengraph: true, cache: :rails).each do |link| %>
  <%= opengraph_preview_for(link[:opengraph]) %>
<% end %>
```

- Automatic cache invalidation for OpenGraph data
- Configurable cache options and key prefix
- Background job support for prefetching/caching link metadata

---

## More Examples & Documentation
- [Full Documentation & Guides](https://ceccec.github.io/rich_text_extraction/)
- [API Reference]({{ site.baseurl }}/api/)
- [Features]({{ site.baseurl }}/features/)

---

*Want to contribute a guide or showcase your use case? [Open an issue or PR!](https://github.com/ceccec/rich_text_extraction/issues)*
