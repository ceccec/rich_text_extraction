---
layout: page
title: Features
permalink: /features/
---

# Features

RichTextExtraction is a comprehensive Ruby & Rails gem for rich text, Markdown, and OpenGraph extraction. Here's what it offers:

## Extraction
- Links (URLs)
- Tags (e.g., #hashtag)
- Mentions (e.g., @user)
- Emails
- Phone numbers
- Dates
- Twitter handles
- Attachments (file URLs)

## OpenGraph & Link Previews
- Fetch OpenGraph metadata for any URL
- Generate HTML, Markdown, or text previews
- Automatic cache invalidation on content change

## Markdown Rendering
- Safe Markdown to HTML rendering
- Supports Redcarpet, Kramdown, CommonMarker
- HTML sanitization for safe display

## Rails & ActionText Integration
- Extend ActionText::RichText with extraction methods
- Rails view helper for OpenGraph previews
- Model concern for automatic cache management

## Caching & Background Jobs
- Rails.cache or custom cache support
- Configurable cache expiration and key prefix
- Background job integration for prefetching OpenGraph data

## Extensibility
- Add your own extraction helpers
- Monkey-patch or extend Extractor class

## Documentation & Quality
- Robust test suite
- YARD doc comments
- CI, coverage badge, and changelog

See the [README](https://github.com/ceccec/rich_text_extraction#readme) for full API details. 