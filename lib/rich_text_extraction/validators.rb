# frozen_string_literal: true

# Auto-require all validator files
Dir[File.join(__dir__, 'validators', '*_validator.rb')].each { |file| require file }

require_relative 'constants'
require_relative 'extraction_patterns'

# Auto-register each validator symbol with its class
RichTextExtraction::Constants::VALIDATOR_EXAMPLES.each_key do |symbol|
  class_name = "#{symbol.to_s.split('_').map(&:capitalize).join}Validator"
  Object.const_set(class_name, Object.const_get(class_name)) unless Object.const_defined?(class_name)
end

# === DRY Metaprogramming: Pattern-based Validators ===

RichTextExtraction::Constants::VALIDATOR_EXAMPLES.each do |key, meta|
  next unless meta[:regex] && !%i[isbn vin issn iban luhn url].include?(key)

  class_name = "#{key.to_s.camelize}Validator"
  regex_const = meta[:regex]
  error_message = meta[:error_message] || "is not a valid #{key.to_s.humanize.downcase}"
  klass = Class.new(ActiveModel::EachValidator) do
    define_method(:validate_each) do |record, attribute, value|
      regex = RichTextExtraction::ExtractionPatterns.const_get(regex_const)
      result = value.to_s.match?(regex)
      return if result

      # Prefer I18n if available
      i18n_key = "errors.messages.#{key}"
      message = options[:message] || begin
        I18n.t(i18n_key, default: error_message)
      rescue StandardError
        error_message
      end
      record.errors.add(attribute, message)
    end
  end
  Object.const_set(class_name, klass) unless Object.const_defined?(class_name)
end
