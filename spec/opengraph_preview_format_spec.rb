# frozen_string_literal: true

##
# Tests for OpenGraph preview rendering in RichTextExtraction (format rendering)
#

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative 'support/shared_contexts'

RSpec.describe 'OpenGraph Format Preview' do
  include_context 'with test cache'
  include_context 'with test extractor'
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
