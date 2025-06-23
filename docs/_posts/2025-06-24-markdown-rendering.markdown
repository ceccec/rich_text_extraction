---
layout: post
title: "Safe Markdown Rendering with RichTextExtraction"
date: 2025-06-24
categories: [tutorials, markdown, security]
tags: [markdown, html, sanitization, security, rendering]
author: RichTextExtraction Team
---

# Safe Markdown Rendering with RichTextExtraction

RichTextExtraction provides secure and customizable Markdown rendering capabilities, ensuring your content is both beautiful and safe. This guide covers the MarkdownService and security features.

## MarkdownService Overview

The `MarkdownService` class handles all Markdown rendering with built-in security features:

```ruby
require 'rich_text_extraction'

service = RichTextExtraction::MarkdownService.new
html = service.render("**Bold text** and [links](https://example.com)")
```

## Basic Usage

### Simple Rendering

```ruby
# Basic markdown rendering
markdown_service = RichTextExtraction::MarkdownService.new
html = markdown_service.render("**Bold** and *italic* text")
# => "<p><strong>Bold</strong> and <em>italic</em> text</p>"
```

### With Custom Options

```ruby
# Custom renderer options
service = RichTextExtraction::MarkdownService.new(
  sanitize_html: true,
  renderer_options: { hard_wrap: true }
)

html = service.render("Line 1\nLine 2")
# => "<p>Line 1<br>\nLine 2</p>"
```

## Security Features

### HTML Sanitization

By default, all rendered HTML is sanitized to prevent XSS attacks:

```ruby
# Dangerous content is automatically sanitized
dangerous_markdown = "**Bold** <script>alert('xss')</script>"
html = markdown_service.render(dangerous_markdown)
# => "<p><strong>Bold</strong> </p>"
# Script tags are removed
```

### Disabling Sanitization (Use with Caution)

```ruby
# Only disable sanitization if you trust the content source
service = RichTextExtraction::MarkdownService.new(sanitize_html: false)
html = service.render("**Bold** <span>trusted content</span>")
# => "<p><strong>Bold</strong> <span>trusted content</span></p>"
```

## Supported Markdown Features

### Text Formatting

```ruby
markdown = """
# Heading 1
## Heading 2

**Bold text**
*Italic text*
~~Strikethrough~~

`inline code`
"""

html = markdown_service.render(markdown)
```

### Links and Images

```ruby
markdown = """
[Link text](https://example.com)
![Alt text](https://example.com/image.jpg)
"""

html = markdown_service.render(markdown)
# Links get target="_blank" and rel="noopener noreferrer" for security
```

### Code Blocks

```ruby
markdown = """
```ruby
def hello_world
  puts "Hello, World!"
end
```
"""

html = markdown_service.render(markdown)
# Code is properly escaped and syntax highlighting classes are added
```

### Lists and Tables

```ruby
markdown = """
- Item 1
- Item 2
  - Nested item

| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
"""

html = markdown_service.render(markdown)
```

## Renderer Options

### Redcarpet (Default)

```ruby
service = RichTextExtraction::MarkdownService.new(
  renderer_options: {
    autolink: true,
    tables: true,
    fenced_code_blocks: true,
    strikethrough: true,
    superscript: true,
    underline: true,
    highlight: true,
    quote: true,
    footnotes: true
  }
)
```

### Custom Link Attributes

```ruby
# All links get security attributes by default
html = markdown_service.render("[Click here](https://example.com)")
# => "<p><a href=\"https://example.com\" target=\"_blank\" rel=\"noopener noreferrer\">Click here</a></p>"
```

## Custom Markdown Renderer

For advanced customization, you can use the `CustomMarkdownRenderer`:

```ruby
require 'redcarpet'

renderer = RichTextExtraction::CustomMarkdownRenderer.new
markdown = Redcarpet::Markdown.new(renderer, fenced_code_blocks: true)

html = markdown.render("**Bold** and [link](https://example.com)")
```

### Custom Renderer Features

- **Secure links**: All links get `target="_blank"` and `rel="noopener noreferrer"`
- **Lazy loading images**: Images get `loading="lazy"` attribute
- **Code escaping**: Code blocks are properly HTML-escaped
- **Custom CSS classes**: Images get `markdown-image` class

## Configuration

### Global Configuration

```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  config.markdown_renderer = :redcarpet
  config.markdown_options = {
    hard_wrap: true,
    link_attributes: { target: '_blank', rel: 'noopener noreferrer' }
  }
end
```

### Per-Instance Configuration

```ruby
# Override global settings for specific instances
service = RichTextExtraction::MarkdownService.new(
  sanitize_html: false,
  renderer_options: { hard_wrap: false }
)
```

## Error Handling

```ruby
begin
  html = markdown_service.render(markdown_content)
rescue StandardError => e
  Rails.logger.error "Markdown rendering failed: #{e.message}"
  html = "<p>Content could not be rendered</p>"
end
```

## Performance Considerations

### Caching Rendered HTML

```ruby
# Cache rendered markdown for performance
cached_html = Rails.cache.fetch("markdown_#{Digest::MD5.hexdigest(content)}") do
  markdown_service.render(content)
end
```

### Batch Processing

```ruby
# Process multiple markdown contents efficiently
contents = ["**Bold**", "*Italic*", "`Code`"]
html_results = contents.map { |content| markdown_service.render(content) }
```

## Best Practices

1. **Always sanitize HTML** unless you completely trust the content source
2. **Use appropriate renderer options** for your use case
3. **Cache rendered content** for better performance
4. **Handle errors gracefully** to prevent application crashes
5. **Test with various markdown inputs** to ensure proper rendering

## Troubleshooting

### Common Issues

- **HTML not rendering**: Check if sanitization is too strict
- **Links not working**: Verify link attributes are being added correctly
- **Performance issues**: Enable caching for frequently rendered content

### Debug Mode

```ruby
# Enable debug logging for troubleshooting
RichTextExtraction.configure do |config|
  config.debug = true
end
```

## Next Steps

- Learn about [Advanced Usage]({{ site.baseurl }}/blog/2025-06-24-advanced-usage.html) for more customization
- Explore [ActionText Integration]({{ site.baseurl }}/blog/2025-06-24-actiontext-integration.html)
- Check the [API Reference]({{ site.baseurl }}/api-reference/) for complete documentation

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀 