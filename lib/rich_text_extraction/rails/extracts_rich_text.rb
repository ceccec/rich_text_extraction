# frozen_string_literal: true

module RichTextExtraction
  module Rails
    module ExtractsRichText
      if defined?(::Rails)
        extend ActiveSupport::Concern

        included do
          after_save :clear_rich_text_link_cache if respond_to?(:after_save)
          after_destroy :clear_rich_text_link_cache if respond_to?(:after_destroy)
        end

        # Clears the OpenGraph cache for all links in the body.
        def clear_rich_text_link_cache
          body.clear_link_cache(cache: :rails)
        end
      end
    end
  end
end
