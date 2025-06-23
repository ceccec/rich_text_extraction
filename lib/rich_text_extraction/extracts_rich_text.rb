module RichTextExtraction
  module ExtractsRichText
    extend ActiveSupport::Concern

    included do
      after_save :clear_rich_text_link_cache if respond_to?(:after_save)
      after_destroy :clear_rich_text_link_cache if respond_to?(:after_destroy)
    end

    def clear_rich_text_link_cache
      body.clear_link_cache(cache: :rails)
    end
  end
end 