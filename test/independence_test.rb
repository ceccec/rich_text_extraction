# test/independence_test.rb
# This script verifies that rich_text_extraction works without Rails or ActiveSupport.
# Run with: ruby test/independence_test.rb

require_relative '../lib/rich_text_extraction'

puts "== RichTextExtraction Independence Test =="

text = "Visit https://example.com and email foo@bar.com #ruby @alice"
extractor = RichTextExtraction::Extractor.new(text)

puts "Links:      #{extractor.links.inspect}"         # => ["https://example.com"]
puts "Emails:     #{extractor.emails.inspect}"       # => ["foo@bar.com"]
puts "Tags:       #{extractor.tags.inspect}"         # => ["ruby"]
puts "Mentions:   #{extractor.mentions.inspect}"     # => ["alice"]

# Test OpenGraph extraction with and without cache
cache = {}
og1 = RichTextExtraction.extract_opengraph('https://example.com', cache: cache)
og2 = RichTextExtraction.extract_opengraph('https://example.com', cache: cache)
puts "OpenGraph title: #{og1['title']}"              # => "Title"
puts "Cache works:     #{og1.equal?(og2)}"           # => true
puts "Cache keys:      #{cache.keys.inspect}"

# Test that nothing explodes if cache: :rails is passed and Rails is not loaded
begin
  og3 = RichTextExtraction.extract_opengraph('https://example.com', cache: :rails)
  puts "OpenGraph with :rails cache: #{og3['title']}" # => "Title"
rescue => e
  puts "Error with :rails cache: #{e.class}: #{e.message}"
end

# Test: Passing an invalid cache object (should not raise, should bypass caching)
invalid_cache = "not_a_cache"
begin
  og4 = RichTextExtraction.extract_opengraph('https://example.com', cache: invalid_cache)
  puts "No error with invalid cache object: #{og4['title']} (cache: #{invalid_cache.inspect})"
rescue => e
  puts "Error with invalid cache object: #{e.class}: #{e.message}"
end

# Test: Passing a custom object that does not respond to []=
class DummyCache; end
dummy_cache = DummyCache.new
begin
  og5 = RichTextExtraction.extract_opengraph('https://example.com', cache: dummy_cache)
  puts "No error with dummy cache object: #{og5['title']} (cache: #{dummy_cache.inspect})"
rescue => e
  puts "Error with dummy cache object: #{e.class}: #{e.message}"
end

# Documentation:
puts <<~DOC

---
Cache Bypass Test Documentation:
- If cache is nil, a string, or any object that does not respond to []=, caching is bypassed and no error is raised.
- If cache: :rails is passed and Rails is not loaded, caching is bypassed and no error is raised.
- If cache is a hash or hash-like object, caching is used.
---

DOC

puts "== Independence test complete ==" 