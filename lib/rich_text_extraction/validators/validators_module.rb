# frozen_string_literal: true

# Auto-require all validator files
Dir[File.join(__dir__, 'validators', '*_validator.rb')].each { |file| require file }

require_relative '../core/constants'
require_relative '../extractors/extraction_patterns'
require_relative '../helpers/validator_helpers'

# Auto-register each validator symbol with its class (now in RichTextExtraction::Validators namespace)
RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES.each_key do |symbol|
  class_name = RichTextExtraction::Helpers::ValidatorHelpers.validator_class_name(symbol)
  names = class_name.split('::')
  # Traverse the namespace to get the parent module
  parent = names[0..-2].inject(Object) { |mod, name| mod.const_get(name) }
  const = names.last
  # Only set if not already defined
  next if parent.const_defined?(const)

  # If the class is already loaded, set it; otherwise, skip
  begin
    parent.const_set(const, parent.const_get(const))
  rescue NameError
    warn "Validator class #{class_name} not found for symbol :#{symbol}"
  end
end

# === DRY Metaprogramming: Pattern-based Validators ===

RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES.each do |key, meta|
  next unless RichTextExtraction::Helpers::ValidatorHelpers.should_process_validator?(key, meta)

  class_name = RichTextExtraction::Helpers::ValidatorHelpers.validator_class_name(key)
  regex_const = RichTextExtraction::Helpers::ValidatorHelpers.get_regex_constant(meta)
  error_message = RichTextExtraction::Helpers::ValidatorHelpers.get_error_message(key, meta)
  klass = Class.new(ActiveModel::EachValidator) do
    define_method(:validate_each) do |record, attribute, value|
      regex = RichTextExtraction::Extractors::ExtractionPatterns.const_get(regex_const)
      result = value.to_s.match?(regex)

      return if result

      record.errors.add(attribute, options[:message] || error_message)
    end
  end
  names = class_name.split('::')
  parent = names[0..-2].inject(Object) { |mod, name| mod.const_get(name) }
  const = names.last
  parent.const_set(const, klass) unless parent.const_defined?(const)
end

module RichTextExtraction
  module Validators
    module ValidatorsModule
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def validate(value)
          new.valid?(value)
        end
      end

      def valid?(value)
        with_error_handling { validate_value(value) }
      end

      def validate_value(value)
        # Validation logic here (placeholder)
        true
      end
    end
  end
end

# Register all validators in the universal registry
RichTextExtraction::Core::UniversalRegistry.instance.register(:validators, :universal, RichTextExtraction::Validators::ValidatorsModule)
