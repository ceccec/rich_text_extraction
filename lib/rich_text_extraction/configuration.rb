# frozen_string_literal: true

# RichTextExtraction provides a modular architecture for extracting rich text,
# Markdown, and OpenGraph metadata in Ruby and Rails applications.
module RichTextExtraction
  ##
  # Configuration provides centralized settings and defaults for RichTextExtraction.
  # This module allows users to customize behavior globally or per-instance.
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
    include CacheConfiguration

    ##
    # Whether caching is enabled globally.
    # @return [Boolean] Cache enabled
    #
    attr_accessor :cache_enabled

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
    # Default TTL (Time To Live) for cached items in seconds.
    # @return [Integer] Cache TTL in seconds
    #
    attr_accessor :cache_ttl

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
    # Initialize configuration with defaults.
    #
    def initialize
      initialize_caching_config
      initialize_general_config
    end

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
    def merge(options)
      to_h.merge(options)
    end

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
      "RichTextExtraction::Configuration(#{to_h})"
    end

    ##
    # @return [String] Inspect representation of configuration
    #
    def inspect
      "#<RichTextExtraction::Configuration #{to_h}>"
    end

    private

    ##
    # Initialize caching-related configuration.
    #
    def initialize_caching_config
      @cache_enabled = true
      @cache_store = :memory_store
      @cache_prefix = 'rte'
      @cache_ttl = 3600 # 1 hour
      @cache_compression = false
      @cache_key_strategy = :url
      @cache_key_generator = nil
      @default_cache_options = { expires_in: 3600 } # 1 hour
    end

    ##
    # Initialize general configuration options.
    #
    def initialize_general_config
      @opengraph_timeout = 15
      @sanitize_html = true
      @default_excerpt_length = 300
      @debug = false
      @user_agent = 'RichTextExtraction/1.0'
      @max_redirects = 3
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
  # @return [Hash] Current configuration as a hash
  #
  def self.config
    configuration.to_h
  end
end
