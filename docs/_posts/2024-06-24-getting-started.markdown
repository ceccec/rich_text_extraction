---
layout: post
title: "Getting Started with RichTextExtraction"
date: 2024-06-24
categories: guides
---

RichTextExtraction is a Ruby & Rails gem for extracting links, tags, mentions, and more from rich text, Markdown, or ActionText.

## Installation

```ruby
gem 'rich_text_extraction', github: 'ceccec/rich_text_extraction'
```
```bash
bundle install
```

## Basic Usage

```ruby
require 'rich_text_extraction'
body = "Hello @alice! Check out https://example.com #welcome"
extractor = RichTextExtraction::Extractor.new(body)
puts extractor.links
puts extractor.tags
puts extractor.mentions
```

See the [README](https://github.com/ceccec/rich_text_extraction#readme) for more! 