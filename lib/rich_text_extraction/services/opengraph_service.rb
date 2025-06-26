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
  # See spec/services/opengraph_service_spec.rb for tests of this class
  class OpenGraphService
    include RichTextExtraction::Cache::CacheOperations

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
      cache_key = build_cache_key(url, key_prefix)
      cached = read_cache(cache_key, cache, cache_options)
      return cached if cached

      og_data = fetch_data(url)
      write_cache(cache_key, og_data, cache, cache_options)
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
      cache_key = build_cache_key(url, key_prefix)
      delete_cache(cache_key, cache, cache_options)
    end

    private

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
