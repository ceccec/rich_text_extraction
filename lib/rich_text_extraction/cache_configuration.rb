# frozen_string_literal: true

module RichTextExtraction
  ##
  # Cache configuration mixin for RichTextExtraction::Configuration
  # Provides cache-related configuration methods and utilities.
  #
  module CacheConfiguration
    ##
    # Generate cache key for a URL.
    #
    # @param url [String] The URL to generate a key for
    # @param options [Hash] Additional options
    # @return [String] Cache key
    #
    def generate_cache_key(url, options = {})
      strategy = options[:key_strategy] || @cache_key_strategy
      generate_key_by_strategy(url, strategy, options)
    end

    ##
    # Get cache options with defaults applied.
    #
    # @param options [Hash] User-provided options
    # @return [Hash] Merged cache options
    #
    def cache_options(options = {})
      default_opts = {
        expires_in: @cache_ttl,
        compress: @cache_compression
      }.merge(@default_cache_options)

      default_opts.merge(options)
    end

    ##
    # Check if caching is enabled and available.
    #
    # @return [Boolean] Whether caching is available
    #
    def caching_available?
      return false unless @cache_enabled

      if defined?(Rails) && Rails.respond_to?(:cache)
        Rails.cache.present?
      else
        true # Assume available if no Rails
      end
    end

    private

    ##
    # Generate cache key based on strategy.
    #
    # @param url [String] The URL
    # @param strategy [Symbol] Key generation strategy
    # @param options [Hash] Additional options
    # @return [String] Cache key
    #
    def generate_key_by_strategy(url, strategy, options)
      case strategy
      when :url
        generate_url_key(url)
      when :hash
        generate_hash_key(url)
      when :custom
        generate_custom_key(url, options)
      else
        generate_url_key(url)
      end
    end

    ##
    # Generate URL-based cache key.
    #
    # @param url [String] The URL
    # @return [String] Cache key
    #
    def generate_url_key(url)
      "#{@cache_prefix}:opengraph:#{url}"
    end

    ##
    # Generate hash-based cache key.
    #
    # @param url [String] The URL
    # @return [String] Cache key
    #
    def generate_hash_key(url)
      require 'digest'
      hash = Digest::MD5.hexdigest(url)
      "#{@cache_prefix}:opengraph:#{hash}"
    end

    ##
    # Generate custom cache key.
    #
    # @param url [String] The URL
    # @param options [Hash] Additional options
    # @return [String] Cache key
    #
    def generate_custom_key(url, options)
      if @cache_key_generator.respond_to?(:call)
        @cache_key_generator.call(url, options)
      else
        generate_url_key(url)
      end
    end
  end
end
