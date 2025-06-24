# frozen_string_literal: true

# spec/extractors/social_extractor_spec.rb
# Tests for RichTextExtraction::SocialExtractor (see lib/rich_text_extraction/extractors/social_extractor.rb)

require 'spec_helper'
require 'rich_text_extraction/extractors/social_extractor'

RSpec.describe RichTextExtraction::SocialExtractor do
  let(:dummy) { Class.new { extend RichTextExtraction::SocialExtractor } }

  it 'extracts hashtags from text' do
    text = 'Check out #ruby and #rails!'
    expect(dummy.extract_tags(text)).to include('ruby', 'rails')
  end

  it 'extracts mentions from text' do
    text = 'Hello @alice and @bob!'
    expect(dummy.extract_mentions(text)).to include('alice', 'bob')
  end
end
