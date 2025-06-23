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
gem 'rich_text_extraction', github: 'YOUR_GITHUB_USERNAME/rich_text_extraction'
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
