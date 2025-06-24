---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
title: RichTextExtraction Documentation
nav_order: 1
---

# RichTextExtraction Documentation

Extract links, tags, mentions, emails, phone numbers, and OpenGraph metadata from rich text, Markdown, or ActionText in Ruby and Rails applications.

## Quick Start

```ruby
require 'rich_text_extraction'

extractor = RichTextExtraction::Extractor.new("Visit https://example.com and check out #ruby #rails!")
links = extractor.links        # => ["https://example.com"]
tags = extractor.tags          # => ["ruby", "rails"]
mentions = extractor.mentions  # => []
```

## Documentation Sections

- **[Usage Guide]({{ site.baseurl }}/usage/)** - Complete guide to installing and using the gem
- **[Features]({{ site.baseurl }}/features/)** - Overview of all available features
- **[API Reference]({{ site.baseurl }}/api-reference/)** - Detailed API documentation
- **[Getting Started]({{ site.baseurl }}/_posts/2025-06-24-getting-started.html)** - Quick start tutorial
- **[Advanced Usage]({{ site.baseurl }}/_posts/2025-06-24-advanced-usage.html)** - Advanced features and patterns

## Key Features

### 🔗 Link Extraction
Extract URLs from text with validation and OpenGraph metadata fetching.

```ruby
extractor = RichTextExtraction::Extractor.new("Check out https://example.com")
links = extractor.links
# => ["https://example.com"]

# With OpenGraph data
link_objects = extractor.link_objects(with_opengraph: true)
# => [{ url: "https://example.com", opengraph: { title: "Example", ... } }]
```

### 🏷️ Social Content Extraction
Extract hashtags, mentions, and social media handles.

```ruby
extractor = RichTextExtraction::Extractor.new("Hello @alice! Check out #ruby #rails")
mentions = extractor.mentions  # => ["alice"]
tags = extractor.tags          # => ["ruby", "rails"]
```

### 📝 Safe Markdown Rendering
Convert Markdown to safe HTML with built-in sanitization.

```ruby
service = RichTextExtraction::MarkdownService.new
html = service.render("**Bold text** and [links](https://example.com)")
# => "<p><strong>Bold text</strong> and <a href=\"https://example.com\" target=\"_blank\" rel=\"noopener noreferrer\">links</a></p>"
```

### 🚀 Rails Integration
Seamless integration with Rails and ActionText.

```ruby
# In your model
class Post < ApplicationRecord
  has_rich_text :content
end

# Extract from ActionText
post = Post.find(1)
links = post.content.extract_links
```

## Installation

Add to your Gemfile:

```ruby
gem 'rich_text_extraction'
```

Then run:

```bash
bundle install
```

## Configuration

```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  config.opengraph_timeout = 15.seconds
  config.sanitize_html = true
  config.debug = Rails.env.development?
end
```

## Test & Quality Status (June 2025)

- **RSpec:** 42 examples, 0 failures
- **RuboCop:** No offenses detected
- **YARD:** 85.86% documented, a few dynamic mixin warnings (expected for Rails mixins)
- **Gem build:** No gemspec self-inclusion error (fixed June 2025)

## Support

- **Documentation**: [Full docs site]({{ site.baseurl }}/)
- **Issues**: [GitHub Issues](https://github.com/ceccec/rich_text_extraction/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ceccec/rich_text_extraction/discussions)

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀
