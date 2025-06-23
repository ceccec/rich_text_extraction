# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

module RichTextExtraction
  ##
  # OpenGraphService handles fetching and caching OpenGraph metadata from URLs.
  # This service encapsulates all OpenGraph-related operations for better separation of concerns.
  #
  # @example
  #   service = OpenGraphService.new
  #   og_data = service.extract('https://example.com', cache: :rails)
  #
  class OpenGraphService
    ##
    # Fetches and parses OpenGraph metadata from a URL, with optional caching.
    #
    # @param url [String] The URL to extract OpenGraph data from
    # @param cache [Hash, Symbol, nil] Optional cache object or :rails
    # @param cache_options [Hash] Options for cache (e.g., :expires_in, :key_prefix)
    # @return [Hash] OpenGraph metadata or error information
    #
    def extract(url, cache: nil, cache_options: {})
      key_prefix = resolve_key_prefix(cache_options)
      cached = read_cache(url, cache, cache_options, key_prefix)
      return cached if cached

      og_data = fetch_data(url)
      write_cache(url, og_data, cache, cache_options, key_prefix)
      og_data
    rescue StandardError => e
      { error: e.message }
    end

    ##
    # Clears OpenGraph cache entries for a specific URL.
    #
    # @param url [String] The URL to clear cache for
    # @param cache [Hash, Symbol, nil] Cache object or :rails
    # @param cache_options [Hash] Cache options
    #
    def clear_cache(url, cache: nil, cache_options: {})
      key_prefix = resolve_key_prefix(cache_options)
      delete_cache_entry(url, cache, cache_options, key_prefix)
    end

    private

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

    def read_cache(url, cache, cache_options, key_prefix)
      return rails_cache_read(url, cache_options, key_prefix) if use_rails_cache?(cache)

      cache[url] if cache && cache != :rails && cache[url]
    end

    def use_rails_cache?(cache)
      cache == :rails && defined?(Rails) && Rails.respond_to?(:cache)
    end

    def rails_cache_read(url, cache_options, key_prefix)
      cache_key = build_cache_key(url, key_prefix)
      Rails.cache.read(cache_key, **cache_options.except(:key_prefix))
    end

    def write_cache(url, og_data, cache, cache_options, key_prefix)
      if use_rails_cache?(cache)
        cache_key = build_cache_key(url, key_prefix)
        Rails.cache.write(cache_key, og_data, **cache_options.except(:key_prefix))
      elsif cache && cache != :rails
        cache[url] = og_data
      end
    end

    def delete_cache_entry(url, cache, cache_options, key_prefix)
      if use_rails_cache?(cache)
        cache_key = build_cache_key(url, key_prefix)
        Rails.cache.delete(cache_key, **cache_options.except(:key_prefix))
      elsif cache && cache != :rails
        cache.delete(url)
      end
    end

    def build_cache_key(url, key_prefix)
      key_prefix ? "opengraph:#{key_prefix}:#{url}" : url
    end

    def fetch_data(url)
      response = HTTParty.get(url)
      return {} unless response.success?

      doc = Nokogiri::HTML(response.body)
      og_data = {}
      doc.css('meta[property^="og:"]').each do |meta|
        property = meta.attr('property')
        content = meta.attr('content')
        og_data[property.sub('og:', '')] = content if property && content
      end
      og_data
    end
  end
end 