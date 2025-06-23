---
layout: post
title: "ActionText Integration with RichTextExtraction"
date: 2025-06-24
categories: [tutorials, actiontext, rails]
tags: [actiontext, rails, integration, background-jobs]
author: RichTextExtraction Team
---

# ActionText Integration with RichTextExtraction

RichTextExtraction seamlessly integrates with Rails ActionText, providing powerful content extraction capabilities for your rich text fields. This guide shows you how to set up and use the integration.

## Setup

### 1. Include the Concern

Add the `ExtractsRichText` concern to your models:

```ruby
class Post < ApplicationRecord
  include RichTextExtraction::ExtractsRichText
  
  has_rich_text :body
  has_rich_text :summary
end
```

### 2. Available Methods

Once included, your ActionText fields gain these methods:

- `extract_links` - Extract URLs from the content
- `extract_tags` - Extract hashtags (#tag)
- `extract_mentions` - Extract mentions (@user)
- `link_objects` - Get rich link objects with OpenGraph data
- `clear_link_cache` - Clear cached OpenGraph data

## Basic Usage

### Extracting Content

```ruby
# In your controller
def show
  @post = Post.find(params[:id])
  
  # Extract different types of content
  @links = @post.body.extract_links
  @tags = @post.body.extract_tags
  @mentions = @post.body.extract_mentions
end
```

### Getting Rich Link Data

```ruby
# Get detailed link information with OpenGraph metadata
link_objects = @post.body.link_objects(with_opengraph: true)

link_objects.each do |link|
  puts "URL: #{link[:url]}"
  puts "Title: #{link[:opengraph][:title]}"
  puts "Description: #{link[:opengraph][:description]}"
  puts "Image: #{link[:opengraph][:image]}"
end
```

## View Helpers

### Rendering OpenGraph Previews

```erb
<!-- In your view -->
<% @post.body.link_objects(with_opengraph: true).each do |link| %>
  <%= render_opengraph_preview(link[:opengraph]) %>
<% end %>
```

### Custom Preview Rendering

```erb
<!-- Custom preview with different formats -->
<%= render_opengraph_preview(@post.body, format: :markdown) %>
<%= render_opengraph_preview(@post.body, format: :text) %>
```

## Background Jobs

For better performance, process OpenGraph data in background jobs:

```ruby
# app/jobs/extract_links_job.rb
class ExtractLinksJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find(post_id)
    links = post.body.link_objects(with_opengraph: true)
    
    # Store or process the links
    post.update(extracted_links: links)
  end
end

# In your controller
def create
  @post = Post.create!(post_params)
  ExtractLinksJob.perform_later(@post.id)
end
```

## Caching

OpenGraph data is automatically cached for performance:

```ruby
# Configure caching in your initializer
RichTextExtraction.configure do |config|
  config.cache_enabled = true
  config.cache_prefix = 'rte'
  config.cache_ttl = 1.hour
end

# Clear cache for specific content
@post.body.clear_link_cache
```

## Advanced Usage

### Custom Cache Options

```ruby
# Use custom cache options per extraction
links = @post.body.link_objects(
  with_opengraph: true,
  cache: :rails,
  cache_options: { expires_in: 10.minutes, key_prefix: 'myapp' }
)
```

### Error Handling

```ruby
begin
  links = @post.body.link_objects(with_opengraph: true)
rescue RichTextExtraction::Error => e
  Rails.logger.error "Failed to extract links: #{e.message}"
  links = []
end
```

## Performance Tips

1. **Use background jobs** for OpenGraph extraction
2. **Configure appropriate cache TTL** based on your needs
3. **Batch process** multiple posts when possible
4. **Monitor cache hit rates** to optimize performance

## Troubleshooting

### Common Issues

- **Slow extraction**: Enable caching and use background jobs
- **Missing OpenGraph data**: Check network connectivity and URL accessibility
- **Cache not working**: Verify cache configuration and Rails cache setup

### Debug Mode

```ruby
# Enable debug logging
RichTextExtraction.configure do |config|
  config.debug = true
end
```

## Next Steps

- Explore [Advanced Usage]({{ site.baseurl }}/blog/2025-06-24-advanced-usage.html) for more customization options
- Learn about [Safe Markdown Rendering]({{ site.baseurl }}/blog/2025-06-24-markdown-rendering.html)
- Check the [API Reference]({{ site.baseurl }}/api-reference/) for complete documentation

---

**RichTextExtraction** - Professional rich text extraction for Ruby and Rails applications. 🚀 