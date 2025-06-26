# frozen_string_literal: true

# Base extractor module providing common extraction functionality
# Shared by all specific extractors to eliminate code duplication
module RichTextExtraction
  module Extractors
    module BaseExtractor
      extend ActiveSupport::Concern

      # Helper method to extract patterns with common logic
      def self.extract_pattern(text, pattern, **_options)
        return [] if text.blank?

        matches = text.scan(pattern)
        matches.flatten.compact.uniq
      end

      # Helper method to extract with validation
      def self.extract_with_validation(text, pattern, validation_method = nil, **options)
        matches = extract_pattern(text, pattern, **options)

        if validation_method
          matches.select { |match| send(validation_method, match) }
        else
          matches
        end
      end

      # Helper method to extract with custom processing
      def self.extract_with_processing(text, pattern, processor = nil, **options)
        matches = extract_pattern(text, pattern, **options)

        if processor
          matches.map(&processor)
        else
          matches
        end
      end
    end
  end
end
