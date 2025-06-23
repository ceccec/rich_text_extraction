# frozen_string_literal: true

require "spec_helper"
require "rich_text_extraction"

RSpec.describe RichTextExtraction do
  it "has a version number" do
    expect(RichTextExtraction::VERSION).not_to be nil
  end
end

RSpec.describe RichTextExtraction::Extractor do
  it "extracts links from text" do
    text = "Visit https://example.com and http://test.com."
    extractor = described_class.new(text)
    expect(extractor.links).to contain_exactly("https://example.com", "http://test.com")
  end

  it "extracts tags and mentions" do
    text = "Hello @alice #welcome"
    extractor = described_class.new(text)
    expect(extractor.mentions).to eq([ "alice" ])
    expect(extractor.tags).to eq([ "welcome" ])
  end

  it "renders markdown to HTML" do
    html = RichTextExtraction.render_markdown("**Bold** [link](https://example.com)")
    expect(html).to include("<strong>Bold</strong>")
    expect(html).to include("<a href=\"https://example.com\"")
  end
end
