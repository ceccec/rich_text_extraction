# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'

# RichTextExtraction provides a modular architecture for extracting rich text,
# Markdown, and OpenGraph metadata in Ruby and Rails applications.
module RichTextExtraction
  module Core
    ##
    # Configuration provides a centralized way to manage RichTextExtraction settings.
    #
    # This module allows users to configure various aspects of the gem's behavior,
    # including cache settings, OpenGraph timeouts, excerpt lengths, and more.
    #
    # @example
    #   RichTextExtraction.configure do |config|
    #     config.default_cache_options = { expires_in: 1.hour }
    #     config.opengraph_timeout = 10
    #   end
    #
    # Configuration class for RichTextExtraction
    #
    # @example Basic configuration
    #   RichTextExtraction.configure do |config|
    #     config.opengraph_timeout = 15
    #     config.sanitize_html = true
    #   end
    #
    # @example Advanced configuration with caching
    #   RichTextExtraction.configure do |config|
    #     config.opengraph_timeout = 30
    #     config.sanitize_html = true
    #     config.default_excerpt_length = 500
    #     config.cache_enabled = true
    #     config.cache_store = :redis_cache_store
    #     config.cache_prefix = 'rte'
    #     config.cache_ttl = 2.hours
    #     config.cache_compression = true
    #     config.default_cache_options = { expires_in: 2.hours }
    #     config.debug = Rails.env.development?
    #     config.user_agent = 'MyApp/1.0'
    #   end
    class Configuration
      include RichTextExtraction::Cache::CacheConfiguration
      include RichTextExtraction::Core::Constants

      attr_accessor :cache_enabled, :cache_ttl, :validation_enabled, :extraction_timeout

      def initialize(options = {})
        @cache_enabled = options.fetch(:cache_enabled, true)
        @cache_ttl = options.fetch(:cache_ttl, 3600)
        @validation_enabled = options.fetch(:validation_enabled, true)
        @extraction_timeout = options.fetch(:extraction_timeout, 15)

        validate_options(options)
      end

      def cache_enabled?
        @cache_enabled
      end

      def validation_enabled?
        @validation_enabled
      end

      def to_hash
        {
          cache_enabled: @cache_enabled,
          cache_ttl: @cache_ttl,
          validation_enabled: @validation_enabled,
          extraction_timeout: @extraction_timeout
        }
      end

      ##
      # Cache store to use (Rails cache store symbol or object).
      # @return [Symbol, Object] Cache store
      #
      attr_accessor :cache_store

      ##
      # Cache key prefix for namespacing.
      # @return [String] Cache prefix
      #
      attr_accessor :cache_prefix

      ##
      # Whether to compress cached data.
      # @return [Boolean] Cache compression
      #
      attr_accessor :cache_compression

      ##
      # Cache key generation strategy (:url, :hash, :custom).
      # @return [Symbol] Cache key strategy
      #
      attr_accessor :cache_key_strategy

      ##
      # Custom cache key generator proc.
      # @return [Proc, nil] Custom key generator
      #
      attr_accessor :cache_key_generator

      ##
      # Default cache options for OpenGraph data.
      # @return [Hash] Cache options
      #
      attr_accessor :default_cache_options

      ##
      # Timeout for OpenGraph HTTP requests in seconds.
      # @return [Integer] Timeout in seconds
      #
      attr_accessor :opengraph_timeout

      ##
      # Whether to sanitize HTML output by default.
      # @return [Boolean] Sanitize HTML
      #
      attr_accessor :sanitize_html

      ##
      # Default excerpt length for text truncation.
      # @return [Integer] Excerpt length
      #
      attr_accessor :default_excerpt_length

      ##
      # Whether to enable debug logging.
      # @return [Boolean] Debug mode
      #
      attr_accessor :debug

      ##
      # Custom user agent for HTTP requests.
      # @return [String] User agent string
      #
      attr_accessor :user_agent

      ##
      # Maximum number of redirects to follow.
      # @return [Integer] Max redirects
      #
      attr_accessor :max_redirects

      ##
      # Allowed CORS origins for the API (string or array, '*' for all)
      attr_accessor :api_cors_origins

      ##
      # Rate limiting config: { limit: Integer, period: ActiveSupport::Duration }
      attr_accessor :api_rate_limit

      ##
      # Custom CORS headers for the API
      attr_accessor :api_cors_headers

      ##
      # Custom CORS methods for the API
      attr_accessor :api_cors_methods

      ##
      # Per-user rate limiting config: { limit: Integer, period: ActiveSupport::Duration }
      attr_accessor :api_rate_limit_per_user

      ##
      # Per-endpoint rate limiting config: { '/path' => { limit: Integer, period: ... } }
      attr_accessor :api_rate_limit_per_endpoint

      ##
      # Reset configuration to defaults.
      #
      def reset!
        initialize
      end

      ##
      # Merge configuration with provided options.
      #
      # @param options [Hash] Options to merge
      # @return [Hash] Merged configuration
      #
      delegate :merge, to: :to_h

      ##
      # Convert configuration to hash.
      #
      # @return [Hash] Configuration as hash
      #
      def to_h
        caching_config_hash.merge(general_config_hash)
      end

      ##
      # @return [String] String representation of configuration
      #
      def to_s
        "RichTextExtraction::Core::Configuration(#{to_h})"
      end

      ##
      # @return [String] Inspect representation of configuration
      #
      def inspect
        "#<RichTextExtraction::Core::Configuration #{to_h}>"
      end

      private

      def validate_options(options)
        validate_cache_enabled(options[:cache_enabled]) if options.key?(:cache_enabled)
        validate_cache_ttl(options[:cache_ttl]) if options.key?(:cache_ttl)
        validate_validation_enabled(options[:validation_enabled]) if options.key?(:validation_enabled)
        validate_extraction_timeout(options[:extraction_timeout]) if options.key?(:extraction_timeout)
      end

      def validate_cache_enabled(value)
        return if [true, false].include?(value)

        raise ArgumentError, 'cache_enabled must be true or false'
      end

      def validate_cache_ttl(value)
        return if value.is_a?(Integer) && value.positive?

        raise ArgumentError, 'cache_ttl must be a positive integer'
      end

      def validate_validation_enabled(value)
        return if [true, false].include?(value)

        raise ArgumentError, 'validation_enabled must be true or false'
      end

      def validate_extraction_timeout(value)
        return if value.is_a?(Integer) && value.positive?

        raise ArgumentError, 'extraction_timeout must be a positive integer'
      end

      ##
      # Initialize caching-related configuration.
      #
      def initialize_caching_config
        @cache_store = DEFAULT_CACHE_STORE
        @cache_prefix = DEFAULT_CACHE_PREFIX
        @cache_compression = false
        @cache_key_strategy = :url
        @cache_key_generator = nil
        @default_cache_options = { expires_in: DEFAULT_CACHE_TTL }
      end

      ##
      # Initialize general configuration options.
      #
      def initialize_general_config
        @opengraph_timeout = DEFAULT_OPENGRAPH_TIMEOUT
        @sanitize_html = true
        @default_excerpt_length = DEFAULT_EXCERPT_LENGTH
        @debug = false
        @user_agent = DEFAULT_USER_AGENT
        @max_redirects = DEFAULT_MAX_REDIRECTS
      end

      ##
      # Build caching configuration hash.
      #
      # @return [Hash] Caching configuration
      #
      def caching_config_hash
        {
          cache_enabled: @cache_enabled,
          cache_store: @cache_store,
          cache_prefix: @cache_prefix,
          cache_ttl: @cache_ttl,
          cache_compression: @cache_compression,
          cache_key_strategy: @cache_key_strategy,
          cache_key_generator: @cache_key_generator
        }
      end

      ##
      # Build general configuration hash.
      #
      # @return [Hash] General configuration
      #
      def general_config_hash
        base_config.merge(api_config)
      end

      ##
      # Build base configuration hash.
      #
      # @return [Hash] Base configuration
      #
      def base_config
        {
          default_cache_options: @default_cache_options,
          opengraph_timeout: @opengraph_timeout,
          sanitize_html: @sanitize_html,
          default_excerpt_length: @default_excerpt_length,
          debug: @debug,
          user_agent: @user_agent,
          max_redirects: @max_redirects
        }
      end

      ##
      # Build API configuration hash.
      #
      # @return [Hash] API configuration
      #
      def api_config
        {
          api_cors_origins: @api_cors_origins,
          api_rate_limit: @api_rate_limit,
          api_cors_headers: @api_cors_headers,
          api_cors_methods: @api_cors_methods,
          api_rate_limit_per_user: @api_rate_limit_per_user,
          api_rate_limit_per_endpoint: @api_rate_limit_per_endpoint
        }
      end
    end

    ##
    # Class-level configuration instance.
    # @return [Configuration] Configuration instance
    #
    def self.configuration
      @configuration ||= Configuration.new
    end

    ##
    # Configure RichTextExtraction with a block.
    #
    # @yield [config] Configuration instance
    # @yieldparam config [Configuration] Configuration to modify
    #
    # @example
    #   RichTextExtraction.configure do |config|
    #     config.opengraph_timeout = 15
    #     config.sanitize_html = false
    #   end
    #
    def self.configure
      yield(configuration) if block_given?
    end

    ##
    # Reset configuration to defaults.
    #
    def self.reset_configuration!
      @configuration = Configuration.new
    end

    ##
    # Returns the configuration object (not a hash)
    def self.config
      configuration
    end

    ##
    # Returns the configuration as a hash
    def self.config_hash
      configuration.to_h
    end
  end
end
