# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

module RichTextExtraction
  module Validators
    # Validator for URL format
    # Validates web URLs and links
    class UrlValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_url?, 'is not a valid URL')
      end

      # Temporarily commented out to avoid registration issues
      # if defined?(RichTextExtraction::Registry)
      #   RichTextExtraction::Registry.register_validator(
      #     :url,
      #     klass: self,
      #     sample_valid: 'https://example.com',
      #     sample_invalid: 'not-a-url'
      #   )
      # end
    end
  end
end
