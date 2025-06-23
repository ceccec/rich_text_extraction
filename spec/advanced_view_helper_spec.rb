# frozen_string_literal: true

##
# Advanced view helper tests for RichTextExtraction
#
# Tests view helper rendering with different formats.

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative 'support/shared_contexts'

RSpec.describe 'Advanced view helper usage' do
  context 'when rendering view helper with markdown and text formats' do
    include_context 'with test helper'
    include_context 'with test OpenGraph data'

    it 'renders markdown format' do
      result = helper.opengraph_preview_for(og, format: :markdown)
      expect(result).to include('Test')
    end

    it 'renders text format' do
      result = helper.opengraph_preview_for(og, format: :text)
      expect(result).to include('Test')
    end
  end
end
