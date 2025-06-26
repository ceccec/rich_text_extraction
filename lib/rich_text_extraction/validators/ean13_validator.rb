# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

module RichTextExtraction
  module Validators
    # Validator for EAN-13 barcode format
    # Validates 13-digit European Article Number barcodes
    class Ean13Validator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_ean13?, 'is not a valid EAN-13')
      end
    end
  end
end
