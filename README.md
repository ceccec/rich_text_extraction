# RichTextExtraction

RichTextExtraction is a Ruby gem for extracting structured data (links, tags, mentions, emails, phone numbers, etc.) and rendering Markdown safely from rich text or Markdown content. It is designed for use with Rails apps using ActionText, but can be used standalone.

## Features
- Extract links, tags, mentions, emails, phone numbers, dates, Twitter handles, and more from text or ActionText::RichText
- Render Markdown to HTML using Redcarpet, Kramdown, or CommonMarker
- Sanitize rendered HTML for safe display
- Extend ActionText::RichText with extraction methods (e.g., `post.body.links`)

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rich_text_extraction', github: 'ceccec/rich_text_extraction'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rich_text_extraction
```

## Usage

```ruby
require 'rich_text_extraction'

body = "Hello @alice! Check out https://example.com #welcome"
extractor = RichTextExtraction::Extractor.new(body)

extractor.links      # => ["https://example.com"]
extractor.tags       # => ["welcome"]
extractor.mentions   # => ["alice"]
extractor.emails     # => []

# In Rails with ActionText:
post.body.links      # => ["https://example.com"]
post.body.tags       # => ["welcome"]

# Markdown rendering
html = RichTextExtraction.render_markdown("**Bold** [link](https://example.com)")
```

## Configuration
You can configure the default Markdown renderer and sanitization options. See the gem's source for details.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/YOUR_GITHUB_USERNAME/rich_text_extraction.

## License
The gem is available as open source under the terms of the MIT License.

## Rails Integration

### 1. Automatic Cache Invalidation
Include the concern in your model:

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  include RichTextExtraction::ExtractsRichText
end
```

This will automatically clear OpenGraph cache for links in the body after save/destroy.

### 2. Railtie Configuration
Set default cache options in your Rails config:

```ruby
# config/application.rb or an initializer
config.rich_text_extraction.cache_options = { expires_in: 1.hour }
```

### 3. Rails View Helper
Render OpenGraph previews in your views:

```erb
<%= opengraph_preview_for("https://example.com") %>
```

You can also pass OpenGraph data directly:

```erb
<%= opengraph_preview_for({ "title" => "Example", "url" => "https://example.com" }) %>
```

## Advanced Usage

### Custom Cache Options and Key Prefix

```ruby
# Use a custom key prefix and expiration with Rails.cache
extractor = RichTextExtraction::Extractor.new("https://example.com")
extractor.link_objects(with_opengraph: true, cache: :rails, cache_options: { expires_in: 10.minutes, key_prefix: 'custom' })
```

### Using the View Helper with Markdown and Text Formats

```erb
<%= opengraph_preview_for("https://example.com", format: :markdown) %>
<%= opengraph_preview_for("https://example.com", format: :text) %>
```

### Using the Extractor Directly (Non-Rails)

```ruby
body = "Check https://example.com"
extractor = RichTextExtraction::Extractor.new(body)
extractor.link_objects(with_opengraph: true)
# => [{ url: "https://example.com", opengraph: { ... } }]
```

### Error Handling

If OpenGraph extraction fails, the returned hash will include an :error key:

```ruby
extractor.link_objects(with_opengraph: true).first[:opengraph][:error]
```

### Extending the Gem

You can add your own extraction helpers by extending the ExtractionHelpers module or monkey-patching the Extractor class.

### Background Job Integration (Stub)

You can enqueue OpenGraph fetching in a background job:

```ruby
class FetchOpenGraphJob < ApplicationJob
  queue_as :default
  def perform(url)
    RichTextExtraction::Extractor.new(url).link_objects(with_opengraph: true, cache: :rails)
  end
end
```

### Full API Options

#### link_objects
- `with_opengraph:` (boolean)
- `cache:` (nil, :rails, or a Hash)
- `cache_options:` (hash, e.g., { expires_in: 1.hour, key_prefix: 'myapp' })

#### clear_link_cache
- `cache:` (nil, :rails, or a Hash)
- `cache_options:` (hash, e.g., { key_prefix: 'myapp' })

## ActionText & Background Job Integration

### Using with ActionText

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  include RichTextExtraction::ExtractsRichText
end
```

#### In a controller or background job

```ruby
@post.body.link_objects(with_opengraph: true, cache: :rails)
# => [{ url: "...", opengraph: { ... } }]
```

#### In a view

```erb
<% @post.body.link_objects(with_opengraph: true, cache: :rails).each do |link| %>
  <%= opengraph_preview_for(link[:opengraph]) %>
<% end %>
```

### Prefetching OpenGraph Data in a Background Job

```ruby
class PrefetchOpenGraphJob < ApplicationJob
  queue_as :default
  def perform(post_id)
    post = Post.find(post_id)
    post.body.link_objects(with_opengraph: true, cache: :rails)
  end
end

# Enqueue for all posts
Post.find_each do |post|
  PrefetchOpenGraphJob.perform_later(post.id)
end
```

### Invalidate Cache When Body Changes

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  include RichTextExtraction::ExtractsRichText

  after_save :prefetch_opengraph

  private
  def prefetch_opengraph
    PrefetchOpenGraphJob.perform_later(id)
  end
end
```
