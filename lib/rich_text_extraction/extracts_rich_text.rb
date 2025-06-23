# frozen_string_literal: true

# RichTextExtraction::ExtractsRichText is a concern for automatic cache invalidation in Rails models.
module RichTextExtraction
  # Concern for automatic cache invalidation on save/destroy for models with a rich text body.
  module ExtractsRichText
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
