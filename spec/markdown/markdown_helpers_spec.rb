# frozen_string_literal: true

##
# Tests for Markdown rendering helpers in RichTextExtraction
#
# Covers rendering of markdown to HTML.

require 'spec_helper'

RSpec.describe 'Markdown rendering helpers' do
  include_context 'with markdown test data'

  include_examples 'renders markdown content'
end

RSpec.describe RichTextExtraction::Helpers::MarkdownHelpers do
  include_context 'with markdown test data'

  include_examples 'renders markdown content'
end
