---
layout: default
title: Usage Guide
nav_order: 2
---

# Usage Guide

This guide covers how to install, configure, and use the RichTextExtraction gem in your Ruby and Rails applications.

## Table of Contents

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Rails Integration](#rails-integration)
- [Advanced Features](#advanced-features)
- [Configuration](#configuration)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

## Installation

### Add to Gemfile

```ruby
# Gemfile
gem 'rich_text_extraction'
```

### Install

```bash
bundle install
```

### Rails Integration (Optional)

The gem automatically integrates with Rails when available. No additional setup required.

## Basic Usage

### Creating an Extractor

```ruby
require 'rich_text_extraction'

# Basic text extraction
extractor = RichTextExtraction::Extractor.new("Visit https://example.com and check out #ruby #rails!")
```

### Extracting Links

```ruby
# Get all URLs
links = extractor.links
# => ["https://example.com"]

# Get links with OpenGraph metadata
link_objects = extractor.link_objects(with_opengraph: true)
# => [{ url: "https://example.com", opengraph: { title: "Example", ... } }]

# Get only valid URLs
valid_links = extractor.valid_urls
# => ["https://example.com"]
```

### Extracting Social Content

```ruby
# Extract hashtags
tags = extractor.tags
# => ["ruby", "rails"]

# Extract mentions
mentions = extractor.mentions
# => ["alice", "bob"]

# Extract with context
tags_with_context = extractor.tags_with_context
# => [{ tag: "ruby", context: "check out #ruby #rails!" }]
```

### Markdown Rendering

```ruby
# Safe HTML rendering
markdown_service = RichTextExtraction::MarkdownService.new
html = markdown_service.render("**Bold text** and [links](https://example.com)")
# => "<p><strong>Bold text</strong> and <a href=\"https://example.com\" target=\"_blank\" rel=\"noopener noreferrer\">links</a></p>"

# Without sanitization (for trusted content)
html = markdown_service.render(content, sanitize: false)
```

## Rails Integration

### ActionText Integration

```ruby
# In your model
class Post < ApplicationRecord
  has_rich_text :content
end

# In your view or controller
post = Post.find(1)
links = post.content.extract_links
opengraph_data = post.content.link_objects(with_opengraph: true)
```

### View Helpers

```erb
<!-- In your ERB templates -->
<%= opengraph_preview_for("https://example.com") %>

<!-- With custom format -->
<%= opengraph_preview_for(og_data, format: :markdown) %>
```

### Background Jobs

```ruby
# In your job
class ProcessLinksJob < ApplicationJob
  def perform(post)
    links = post.content.extract_links
    opengraph_data = post.content.link_objects(with_opengraph: true)
    # Process the data...
  end
end
```

## Advanced Features

### Caching OpenGraph Data

```ruby
# Use Rails cache
extractor = RichTextExtraction::Extractor.new("https://example.com")
opengraph_data = extractor.link_objects(with_opengraph: true, cache: :rails)

# Use custom cache
custom_cache = {}
opengraph_data = extractor.link_objects(
  with_opengraph: true, 
  cache: custom_cache,
  cache_options: { expires_in: 3600 }
)
```

### Custom Markdown Rendering

```ruby
# Configure renderer options
service = RichTextExtraction::MarkdownService.new(
  renderer_options: { 
    hard_wrap: true,
    link_attributes: { class: 'custom-link' }
  }
)

# Use different renderers
service = RichTextExtraction::MarkdownService.new(renderer: :kramdown)
service = RichTextExtraction::MarkdownService.new(renderer: :commonmarker)
```

### Error Handling

```ruby
# Graceful error handling
begin
  opengraph_data = extractor.link_objects(with_opengraph: true)
rescue => e
  Rails.logger.error "OpenGraph extraction failed: #{e.message}"
  # Handle error gracefully
end

# Check for errors in results
link_objects = extractor.link_objects(with_opengraph: true)
link_objects.each do |link|
  if link[:opengraph][:error]
    puts "Error fetching #{link[:url]}: #{link[:opengraph][:error]}"
  end
end
```

## Configuration

### Global Configuration

```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  config.opengraph_timeout = 15.seconds
  config.max_redirects = 5
  config.sanitize_html = true
  config.default_excerpt_length = 300
  config.debug = Rails.env.development?
  config.user_agent = 'MyApp/1.0'
end
```

### Per-Request Configuration

```ruby
# Override settings for specific requests
extractor = RichTextExtraction::Extractor.new(text)
opengraph_data = extractor.link_objects(
  with_opengraph: true,
  timeout: 30.seconds,
  max_redirects: 10
)
```

## Examples

### Social Media Post Processing

```ruby
class SocialMediaProcessor
  def process_post(content)
    extractor = RichTextExtraction::Extractor.new(content)
    
    {
      links: extractor.links,
      hashtags: extractor.tags,
      mentions: extractor.mentions,
      opengraph_previews: extractor.link_objects(with_opengraph: true)
    }
  end
end

# Usage
processor = SocialMediaProcessor.new
result = processor.process_post("Check out https://example.com #ruby @alice")
```

### Content Moderation

```ruby
class ContentModerator
  def moderate_content(content)
    extractor = RichTextExtraction::Extractor.new(content)
    
    {
      has_links: extractor.links.any?,
      link_count: extractor.links.count,
      has_mentions: extractor.mentions.any?,
      mention_count: extractor.mentions.count,
      has_hashtags: extractor.tags.any?,
      hashtag_count: extractor.tags.count
    }
  end
end
```

### Link Preview Generation

```ruby
class LinkPreviewGenerator
  def generate_previews(content)
    extractor = RichTextExtraction::Extractor.new(content)
    
    extractor.link_objects(with_opengraph: true).map do |link|
      {
        url: link[:url],
        title: link[:opengraph]['title'],
        description: link[:opengraph]['description'],
        image: link[:opengraph]['image']
      }
    end
  end
end
```

### Markdown Content Processing

```ruby
class MarkdownProcessor
  def process_content(markdown_content)
    service = RichTextExtraction::MarkdownService.new
    
    {
      html: service.render(markdown_content),
      links: RichTextExtraction::Extractor.new(markdown_content).links,
      word_count: markdown_content.split(/\s+/).count
    }
  end
end
```

## Troubleshooting

### Common Issues

**OpenGraph extraction fails:**
```ruby
# Increase timeout
RichTextExtraction.configure do |config|
  config.opengraph_timeout = 30.seconds
end

# Check for errors
result = extractor.link_objects(with_opengraph: true)
if result.first[:opengraph][:error]
  puts "Error: #{result.first[:opengraph][:error]}"
end
```

**Markdown rendering issues:**
```ruby
# Enable debug mode
RichTextExtraction.configure do |config|
  config.debug = true
end

# Check Jekyll configuration
service = RichTextExtraction::MarkdownService.new
html = service.render(content, sanitize: false) # For debugging
```

**Performance issues:**
```ruby
# Use caching
opengraph_data = extractor.link_objects(
  with_opengraph: true,
  cache: :rails,
  cache_options: { expires_in: 3600 }
)

# Process in background jobs
ProcessLinksJob.perform_later(post)
```

### Debug Mode

```ruby
# Enable debug logging
RichTextExtraction.configure do |config|
  config.debug = true
end

# Check logs for detailed information
Rails.logger.info "Processing content: #{content}"
```

### Performance Tips

1. **Use caching** for OpenGraph data
2. **Process in background jobs** for large content
3. **Batch process** multiple items
4. **Use appropriate timeouts** for your use case
5. **Monitor memory usage** with large datasets

## API Reference

For detailed API documentation, see the [API Reference]({{ site.baseurl }}/api-reference/).

## Support

- **Documentation**: [Full docs site]({{ site.baseurl }}/)
- **Issues**: [GitHub Issues](https://github.com/ceccec/rich_text_extraction/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ceccec/rich_text_extraction/discussions)

# Usage

> **Note:** All extraction patterns, regexes, and cache operations are centralized in shared modules:
> - `lib/rich_text_extraction/constants.rb`
> - `lib/rich_text_extraction/extraction_patterns.rb`
> - `lib/rich_text_extraction/cache_operations.rb`
>
> For advanced usage or extension, contribute to these files. 