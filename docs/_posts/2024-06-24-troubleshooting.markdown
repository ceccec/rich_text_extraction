---
layout: post
title: "Troubleshooting RichTextExtraction"
date: 2024-06-24
categories: guides
---

Having trouble? Here are solutions to common issues with RichTextExtraction.

## 1. Missing Dependencies (Redcarpet, Nokogiri, HTTParty)
- **Error:** `uninitialized constant Redcarpet`
- **Solution:** Add `gem 'redcarpet'` to your Gemfile and run `bundle install`.
- Repeat for `nokogiri` and `httparty` if you see similar errors.

## 2. OpenGraph Extraction Fails
- **Error:** `:error` key in OpenGraph data
- **Solution:** Check the URL is correct and accessible. Some sites block bots or require HTTPS.

## 3. Cache Not Working
- **Error:** OpenGraph data not cached or not invalidated
- **Solution:** Ensure you are using `cache: :rails` and have configured `Rails.cache` properly. Check your cache store settings.

## 4. Markdown Not Rendering as Expected
- **Error:** Output is plain text or missing formatting
- **Solution:** Ensure you are using a supported Markdown engine (Redcarpet, Kramdown, CommonMarker) and that the gem is installed.

## 5. Rails Integration Issues
- **Error:** `undefined method 'links' for #<ActionText::RichText>`
- **Solution:** Make sure you included `RichTextExtraction::ExtractsRichText` in your model and restarted your Rails server.

## More Help
- [API Reference]({{ site.baseurl }}/api/)
- [Full README & Guides](https://github.com/ceccec/rich_text_extraction#readme)
- [Open an Issue](https://github.com/ceccec/rich_text_extraction/issues) 