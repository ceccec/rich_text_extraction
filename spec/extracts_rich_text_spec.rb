# frozen_string_literal: true

##
# Tests for ExtractsRichText concern/module in RichTextExtraction
#
# Covers cache clearing and integration with dummy classes.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe 'ExtractsRichText concern' do
  include_context 'when using a dummy body class'
  include_context 'when using a dummy class'
  include_context 'with Rails stubs'

  context 'when clearing cache for links in the body via the concern' do
    it 'removes the cache entry' do
      rails_stub
      instance = dummy_class.new(dummy_body_class)
      instance.body.link_objects(with_opengraph: true, cache: :rails)
      expect(Rails.cache.exist?('opengraph:TestApp:https://example.com')).to be true
      instance.clear_rich_text_link_cache
      expect(Rails.cache.exist?('opengraph:TestApp:https://example.com')).to be false
    end
  end
end

RSpec.describe RichTextExtraction::ExtractsRichText do
  # Add ExtractsRichText tests here
  it 'is a placeholder for ExtractsRichText tests' do
    expect(true).to be true
  end
end
