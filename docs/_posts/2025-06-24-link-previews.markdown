---
layout: post
title: "Link Previews with RichTextExtraction"
date: 2025-06-24
categories: [tutorials, opengraph, link-previews]
tags: [opengraph, link-previews, caching, background-jobs]
author: RichTextExtraction Team
---

# Link Previews with RichTextExtraction

RichTextExtraction provides powerful link preview functionality by automatically fetching and caching OpenGraph metadata from URLs. This guide shows you how to implement beautiful link previews in your Rails applications.

## OpenGraph Service Overview

The `OpenGraphService` handles fetching and caching OpenGraph metadata:

```ruby
require 'rich_text_extraction'

og_service = RichTextExtraction::OpenGraphService.new
metadata = og_service.extract('https://example.com')
# => { title: "Example Site", description: "...", image: "...", url: "..." }
```

## Basic Usage

### Fetching OpenGraph Data

```ruby
# Basic OpenGraph extraction
og_service = RichTextExtraction::OpenGraphService.new
metadata = og_service.extract('https://github.com/ceccec/rich_text_extraction')

puts metadata[:title]        # => "ceccec/rich_text_extraction"
puts metadata[:description]  # => "Professional rich text extraction..."
puts metadata[:image]        # => "https://opengraph.githubassets.com/..."
puts metadata[:url]          # => "https://github.com/ceccec/rich_text_extraction"
```

### With Caching

```ruby
# OpenGraph data is automatically cached for performance
metadata = og_service.extract('https://example.com', cache: :rails)
# Data is cached for 1 hour by default
```

## View Helpers

### Rendering Link Previews

```erb
<!-- In your view -->
<% @post.body.link_objects(with_opengraph: true).each do |link| %>
  <%= render_opengraph_preview(link[:opengraph]) %>
<% end %>
```

### Custom Preview Formats

```erb
<!-- Markdown format -->
<%= render_opengraph_preview(@post.body, format: :markdown) %>

<!-- Text format -->
<%= render_opengraph_preview(@post.body, format: :text) %>

<!-- Custom template -->
<%= render_opengraph_preview(@post.body, template: 'custom_preview') %>
```

## Custom Preview Templates

### Default Template

The default preview template includes:

```erb
<!-- Default preview structure -->
<div class="opengraph-preview">
  <div class="opengraph-image">
    <img src="<%= metadata[:image] %>" alt="<%= metadata[:title] %>">
  </div>
  <div class="opengraph-content">
    <h3 class="opengraph-title"><%= metadata[:title] %></h3>
    <p class="opengraph-description"><%= metadata[:description] %></p>
    <span class="opengraph-url"><%= metadata[:url] %></span>
  </div>
</div>
```

### Custom Template

Create your own preview template:

```erb
<!-- app/views/rich_text_extraction/_custom_preview.html.erb -->
<div class="link-preview">
  <% if metadata[:image].present? %>
    <div class="preview-image">
      <img src="<%= metadata[:image] %>" alt="<%= metadata[:title] %>" loading="lazy">
    </div>
  <% end %>
  
  <div class="preview-content">
    <h4><%= link_to metadata[:title], metadata[:url], target: '_blank' %></h4>
    <% if metadata[:description].present? %>
      <p><%= truncate(metadata[:description], length: 150) %></p>
    <% end %>
    <small class="preview-domain"><%= URI.parse(metadata[:url]).host %></small>
  </div>
</div>
```

## Configuration

### Global Configuration

```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  config.opengraph_timeout = 5.seconds
  config.opengraph_user_agent = 'RichTextExtraction/1.0'
  config.cache_enabled = true
  config.cache_prefix = 'rte'
  config.cache_ttl = 1.hour
end
```

### Per-Request Configuration

```ruby
# Custom options for specific requests
metadata = og_service.extract('https://example.com',
  cache: :rails,
  cache_options: { expires_in: 10.minutes, key_prefix: 'myapp' },
  timeout: 10.seconds
)
```

## Background Jobs

For better performance, process OpenGraph data in background jobs:

```ruby
# app/jobs/fetch_opengraph_job.rb
class FetchOpenGraphJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find(post_id)
    og_service = RichTextExtraction::OpenGraphService.new
    
    links = post.body.extract_links
    links.each do |url|
      metadata = og_service.extract(url, cache: :rails)
      # Store or process the metadata
    end
  end
end

# In your controller
def create
  @post = Post.create!(post_params)
  FetchOpenGraphJob.perform_later(@post.id)
end
```

## Error Handling

### Graceful Degradation

```ruby
begin
  metadata = og_service.extract('https://example.com')
rescue RichTextExtraction::Error => e
  Rails.logger.error "OpenGraph extraction failed: #{e.message}"
  metadata = {
    title: 'Link Preview Unavailable',
    description: 'Unable to fetch preview for this link',
    url: 'https://example.com'
  }
end
```

### Custom Error Handling

```ruby
# Custom error handling in views
<% begin %>
  <%= render_opengraph_preview(@post.body) %>
<% rescue RichTextExtraction::Error => e %>
  <div class="preview-error">
    <p>Preview unavailable</p>
    <small>Error: <%= e.message %></small>
  </div>
<% end %>
```

## Performance Optimization

### Caching Strategies

```ruby
# Use different cache strategies
og_service.extract('https://example.com', cache: :rails)           # Rails cache
og_service.extract('https://example.com', cache: :redis)           # Redis cache
og_service.extract('https://example.com', cache: :memory)          # Memory cache
og_service.extract('https://example.com', cache: false)            # No caching
```

### Batch Processing

```ruby
# Process multiple URLs efficiently
urls = ['https://example1.com', 'https://example2.com', 'https://example3.com']
metadata_batch = urls.map { |url| og_service.extract(url, cache: :rails) }
```

## Styling Link Previews

### CSS Example

```css
/* Basic preview styling */
.opengraph-preview {
  border: 1px solid #e1e5e9;
  border-radius: 8px;
  overflow: hidden;
  margin: 1rem 0;
  background: #fff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.opengraph-image img {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.opengraph-content {
  padding: 1rem;
}

.opengraph-title {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.opengraph-description {
  margin: 0 0 0.5rem 0;
  color: #586069;
  font-size: 0.9rem;
  line-height: 1.4;
}

.opengraph-url {
  color: #0366d6;
  font-size: 0.8rem;
}
```

## Advanced Features

### Custom User Agents

```ruby
# Use custom user agent for specific requests
metadata = og_service.extract('https://example.com',
  user_agent: 'MyApp/1.0 (https://myapp.com)'
)
```

### Timeout Configuration

```ruby
# Set custom timeout for slow sites
metadata = og_service.extract('https://slow-site.com',
  timeout: 15.seconds
)
```

### Fallback Content

```ruby
# Provide fallback content when OpenGraph data is unavailable
metadata = og_service.extract('https://example.com') || {
  title: 'Example.com',
  description: 'Visit Example.com for more information',
  url: 'https://example.com'
}
```

## Troubleshooting

### Common Issues

- **Slow loading**: Enable caching and use background jobs
- **Missing images**: Check if the site provides OpenGraph images
- **Timeout errors**: Increase timeout for slow sites
- **Cache not working**: Verify cache configuration

### Debug Mode

```ruby
# Enable debug logging
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