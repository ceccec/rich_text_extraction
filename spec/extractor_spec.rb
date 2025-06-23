# frozen_string_literal: true

##
# Tests for RichTextExtraction::Extractor
#
# Covers link, tag, and mention extraction.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe RichTextExtraction::Extractor do
  subject(:extractor) { described_class.new(text) }

  context 'when extracting links' do
    let(:text) { 'Visit https://example.com and http://test.com.' }

    it 'extracts all links' do
      expect(extractor.links).to contain_exactly('https://example.com', 'http://test.com')
    end
  end

  context 'when extracting tags' do
    let(:text) { 'Hello #welcome' }

    it 'extracts tags' do
      expect(extractor.tags).to eq(['welcome'])
    end
  end

  context 'when extracting mentions' do
    let(:text) { 'Hello @alice' }

    it 'extracts mentions' do
      expect(extractor.mentions).to eq(['alice'])
    end
  end

  it 'is a placeholder for Extractor tests' do
    expect(true).to be true
  end
end
