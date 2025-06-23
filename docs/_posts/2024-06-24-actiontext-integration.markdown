---
layout: post
title: "ActionText Integration with RichTextExtraction"
date: 2024-06-24
categories: guides
---

Learn how to supercharge your Rails app's rich text fields with RichTextExtraction and ActionText.

## 1. Enable ActionText in Your Model

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  include RichTextExtraction::ExtractsRichText
end
```

## 2. Extract Data from Rich Text

```ruby
post = Post.create!(body: "Hello @alice! Visit https://example.com #welcome")
post.body.links      # => ["https://example.com"]
post.body.tags       # => ["welcome"]
post.body.mentions   # => ["alice"]
```

## 3. Link Previews in Views

```erb
<% @post.body.link_objects(with_opengraph: true, cache: :rails).each do |link| %>
  <%= opengraph_preview_for(link[:opengraph]) %>
<% end %>
```

## 4. Automatic Cache Invalidation

When you update or destroy a record, OpenGraph cache for all links in the body is cleared automatically.

## 5. Background Job Prefetching

```ruby
class PrefetchOpenGraphJob < ApplicationJob
  queue_as :default
  def perform(post_id)
    post = Post.find(post_id)
    post.body.link_objects(with_opengraph: true, cache: :rails)
  end
end
```

## 6. More Resources
- [API Reference]({{ site.baseurl }}/api/)
- [Advanced Usage]({{ site.baseurl }}/blog/2024-06-24-advanced-usage.html)
- [Full README & Guides](https://github.com/ceccec/rich_text_extraction#readme) 