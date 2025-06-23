# frozen_string_literal: true

##
# Tests for RichTextExtraction::Extractor
#
# Covers link, tag, and mention extraction.

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative 'support/shared_contexts'

RSpec.describe RichTextExtraction::Extractor do
  context 'when extracting links' do
    let(:text) { 'Visit https://example.com and http://test.com.' }
    subject(:extractor) { described_class.new(text) }

    it_behaves_like 'extracts links from text'
  end

  context 'when extracting tags' do
    let(:text) { 'Hello #welcome' }
    subject(:extractor) { described_class.new(text) }

    it_behaves_like 'extracts tags from text'
  end

  context 'when extracting mentions' do
    let(:text) { 'Hello @alice' }
    subject(:extractor) { described_class.new(text) }

    it_behaves_like 'extracts mentions from text'
  end

  it 'is a placeholder for Extractor tests' do
    expect(true).to be true
  end
end
