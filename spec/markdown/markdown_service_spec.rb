# frozen_string_literal: true

# spec/services/markdown_service_spec.rb
# Tests for RichTextExtraction::MarkdownService (see lib/rich_text_extraction/services/markdown_service.rb)

require 'spec_helper'
require 'rich_text_extraction/services/markdown_service'

RSpec.describe RichTextExtraction::MarkdownService do
  let(:service) { described_class.new }

  it 'renders markdown to HTML' do
    expect(service.render('**Bold**')).to include('<strong>Bold</strong>')
  end

  it 'sanitizes script tags' do
    html = service.render('<script>alert(1)</script>')
    expect(html).not_to include('<script>')
  end
end
