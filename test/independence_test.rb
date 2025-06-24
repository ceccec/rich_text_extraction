# frozen_string_literal: true

# test/independence_test.rb
# This script verifies that rich_text_extraction works without Rails or ActiveSupport.
# Run with: ruby test/independence_test.rb

require_relative '../lib/rich_text_extraction'

Rails.logger.debug '== RichTextExtraction Independence Test =='

text = 'Visit https://example.com and email foo@bar.com #ruby @alice'
extractor = RichTextExtraction::Extractor.new(text)

Rails.logger.debug { "Links:      #{extractor.links.inspect}" } # => ["https://example.com"]
Rails.logger.debug { "Emails:     #{extractor.emails.inspect}" }       # => ["foo@bar.com"]
Rails.logger.debug { "Tags:       #{extractor.tags.inspect}" }         # => ["ruby"]
Rails.logger.debug { "Mentions:   #{extractor.mentions.inspect}" }     # => ["alice"]

# Test OpenGraph extraction with and without cache
cache = {}
og1 = RichTextExtraction.extract_opengraph('https://example.com', cache: cache)
og2 = RichTextExtraction.extract_opengraph('https://example.com', cache: cache)
Rails.logger.debug { "OpenGraph title: #{og1['title']}" }              # => "Title"
Rails.logger.debug { "Cache works:     #{og1.equal?(og2)}" }           # => true
Rails.logger.debug { "Cache keys:      #{cache.keys.inspect}" }

# Test that nothing explodes if cache: :rails is passed and Rails is not loaded
begin
  og3 = RichTextExtraction.extract_opengraph('https://example.com', cache: :rails)
  Rails.logger.debug { "OpenGraph with :rails cache: #{og3['title']}" } # => "Title"
rescue StandardError => e
  Rails.logger.debug { "Error with :rails cache: #{e.class}: #{e.message}" }
end

# Test: Passing an invalid cache object (should not raise, should bypass caching)
invalid_cache = 'not_a_cache'
begin
  og4 = RichTextExtraction.extract_opengraph('https://example.com', cache: invalid_cache)
  Rails.logger.debug { "No error with invalid cache object: #{og4['title']} (cache: #{invalid_cache.inspect})" }
rescue StandardError => e
  Rails.logger.debug { "Error with invalid cache object: #{e.class}: #{e.message}" }
end

# Test: Passing a custom object that does not respond to []=
class DummyCache; end
dummy_cache = DummyCache.new
begin
  og5 = RichTextExtraction.extract_opengraph('https://example.com', cache: dummy_cache)
  Rails.logger.debug { "No error with dummy cache object: #{og5['title']} (cache: #{dummy_cache.inspect})" }
rescue StandardError => e
  Rails.logger.debug { "Error with dummy cache object: #{e.class}: #{e.message}" }
end

# Documentation:
Rails.logger.debug { <<~DOC }

  ---
  Cache Bypass Test Documentation:
  - If cache is nil, a string, or any object that does not respond to []=, caching is bypassed and no error is raised.
  - If cache: :rails is passed and Rails is not loaded, caching is bypassed and no error is raised.
  - If cache is a hash or hash-like object, caching is used.
  ---

DOC

Rails.logger.debug '== Independence test complete =='
