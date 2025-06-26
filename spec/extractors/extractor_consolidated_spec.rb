# frozen_string_literal: true

##
# Comprehensive tests for RichTextExtraction Extractor
#
# This file consolidates all extractor-related tests to eliminate duplication
# and provide a single source of truth for extractor functionality.

require 'spec_helper'

RSpec.describe RichTextExtraction::Extractors::Extractor do
  include_context 'with common test data'

  # Set up subject for shared examples
  subject { RichTextExtraction::Extractors::Extractor.new(sample_text) }

  describe 'Basic extraction functionality' do
    include_context 'with common setup'

    it 'can be instantiated with a URL' do
      expect(extractor).to be_a(RichTextExtraction::Extractors::Extractor)
    end

    it 'extracts links from text' do
      result = extractor.links
      expect(result).to include(*test_links)
    end

    it 'extracts tags from text' do
      result = extractor.tags
      expect(result).to include(*test_tags)
    end

    it 'extracts mentions from text' do
      result = extractor.mentions
      expect(result).to include(*test_mentions)
    end

    include_examples 'extracts content from text', :extract_links
    include_examples 'extracts content from text', :extract_tags
    include_examples 'extracts content from text', :extract_mentions
    include_examples 'extracts multiple content types'
  end

  describe 'OpenGraph integration' do
    include_context 'with OpenGraph setup'

    include_examples 'handles OpenGraph extraction'
    include_examples 'handles OpenGraph caching'
  end

  describe 'Caching functionality' do
    include_context 'with common setup'

    include_examples 'handles caching correctly'
  end

  describe 'Error handling' do
    include_context 'with error setup'

    include_examples 'handles errors gracefully'
    include_examples 'handles invalid input gracefully'
  end

  describe 'Performance characteristics' do
    include_context 'with performance test data'
    include_context 'with common setup'

    include_examples 'performs efficiently'
  end

  describe 'Configuration' do
    include_context 'with common setup'

    include_examples 'respects configuration'
  end

  describe 'API interface' do
    include_context 'with common setup'

    include_examples 'provides API interface'
  end

  describe 'Rails integration' do
    include_context 'with Rails integration setup'

    include_examples 'integrates with Rails'
    include_examples 'works with background jobs'
  end
end

# === Merged from social_extractor_spec.rb ===
require 'rich_text_extraction/extractors/social_extractor'

RSpec.describe RichTextExtraction::Extractors::SocialExtractor do
  let(:dummy) { Class.new { extend RichTextExtraction::Extractors::SocialExtractor } }

  it 'extracts hashtags from text' do
    text = 'Check out #ruby and #rails!'
    expect(dummy.extract_tags(text)).to include('ruby', 'rails')
  end

  it 'extracts mentions from text' do
    text = 'Hello @alice and @bob!'
    expect(dummy.extract_mentions(text)).to include('alice', 'bob')
  end
end

# === Merged from link_extractor_spec.rb ===
require 'rich_text_extraction/extractors/link_extractor'

RSpec.describe RichTextExtraction::Extractors::LinkExtractor do
  let(:dummy) { Class.new { extend RichTextExtraction::Extractors::LinkExtractor } }

  it 'extracts links from text' do
    text = 'Visit https://example.com and http://test.com.'
    expect(dummy.extract_links(text)).to include('https://example.com', 'http://test.com')
  end

  it 'validates URLs' do
    expect(dummy.valid_url?('https://example.com')).to be true
    expect(dummy.valid_url?('not_a_url')).to be false
  end
end
