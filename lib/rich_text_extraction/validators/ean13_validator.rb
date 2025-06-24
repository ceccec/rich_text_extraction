# frozen_string_literal: true

require_relative '../extraction_patterns'

class Ean13Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    result = value.to_s.match?(RichTextExtraction::ExtractionPatterns::EAN13_REGEX)
    Rails.logger.debug { "[DEBUG] Ean13Validator: value=#{value.inspect}, result=#{result}" }
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid EAN-13 barcode')
  end
end
