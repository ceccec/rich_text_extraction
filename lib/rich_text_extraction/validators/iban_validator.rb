# frozen_string_literal: true

require_relative '../extractors/validators'
require_relative '../extraction_patterns'

class IbanValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    result = RichTextExtraction::Extractors::Validators.valid_iban?(value)
    Rails.logger.debug { "[DEBUG] IbanValidator: value=#{value.inspect}, result=#{result}" }
    return if result

    record.errors.add(attribute, options[:message] || 'is not a valid IBAN')
  end
end
