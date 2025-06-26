# frozen_string_literal: true

# Helper methods for validator operations
# Provides utility functions for validator class creation and management
module RichTextExtraction
  module Helpers
    module ValidatorHelpers
      # Validators that use method-based validation instead of regex
      METHOD_BASED_VALIDATORS = %i[isbn vin issn iban luhn url].freeze

      # Check if a validator should be processed (has regex and is not method-based)
      def self.should_process_validator?(key, meta)
        meta[:regex] && !METHOD_BASED_VALIDATORS.include?(key)
      end

      # Get the class name for a validator symbol
      def self.validator_class_name(key)
        "RichTextExtraction::Validators::#{key.to_s.camelize}Validator"
      end

      # Get the method name for a validator symbol
      def self.validator_method_name(key)
        "extract_#{key.to_s.pluralize}"
      end

      # Get the regex constant for a validator
      def self.get_regex_constant(meta)
        meta[:regex]
      end

      # Get the error message for a validator
      def self.get_error_message(key, meta)
        meta[:error_message] || "is not a valid #{key.to_s.humanize.downcase}"
      end
    end
  end
end
