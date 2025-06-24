# frozen_string_literal: true

require_relative '../extraction_patterns'

class IpValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    result = value.to_s.match?(RichTextExtraction::ExtractionPatterns::IP_REGEX)
    Rails.logger.debug { "[DEBUG] IpValidator: value=#{value.inspect}, result=#{result}" }
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid IPv4 address')
  end
end
