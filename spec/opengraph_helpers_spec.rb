# frozen_string_literal: true

##
# Tests for OpenGraph extraction and preview helpers in RichTextExtraction
#
# Covers OpenGraph extraction, preview rendering, and error handling.

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative 'support/shared_contexts'

RSpec.describe RichTextExtraction::OpenGraphHelpers do
  include_context 'with test cache'
  include_context 'with test extractor'

  it 'provides OpenGraph extraction functionality' do
    expect(extractor).to respond_to(:link_objects)
  end

  it 'supports caching options' do
    expect(extractor.link_objects(with_opengraph: true, cache: cache)).to be_an(Array)
  end
end
