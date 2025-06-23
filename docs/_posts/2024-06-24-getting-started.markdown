---
layout: post
title: "Getting Started with RichTextExtraction"
date: 2025-06-24
categories: [tutorials, getting-started]
tags: [installation, basic-usage, rails]
author: RichTextExtraction Team
---

# Getting Started with RichTextExtraction

RichTextExtraction is a powerful Ruby gem designed to extract rich text, Markdown, and OpenGraph metadata from content in Ruby and Rails applications. This guide will walk you through the installation and basic usage.

## Installation

Add RichTextExtraction to your Gemfile:

```ruby
gem 'rich_text_extraction'
```

Then run:

```bash
bundle install
```

## Basic Usage

### Extracting Links

```ruby
require 'rich_text_extraction'

# Create an extractor instance
extractor = RichTextExtraction::Extractor.new("Visit https://example.com and check out #ruby")

# Extract different types of content
extractor.links      # => ["https://example.com"]
extractor.tags       # => ["ruby"]
extractor.mentions   # => []
```

### Getting Rich Link Objects

```ruby
# Get detailed link information with OpenGraph data
link_objects = extractor.link_objects(with_opengraph: true)
# => [{ url: "https://example.com", opengraph: { title: "Example Site", ... } }]
```

### Rendering Markdown

```ruby
# Render markdown to HTML
markdown_service = RichTextExtraction::MarkdownService.new
html = markdown_service.render("**Bold text** and [links](https://example.com)")
# => "<p><strong>Bold text</strong> and <a href=\"https://example.com\">links</a></p>"
```

## Rails Integration

### Model Setup

```ruby
class Post < ApplicationRecord
  include RichTextExtraction::ExtractsRichText
  
  has_rich_text :body
end
```

### Controller Usage

```ruby
def show
  @post = Post.find(params[:id])
  @links = @post.body.extract_links(with_opengraph: true)
end
```

### View Helpers

```erb
<%= render_opengraph_preview(@post.body) %>
```

## Configuration

Create an initializer to customize behavior:

```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  config.cache_enabled = true
  config.cache_prefix = 'rte'
  config.cache_ttl = 1.hour
  
  config.opengraph_timeout = 5.seconds
  config.opengraph_user_agent = 'RichTextExtraction/1.0'
  
  config.markdown_renderer = :redcarpet
  config.markdown_options = { hard_wrap: true, link_attributes: { target: '_blank' } }
end
```

## Next Steps

- Learn about [ActionText Integration]({{ site.baseurl }}/blog/2025-06-24-actiontext-integration.html)
- Explore [Advanced Usage]({{ site.baseurl }}/blog/2025-06-24-advanced-usage.html)
- Check out the [API Reference]({{ site.baseurl }}/api-reference/)

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀 