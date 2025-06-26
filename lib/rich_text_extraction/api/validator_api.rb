# frozen_string_literal: true

require 'active_support/core_ext/numeric/time'
require 'json'
require 'digest'
require_relative '../core/constants'
require_relative '../validators/auto_loader'

# RichTextExtraction::ValidatorAPI provides public methods for validator metadata, examples, regex, and validation (with optional caching).
# This module serves as the main public interface for all validator operations.
module RichTextExtraction
  module API
    ##
    # ValidatorAPI provides a comprehensive API for validating various data types.
    #
    # This class offers both single and batch validation capabilities with caching,
    # rate limiting, and comprehensive error handling.
    #
    class ValidatorAPI
      # Constants for loop detection
      MAX_VALIDATION_ATTEMPTS = 5
      LOOP_DETECTION_TTL = 1.minute
      LOOP_DETECTION_PREFIX = 'validation_loop'

      # Get help information about the API
      def self.help(json: false)
        info = {
          description: 'RichTextExtraction::ValidatorAPI provides public methods for validator metadata, examples, regex, and validation (with optional caching).',
          methods: {
            metadata: 'metadata(symbol = nil) => { symbol, schema_type, schema_property, description, regex, valid, invalid }',
            validators: 'validators() => [symbols]',
            fields: 'fields() => [symbols] (alias for validators)',
            examples: 'examples(symbol) => { valid: [...], invalid: [...] }',
            regex: 'regex(symbol) => regex or nil',
            validate: 'validate(symbol, value, cache: nil, cache_options: {}, json: false) => { valid: true/false, errors: [...] }',
            batch_validate: 'batch_validate(symbol, values) => { valid: true/false, results: [...] }',
            jsonld: 'jsonld(symbol, value) => JSON-LD string or nil'
          }
        }

        return info.to_json if json

        info
      end

      # Get metadata for all validators or a specific validator
      def self.metadata(symbol = nil)
        if symbol
          entry = RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES[symbol]
          return nil unless entry

          {
            symbol: symbol,
            schema_type: entry[:schema_type],
            schema_property: entry[:schema_property],
            description: entry[:description],
            regex: entry[:regex],
            valid: entry[:valid],
            invalid: entry[:invalid]
          }
        else
          RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES.transform_values do |entry|
            {
              symbol: entry[:symbol],
              schema_type: entry[:schema_type],
              schema_property: entry[:schema_property],
              description: entry[:description],
              regex: entry[:regex],
              valid: entry[:valid],
              invalid: entry[:invalid]
            }
          end
        end
      end

      # Get all validator symbols
      def self.validators
        RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES.keys
      end

      # Get validator fields (symbols)
      def self.fields
        validators
      end

      # Get examples for a validator
      def self.examples(symbol)
        entry = RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES[symbol]
        return nil unless entry

        {
          valid: entry[:valid],
          invalid: entry[:invalid]
        }
      end

      # Get regex for a validator
      def self.regex(symbol)
        entry = RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES[symbol]
        return nil unless entry && entry[:regex]

        RichTextExtraction::Core::Constants.resolve_validator_regex(symbol)
      end

      # Validate a value using a validator with loop detection and caching
      def self.validate(symbol, value, cache: nil, cache_options: {})
        # Check for potential infinite loop
        if loop_detected?(symbol, value)
          return { valid: false, errors: ['Validation loop detected - possible infinite recursion'] }
        end

        # Try to get cached result first
        cache_key = cache_key_for_validation(symbol, value)
        cached_result = get_cached_result(cache_key, cache)
        return cached_result if cached_result

        # Increment loop detection counter
        increment_loop_counter(symbol, value)

        # Perform validation
        result = validator_result(symbol, value)

        # Cache the result
        cache_result(cache_key, result, cache, cache_options)

        # Decrement loop detection counter
        decrement_loop_counter(symbol, value)

        result
      end

      # Batch validate multiple values
      def self.batch_validate(symbol, values)
        return { valid: false, errors: ['Values must be an array'] } unless values.is_a?(Array)

        results = values.map { |value| validate(symbol, value) }
        {
          valid: results.all? { |r| r[:valid] },
          results: results
        }
      end

      # Generate JSON-LD for a validated value
      def self.jsonld(symbol, value)
        RichTextExtraction::Core::Constants.to_jsonld(symbol, value)
      end

      def self.validator_result(symbol, value)
        entry = RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES[symbol]
        return { valid: false, errors: ['Validator not found'] } unless entry

        # Use the auto-loader to get or create the validator class
        klass = Validators::AutoLoader.get_validator_class(symbol)
        return { valid: false, errors: ['Validator not implemented'] } unless klass

        # Create a proper record object with errors (plain array)
        errors = []
        record = Struct.new(:value, :errors).new(value, errors)

        # Provide a simple add_error method for errors
        def record.add_error(attribute, message)
          self.errors << "#{attribute} #{message}"
        end

        # Create validator instance and validate
        validator = klass.new(attributes: [:value])
        # The validator should call record.add_error or record.errors << ...
        validator.validate_each(record, :value, value)

        { valid: errors.empty?, errors: errors }
      end

      # Generate cache key for validation result
      def self.cache_key_for_validation(symbol, value)
        "validator_result:#{symbol}:#{Digest::SHA256.hexdigest(value.to_s)}"
      end

      # Get cached validation result
      def self.get_cached_result(cache_key, cache)
        return nil unless cache

        begin
          cached = cache.read(cache_key)
          return cached if cached
        rescue StandardError => e
          log_debug("Cache read error: #{e.message}")
        end
        nil
      end

      # Cache validation result
      def self.cache_result(cache_key, result, cache, cache_options)
        return unless cache

        begin
          ttl = cache_options[:expires_in] || 1.hour
          cache.write(cache_key, result, expires_in: ttl)
        rescue StandardError => e
          log_debug("Cache write error: #{e.message}")
        end
      end

      # Check if a validation loop is detected
      def self.loop_detected?(symbol, value)
        cache = cache_store
        return false unless cache

        loop_key = loop_detection_key(symbol, value)
        attempts = cache.read(loop_key).to_i
        attempts >= MAX_VALIDATION_ATTEMPTS
      end

      # Increment loop detection counter
      def self.increment_loop_counter(symbol, value)
        cache = cache_store
        return unless cache

        loop_key = loop_detection_key(symbol, value)
        attempts = cache.read(loop_key).to_i + 1
        cache.write(loop_key, attempts, expires_in: LOOP_DETECTION_TTL)
      end

      # Decrement loop detection counter
      def self.decrement_loop_counter(symbol, value)
        cache = cache_store
        return unless cache

        loop_key = loop_detection_key(symbol, value)
        attempts = cache.read(loop_key).to_i - 1
        if attempts <= 0
          cache.delete(loop_key)
        else
          cache.write(loop_key, attempts, expires_in: LOOP_DETECTION_TTL)
        end
      end

      # Generate loop detection cache key
      def self.loop_detection_key(symbol, value)
        "#{LOOP_DETECTION_PREFIX}:#{symbol}:#{Digest::SHA256.hexdigest(value.to_s)}"
      end

      # Get cache store (Rails.cache or nil)
      def self.cache_store
        return ::Rails.cache if defined?(::Rails) && ::Rails.cache

        nil
      end

      # Log debug message if Rails logger is available
      def self.log_debug(message)
        return unless defined?(::Rails) && ::Rails.logger

        ::Rails.logger.debug("ValidatorAPI: #{message}")
      end
    end
  end
end
