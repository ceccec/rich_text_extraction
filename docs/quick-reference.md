---
layout: default
title: Quick Reference
nav_order: 3
---

# Quick Reference

Common use cases and code snippets for RichTextExtraction.

## Basic Extraction

### Extract Links
```ruby
extractor = RichTextExtraction::Extractor.new("Visit https://example.com")
extractor.links                    # => ["https://example.com"]
extractor.valid_urls              # => ["https://example.com"]
extractor.link_objects            # => [{ url: "https://example.com" }]
```

### Extract Social Content
```ruby
extractor = RichTextExtraction::Extractor.new("Hello @alice! Check out #ruby #rails")
extractor.mentions                 # => ["alice"]
extractor.tags                     # => ["ruby", "rails"]
extractor.mentions_with_context   # => [{ mention: "alice", context: "Hello @alice!" }]
extractor.tags_with_context       # => [{ tag: "ruby", context: "Check out #ruby #rails" }]
```

### Extract Everything
```ruby
extractor = RichTextExtraction::Extractor.new("Check out https://example.com #ruby @alice")
{
  links: extractor.links,
  tags: extractor.tags,
  mentions: extractor.mentions,
  emails: extractor.emails,
  phones: extractor.phone_numbers
}
```

## OpenGraph Integration

### Basic OpenGraph
```ruby
extractor = RichTextExtraction::Extractor.new("https://example.com")
link_objects = extractor.link_objects(with_opengraph: true)
# => [{ url: "https://example.com", opengraph: { title: "Example", description: "...", image: "..." } }]
```

### With Caching
```ruby
# Use Rails cache
link_objects = extractor.link_objects(with_opengraph: true, cache: :rails)

# Use custom cache
cache = {}
link_objects = extractor.link_objects(
  with_opengraph: true, 
  cache: cache,
  cache_options: { expires_in: 3600 }
)
```

### Error Handling
```ruby
link_objects = extractor.link_objects(with_opengraph: true)
link_objects.each do |link|
  if link[:opengraph][:error]
    puts "Error: #{link[:opengraph][:error]}"
  else
    puts "Title: #{link[:opengraph]['title']}"
  end
end
```

## Markdown Rendering

### Basic Rendering
```ruby
service = RichTextExtraction::MarkdownService.new
html = service.render("**Bold** and [link](https://example.com)")
# => "<p><strong>Bold</strong> and <a href=\"https://example.com\" target=\"_blank\" rel=\"noopener noreferrer\">link</a></p>"
```

### Custom Options
```ruby
service = RichTextExtraction::MarkdownService.new(
  renderer_options: { hard_wrap: true }
)
html = service.render(content, sanitize: false)  # For trusted content
```

### Different Renderers
```ruby
# Redcarpet (default)
service = RichTextExtraction::MarkdownService.new(renderer: :redcarpet)

# Kramdown
service = RichTextExtraction::MarkdownService.new(renderer: :kramdown)

# CommonMarker
service = RichTextExtraction::MarkdownService.new(renderer: :commonmarker)
```

## Rails Integration

### ActionText
```ruby
class Post < ApplicationRecord
  has_rich_text :content
end

post = Post.find(1)
links = post.content.extract_links
opengraph = post.content.link_objects(with_opengraph: true)
```

### View Helpers
```erb
<!-- Basic preview -->
<%= opengraph_preview_for("https://example.com") %>

<!-- With format -->
<%= opengraph_preview_for(og_data, format: :markdown) %>
<%= opengraph_preview_for(og_data, format: :text) %>
```

### Background Jobs
```ruby
class ProcessLinksJob < ApplicationJob
  def perform(post)
    links = post.content.extract_links
    opengraph = post.content.link_objects(with_opengraph: true)
    # Process data...
  end
end

ProcessLinksJob.perform_later(post)
```

## Configuration

### Global Config
```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  config.opengraph_timeout = 15.seconds
  config.max_redirects = 5
  config.sanitize_html = true
  config.debug = Rails.env.development?
  config.user_agent = 'MyApp/1.0'
end
```

### Per-Request Override
```ruby
extractor = RichTextExtraction::Extractor.new(text)
opengraph = extractor.link_objects(
  with_opengraph: true,
  timeout: 30.seconds,
  max_redirects: 10
)
```

## Common Patterns

### Social Media Processor
```ruby
class SocialMediaProcessor
  def process(content)
    extractor = RichTextExtraction::Extractor.new(content)
    {
      links: extractor.links,
      hashtags: extractor.tags,
      mentions: extractor.mentions,
      previews: extractor.link_objects(with_opengraph: true)
    }
  end
end
```

### Content Validator
```ruby
class ContentValidator
  def validate(content)
    extractor = RichTextExtraction::Extractor.new(content)
    {
      has_links: extractor.links.any?,
      link_count: extractor.links.count,
      has_mentions: extractor.mentions.any?,
      has_hashtags: extractor.tags.any?
    }
  end
end
```

### Link Preview Generator
```ruby
class LinkPreviewGenerator
  def generate(content)
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

## Error Handling

### Graceful Degradation
```ruby
begin
  opengraph = extractor.link_objects(with_opengraph: true)
rescue => e
  Rails.logger.error "OpenGraph failed: #{e.message}"
  # Fallback to basic links
  opengraph = extractor.links.map { |url| { url: url, opengraph: {} } }
end
```

### Check for Errors
```ruby
link_objects = extractor.link_objects(with_opengraph: true)
link_objects.each do |link|
  if link[:opengraph][:error]
    # Handle error case
    puts "Failed to fetch: #{link[:url]}"
  else
    # Process successful data
    puts "Title: #{link[:opengraph]['title']}"
  end
end
```

## Performance Tips

### Use Caching
```ruby
# Always cache OpenGraph data
opengraph = extractor.link_objects(
  with_opengraph: true,
  cache: :rails,
  cache_options: { expires_in: 3600 }
)
```

### Background Processing
```ruby
# For large content or many URLs
ProcessLinksJob.perform_later(post)
```

### Batch Processing
```ruby
# Process multiple items efficiently
posts.find_in_batches(batch_size: 100) do |batch|
  batch.each { |post| ProcessLinksJob.perform_later(post) }
end
```

## Debug Mode

### Enable Debugging
```ruby
RichTextExtraction.configure do |config|
  config.debug = true
end
```

### Check Logs
```ruby
Rails.logger.info "Processing: #{content}"
# Check logs for detailed information
``` 