---
layout: post
title: "How to Add Link Previews to Rails with ActionText"
date: 2024-06-24
categories: guides
---

Learn how to add rich link previews to your Rails app using ActionText and the RichTextExtraction gem.

## 1. Install the Gem

```ruby
gem 'rich_text_extraction', github: 'ceccec/rich_text_extraction'
```

## 2. Enable ActionText in Your Model

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  include RichTextExtraction::ExtractsRichText
end
```

## 3. Display Link Previews in Your View

```erb
<% @post.body.link_objects(with_opengraph: true, cache: :rails).each do |link| %>
  <%= opengraph_preview_for(link[:opengraph]) %>
<% end %>
```

## 4. Prefetch OpenGraph Data in a Background Job (Optional)

```ruby
class PrefetchOpenGraphJob < ApplicationJob
  queue_as :default
  def perform(post_id)
    post = Post.find(post_id)
    post.body.link_objects(with_opengraph: true, cache: :rails)
  end
end
```

## 5. More Resources

- [Full README & API](https://github.com/ceccec/rich_text_extraction#readme)
- [Getting Started Guide]({{ site.baseurl }}/blog/2024-06-24-getting-started.html) 