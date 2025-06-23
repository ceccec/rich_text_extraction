---
layout: post
title: "Advanced Usage & Customization with RichTextExtraction"
date: 2024-06-24
categories: guides
---

Take your use of RichTextExtraction to the next level! This guide covers advanced features, customization, and extension points.

## Custom Extraction Helpers

You can add your own extraction logic by extending the `ExtractionHelpers` module:

```ruby
module RichTextExtraction::ExtractionHelpers
  def extract_custom_ids(text)
    text.scan(/ID-(\d+)/).flatten
  end
end

extractor = RichTextExtraction::Extractor.new("Order ID-12345 is ready.")
extractor.extract_custom_ids(extractor.text) # => ["12345"]
```

## Custom Cache Options & Key Prefix

```ruby
extractor = RichTextExtraction::Extractor.new("https://example.com")
extractor.link_objects(with_opengraph: true, cache: :rails, cache_options: { expires_in: 10.minutes, key_prefix: 'custom' })
```

## Using Background Jobs

Prefetch OpenGraph data in a background job for all posts:

```ruby
class PrefetchOpenGraphJob < ApplicationJob
  queue_as :default
  def perform(post_id)
    post = Post.find(post_id)
    post.body.link_objects(with_opengraph: true, cache: :rails)
  end
end

Post.find_each { |post| PrefetchOpenGraphJob.perform_later(post.id) }
```

## Extending the Gem

You can monkey-patch or extend the `Extractor` class for custom behavior:

```ruby
class RichTextExtraction::Extractor
  def first_link
    links.first
  end
end
```

## Error Handling

If OpenGraph extraction fails, the returned hash will include an `:error` key:

```ruby
extractor.link_objects(with_opengraph: true).first[:opengraph][:error]
```

## More Resources
- [API Reference]({{ site.baseurl }}/api/)
- [Features]({{ site.baseurl }}/features/)
- [Full README & Guides](https://github.com/ceccec/rich_text_extraction#readme) 