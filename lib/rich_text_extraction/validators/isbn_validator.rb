# frozen_string_literal: true

require_relative '../extractors/validators'
require_relative '../extraction_patterns'

class IsbnValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    result = RichTextExtraction::Extractors::Validators.valid_isbn?(value)
    Rails.logger.debug { "[DEBUG] IsbnValidator: value=#{value.inspect}, result=#{result}" }
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid ISBN')
  end
end
