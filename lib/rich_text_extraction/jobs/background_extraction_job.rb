# frozen_string_literal: true

module RichTextExtraction
  module Jobs
    class BackgroundExtractionJob < ApplicationJob
      queue_as :default

      def perform(content, extraction_type = :universal, options = {})
        # Register this job in the registry
        RichTextExtraction::Registry.register_job(self.class.name, self)
        
        # Use helper for extraction
        helper = RichTextExtraction::Helper.new
        
        # Extract content using universal interface
        result = case extraction_type.to_sym
                 when :links
                   helper.extract_links(content, options)
                 when :mentions
                   helper.extract_mentions(content, options)
                 when :hashtags
                   helper.extract_hashtags(content, options)
                 when :social
                   helper.extract_social_media(content, options)
                 else
                   helper.extract_rich_text(content, options)
                 end
        
        # Return the extracted result
        result
      end

      private

      def self.register_in_registry
        RichTextExtraction::Registry.register_job(
          'BackgroundExtractionJob',
          self,
          description: 'Background job for rich text extraction processing'
        )
      end

      # Auto-register when the class is loaded
      register_in_registry
    end
  end
end 