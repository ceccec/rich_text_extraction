# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

# Validator for MAC address format
# Validates Media Access Control addresses
module RichTextExtraction
  module Validators
    class MacAddressValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_mac_address?, 'is not a valid MAC address')
      end
    end
  end
end
