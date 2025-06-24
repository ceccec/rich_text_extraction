# frozen_string_literal: true

# RichTextExtraction::Helpers provides Rails view helpers for OpenGraph previews.
module RichTextExtraction
  # Helpers for rendering OpenGraph previews in Rails views.
  module Helpers
    # Renders an OpenGraph preview for a URL or OpenGraph data hash.
    # @param url_or_og [String, Hash]
    # @param format [Symbol] :html, :markdown, or :text
    # @return [String]
    def opengraph_preview_for(url_or_og, format: :html)
      og = if url_or_og.is_a?(String)
             extractor = RichTextExtraction::Extractor.new(url_or_og)
             data = extractor.opengraph_data_for_links.first
             data ? data[:opengraph] : {}
           else
             url_or_og
           end
      result = RichTextExtraction.opengraph_preview(og, format: format)
      result.respond_to?(:html_safe) ? result.html_safe : result
    end
  end
end

# Auto-include helpers in ActionView::Base if Rails is loaded
# @!parse
#   ActionView::Base.include RichTextExtraction::Helpers if defined?(Rails) && defined?(ActionView::Base)
ActionView::Base.include RichTextExtraction::Helpers if defined?(Rails) && defined?(ActionView::Base)
