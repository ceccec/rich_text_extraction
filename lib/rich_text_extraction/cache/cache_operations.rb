# frozen_string_literal: true

module RichTextExtraction
  module Cache
    ##
    # CacheOperations provides caching functionality for RichTextExtraction.
    #
    # This module includes methods for caching OpenGraph data, managing cache keys,
    # and handling cache operations with different backends (Rails cache, memory, etc.).
    #
    module CacheOperations
      include RichTextExtraction::Core::Constants

      ##
      # Reads data from cache with support for Rails cache and custom cache objects.
      #
      # @param key [String] The cache key
      # @param cache [Hash, Symbol, nil] Cache object or :rails
      # @param cache_options [Hash] Cache options
      # @return [Object, nil] Cached data or nil if not found
      #
      def read_cache(key, cache, cache_options = {})
        return nil unless cache

        if use_rails_cache?(cache)
          rails_cache_read(key, cache_options)
        else
          cache[key]
        end
      end

      ##
      # Writes data to cache with support for Rails cache and custom cache objects.
      #
      # @param key [String] The cache key
      # @param data [Object] The data to cache
      # @param cache [Hash, Symbol, nil] Cache object or :rails
      # @param cache_options [Hash] Cache options
      # @return [Object] The cached data
      #
      def write_cache(key, data, cache, cache_options = {})
        return data unless cache

        if use_rails_cache?(cache)
          rails_cache_write(key, data, cache_options)
        else
          cache[key] = data
        end
        data
      end

      ##
      # Deletes data from cache with support for Rails cache and custom cache objects.
      #
      # @param key [String] The cache key
      # @param cache [Hash, Symbol, nil] Cache object or :rails
      # @param cache_options [Hash] Cache options
      # @return [Boolean] True if deleted, false otherwise
      #
      def delete_cache(key, cache, cache_options = {})
        return false unless cache

        if use_rails_cache?(cache)
          rails_cache_delete(key, cache_options)
        else
          cache.delete(key)
        end
      end

      ##
      # Builds a cache key with optional prefix.
      #
      # @param base_key [String] The base key
      # @param prefix [String, nil] Optional prefix
      # @return [String] The complete cache key
      #
      def build_cache_key(base_key, prefix = nil)
        prefix ? "opengraph:#{prefix}:#{base_key}" : base_key
      end

      ##
      # Resolves cache key prefix from options.
      #
      # @param cache_options [Hash] Cache options
      # @return [String, nil] The key prefix
      #
      def resolve_key_prefix(cache_options)
        key_prefix = cache_options[:key_prefix]
        if key_prefix.nil? && defined?(Rails) && Rails.respond_to?(:application)
          key_prefix = begin
            Rails.application.class.module_parent_name
          rescue StandardError
            nil
          end
        end
        key_prefix
      end

      ##
      # Checks if Rails cache should be used.
      #
      # @param cache [Hash, Symbol, nil] Cache object or :rails
      # @return [Boolean] True if Rails cache should be used
      #
      def use_rails_cache?(cache)
        cache == :rails && defined?(Rails) && Rails.respond_to?(:cache)
      end

      ##
      # Reads from Rails cache.
      #
      # @param key [String] The cache key
      # @param cache_options [Hash] Cache options
      # @return [Object, nil] Cached data or nil
      #
      def rails_cache_read(key, cache_options = {})
        return nil unless defined?(Rails) && Rails.respond_to?(:cache)

        Rails.cache.read(key, **cache_options.except(:key_prefix))
      end

      ##
      # Writes to Rails cache.
      #
      # @param key [String] The cache key
      # @param data [Object] The data to cache
      # @param cache_options [Hash] Cache options
      # @return [Object] The cached data
      #
      def rails_cache_write(key, data, cache_options = {})
        return data unless defined?(Rails) && Rails.respond_to?(:cache)

        Rails.cache.write(key, data, **cache_options.except(:key_prefix))
        data
      end

      ##
      # Deletes from Rails cache.
      #
      # @param key [String] The cache key
      # @param cache_options [Hash] Cache options
      # @return [Boolean] True if deleted, false otherwise
      #
      def rails_cache_delete(key, cache_options = {})
        return false unless defined?(Rails) && Rails.respond_to?(:cache)

        Rails.cache.delete(key, **cache_options.except(:key_prefix))
      end

      ##
      # Generates a cache key for OpenGraph data.
      #
      # @param url [String] The URL
      # @param prefix [String, nil] Optional prefix
      # @return [String] The cache key
      #
      def opengraph_cache_key(url, prefix = nil)
        build_cache_key(url, prefix)
      end

      ##
      # Clears cache entries for multiple URLs.
      #
      # @param urls [Array<String>] The URLs to clear cache for
      # @param cache [Hash, Symbol, nil] Cache object or :rails
      # @param cache_options [Hash] Cache options
      # @return [Array<Boolean>] Array of deletion results
      #
      def clear_cache_for_urls(urls, cache, cache_options = {})
        prefix = resolve_key_prefix(cache_options)
        urls.map { |url| delete_cache(opengraph_cache_key(url, prefix), cache, cache_options) }
      end

      ##
      # Resolves the key prefix for OpenGraph cache operations.
      # This method provides backward compatibility with existing code.
      #
      # @param cache_options [Hash] Cache options
      # @return [String, nil] The key prefix
      #
      def opengraph_key_prefix(cache_options)
        resolve_key_prefix(cache_options)
      end
    end
  end
end
