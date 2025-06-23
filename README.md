# RichTextExtraction: Ruby & Rails Gem for Rich Text, Markdown, and OpenGraph Extraction

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.txt)
[![Build Status](https://github.com/ceccec/rich_text_extraction/actions/workflows/main.yml/badge.svg)](https://github.com/ceccec/rich_text_extraction/actions)

> **RichTextExtraction** is a powerful Ruby gem for extracting links, tags, mentions, emails, phone numbers, and OpenGraph metadata from rich text, Markdown, or ActionText content in Rails. It also provides safe Markdown rendering and seamless integration with Rails and ActionText for link previews and structured data extraction.

## 📚 Documentation

- [Getting Started Guide](docs/_posts/2024-06-24-getting-started.html)
- [ActionText Integration](docs/_posts/2024-06-24-actiontext-integration.html)
- [Safe Markdown Rendering](docs/_posts/2024-06-24-markdown-rendering.html)
- [Advanced Usage & Customization](docs/_posts/2024-06-24-advanced-usage.html)
- [Troubleshooting](docs/_posts/2024-06-24-troubleshooting.html)
- [Features Overview](docs/features.markdown)
- [API Reference](docs/api.markdown)
- [Architecture Diagram](docs/assets/diagram-rich-text-extraction.mmd)
- [Example Screenshot](docs/assets/example-screenshot.png)

> For the latest guides and full documentation, visit the [project website](https://ceccec.github.io/rich_text_extraction/).

---

## Table of Contents
- [Why Use This Gem?](#why-use-this-gem)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Rails Integration](#rails-integration)
- [Advanced Usage](#advanced-usage)
- [ActionText & Background Job Integration](#actiontext--background-job-integration)
- [Example Output](#example-output)
- [Related Projects & Docs](#related-projects--docs)
- [Contributing](#contributing)
- [License](#license)
- [Compatibility](#compatibility)

---

## Why Use This Gem?
- **All-in-one**: Extract links, tags, mentions, emails, phone numbers, dates, Twitter handles, and OpenGraph metadata from any text, Markdown, or ActionText::RichText.
- **Rails & ActionText ready**: Seamless integration with Rails, ActionText, and background jobs for link preview and metadata caching.
- **Safe Markdown rendering**: Supports Redcarpet, Kramdown, and CommonMarker with HTML sanitization.
- **Link preview**: Generate OpenGraph-based link previews for any URL in your content.
- **Highly customizable**: Extend extraction logic, configure caching, and use in both Rails and plain Ruby projects.

---

## Features
- Extract links, tags, mentions, emails, phone numbers, dates, Twitter handles, and more from text or ActionText::RichText
- Extract OpenGraph metadata for link previews
- Render Markdown to HTML using Redcarpet, Kramdown, or CommonMarker
- Sanitize rendered HTML for safe display
- Extend ActionText::RichText with extraction methods (e.g., `post.body.links`)
- Integrate with Rails background jobs for prefetching/caching link metadata

---

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

---

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

---

## Configuration
You can configure the default Markdown renderer and sanitization options. See the gem's source for details.

---

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

---

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

---

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

---

## Example Output

**Extracted Data:**
```ruby
body = "Hello @alice! Check out https://example.com #welcome"
extractor = RichTextExtraction::Extractor.new(body)
extractor.link_objects(with_opengraph: true)
# => [{ url: "https://example.com", opengraph: { "title" => "Example Domain", ... } }]
```

**Rendered Link Preview (HTML):**
```html
<a href='https://example.com' target='_blank' rel='noopener'><img src='https://example.com/image.png' alt='Example Domain' style='max-width:200px;'><br><strong>Example Domain</strong></a><p>This domain is for use in illustrative examples in documents.</p>
```

---

## Related Projects & Docs
- [ActionText (Rails)](https://edgeguides.rubyonrails.org/action_text_overview.html)
- [Redcarpet](https://github.com/vmg/redcarpet)
- [Kramdown](https://kramdown.gettalong.org/)
- [CommonMarker](https://github.com/gjtorikian/commonmarker)
- [OpenGraph Protocol](https://ogp.me/)

---

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ceccec/rich_text_extraction.

---

## License
The gem is available as open source under the terms of the MIT License.

## Compatibility

- Ruby: >= 3.1.0, < 4.0
- Redcarpet: >= 3.6, < 4.0
- Kramdown: >= 2.4, < 3.0
- CommonMarker: >= 0.23, < 1.0
- Sanitize: >= 6.0, < 7.0
- Jekyll (for docs): >= 4.0, < 5.0
