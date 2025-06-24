# frozen_string_literal: true

require 'json'

module RichTextExtraction
  module ValidatorAPI
    # Integrated help for the public API
    # Usage: RichTextExtraction::ValidatorAPI.help or RichTextExtraction::ValidatorAPI.help(json: true)
    def self.help(json: false)
      info = {
        description: 'RichTextExtraction::ValidatorAPI provides public methods for validator metadata, examples, regex, and validation (with optional caching).',
        methods: {
          validate: 'validate(symbol, value, cache: nil, cache_options: {}, json: false) => { valid: true/false, errors: [...] }',
          examples: 'examples(symbol, json: false) => { valid: [...], invalid: [...] }',
          regex: 'regex(symbol, json: false) => regex string or nil',
          metadata: 'metadata(symbol, json: false) => metadata hash',
          help: 'help(json: false) => this help info'
        },
        options: {
          cache: 'Optional cache object (defaults to Rails.cache if available)',
          cache_options: 'Optional cache options (defaults to config if available)',
          json: 'If true, output is JSON (Linux-style: --json)'
        },
        example: {
          ruby: "RichTextExtraction::ValidatorAPI.validate(:isbn, '978-3-16-148410-0', json: true)",
          shell: 'irb -r ./lib/rich_text_extraction.rb'
        }
      }
      json ? JSON.pretty_generate(info) : info
    end

    # Validate a value for a given validator symbol, with optional request->response caching.
    #
    # @param symbol [Symbol] Validator symbol (e.g., :isbn)
    # @param value [String] Value to validate
    # @param cache [Object, nil] Optional cache object (defaults to Rails.cache if available)
    # @param cache_options [Hash] Optional cache options (defaults to config if available)
    # @param json [Boolean] If true, output is JSON (Linux-style: --json)
    # @return [Hash] { valid: true/false, errors: [...] }
    def self.validate(symbol, value, cache: nil, cache_options: {}, json: false)
      cache ||= default_cache
      cache_options = merged_cache_options(cache_options)
      cache_key = "validator:#{symbol}:#{value}"
      if cache
        cached = cache_read(cache, cache_key)
        return json ? JSON.generate(cached) : cached if cached
      end
      result = validator_result(symbol, value)
      cache_write(cache, cache_key, result, cache_options)
      json ? JSON.generate(result) : result
    end

    private

    def self.default_cache
      defined?(Rails) && Rails.respond_to?(:cache) ? Rails.cache : nil
    end

    def self.merged_cache_options(cache_options)
      config = defined?(RichTextExtraction) && RichTextExtraction.respond_to?(:configuration) ? RichTextExtraction.configuration : nil
      default_cache_options = (config.respond_to?(:cache_options) ? config.cache_options : {})
      default_cache_options.merge(cache_options)
    end

    def self.cache_read(cache, key)
      cache.read(key)
    rescue StandardError
      nil
    end

    def self.cache_write(cache, key, value, options)
      cache&.write(key, value, **options)
    rescue StandardError
      nil
    end

    def self.validator_result(symbol, value)
      entry = Constants::VALIDATOR_EXAMPLES[symbol]
      return { valid: false, errors: ['Validator not found'] } unless entry
      klass = begin
        Object.const_get("#{symbol.to_s.camelize}Validator")
      rescue StandardError
        nil
      end
      return { valid: false, errors: ['Validator not implemented'] } unless klass
      record = Struct.new(:value, :errors).new(value, ActiveModel::Errors.new(nil))
      klass.new(attributes: [:value]).validate_each(record, :value, value)
      { valid: record.errors.empty?, errors: record.errors.full_messages }
    end

    def self.examples(symbol, json: false)
      entry = Constants::VALIDATOR_EXAMPLES[symbol]
      result = entry ? { valid: entry[:valid], invalid: entry[:invalid] } : { valid: [], invalid: [] }
      json ? JSON.generate(result) : result
    end

    def self.regex(symbol, json: false)
      entry = Constants::VALIDATOR_EXAMPLES[symbol]
      result = entry && entry[:regex]
      json ? JSON.generate({ regex: result }) : result
    end

    def self.metadata(symbol, json: false)
      result = Constants::VALIDATOR_EXAMPLES[symbol]
      json ? JSON.generate(result) : result
    end

    def self.batch_validate(symbol, values, cache: nil, cache_options: {}, json: false)
      results = values.map { |v| validate(symbol, v, cache: cache, cache_options: cache_options) }
      json ? JSON.generate(results) : results
    end
  end
end
