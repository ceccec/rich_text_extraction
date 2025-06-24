# frozen_string_literal: true

require_relative '../extraction_patterns'

class MacAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    regex = RichTextExtraction::ExtractionPatterns.const_get(:MAC_ADDRESS_REGEX)
    val = value.to_s.strip
    Rails.logger.debug { "[DEBUG] MacAddressValidator: value='#{val}', regex=#{regex.inspect}" }
    result = val.match?(regex)
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid MAC address')
  end
end
