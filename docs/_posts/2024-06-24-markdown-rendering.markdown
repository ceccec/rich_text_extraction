---
layout: post
title: "Safe Markdown Rendering with RichTextExtraction"
date: 2024-06-24
categories: guides
---

RichTextExtraction makes it easy to render Markdown to safe HTML in Ruby and Rails apps.

## Supported Engines
- Redcarpet (default)
- Kramdown
- CommonMarker

## Basic Usage

```ruby
html = RichTextExtraction.render_markdown("**Bold** [link](https://example.com)")
```

## In Rails Views

```erb
<%= RichTextExtraction.render_markdown(@post.body.to_plain_text) %>
```

## Security: HTML Sanitization
All rendered HTML is sanitized to prevent XSS and unsafe tags/attributes.

## Customizing the Renderer
You can configure the Markdown engine and options in your Rails initializer or by monkey-patching.

## More Resources
- [API Reference]({{ site.baseurl }}/api/)
- [Advanced Usage]({{ site.baseurl }}/blog/2024-06-24-advanced-usage.html)
- [Full README & Guides](https://github.com/ceccec/rich_text_extraction#readme) 