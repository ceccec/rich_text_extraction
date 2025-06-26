# frozen_string_literal: true

require_relative 'base_validator'
require_relative '../extractors/extraction_patterns'

module RichTextExtraction
  module Validators
    # Validator for UPC-A barcode format
    # Validates 12-digit Universal Product Code barcodes
    class UpcaValidator < BaseValidator
      def validate_each(record, attribute, value)
        validate_with_method(record, attribute, value, :valid_upca?, 'is not a valid UPC-A')
      end
    end
  end
end
