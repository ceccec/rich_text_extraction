# frozen_string_literal: true

##
# Advanced view helper tests for RichTextExtraction
#
# Tests view helper rendering with different formats.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe 'Advanced view helper usage' do
  context 'when rendering view helper with markdown and text formats' do
    let(:helper) { Class.new { include RichTextExtraction::Helpers }.new }
    let(:og) { { 'title' => 'Test', 'url' => 'https://test.com' } }

    it 'renders markdown format' do
      expect(helper.opengraph_preview_for(og, format: :markdown)).to include('**Test**')
    end

    it 'renders text format' do
      expect(helper.opengraph_preview_for(og, format: :text)).to include('Test')
    end
  end
end 