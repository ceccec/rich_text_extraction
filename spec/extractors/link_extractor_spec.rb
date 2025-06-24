# frozen_string_literal: true

# spec/extractors/link_extractor_spec.rb
# Tests for RichTextExtraction::LinkExtractor (see lib/rich_text_extraction/extractors/link_extractor.rb)

require 'spec_helper'
require 'rich_text_extraction/extractors/link_extractor'

RSpec.describe RichTextExtraction::LinkExtractor do
  let(:dummy) { Class.new { extend RichTextExtraction::LinkExtractor } }

  it 'extracts links from text' do
    text = 'Visit https://example.com and http://test.com.'
    expect(dummy.extract_links(text)).to include('https://example.com', 'http://test.com')
  end

  it 'validates URLs' do
    expect(dummy.valid_url?('https://example.com')).to be true
    expect(dummy.valid_url?('not_a_url')).to be false
  end
end
