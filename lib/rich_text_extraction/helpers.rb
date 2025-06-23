module RichTextExtraction
  module Helpers
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

if defined?(Rails)
  ActionView::Base.include RichTextExtraction::Helpers
end 