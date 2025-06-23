# frozen_string_literal: true

##
# Tests for Markdown rendering helpers in RichTextExtraction
#
# Covers rendering of markdown to HTML.

require 'spec_helper'
require_relative 'support/shared_contexts'

RSpec.describe 'Markdown rendering helpers' do
  context 'when rendering markdown to HTML' do
    it 'renders bold text' do
      html = RichTextExtraction.render_markdown('**Bold** [link](https://example.com)')
      expect(html).to include('<strong>Bold</strong>')
    end

    it 'renders links' do
      html = RichTextExtraction.render_markdown('**Bold** [link](https://example.com)')
      expect(html).to include('<a href="https://example.com"')
    end
  end
end

RSpec.describe RichTextExtraction::MarkdownHelpers do
  # Add MarkdownHelpers tests here
  it 'is a placeholder for MarkdownHelpers tests' do
    expect(true).to be true
  end
end
