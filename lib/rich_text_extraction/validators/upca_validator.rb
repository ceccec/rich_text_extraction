# frozen_string_literal: true

require_relative '../extraction_patterns'

class UpcaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    result = value.to_s.match?(RichTextExtraction::ExtractionPatterns::UPCA_REGEX)
    Rails.logger.debug { "[DEBUG] UpcaValidator: value=#{value.inspect}, result=#{result}" }
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid UPC-A barcode')
  end
end
