# frozen_string_literal: true

module RichTextExtraction
  ##
  # ExtractionHelpers provides reusable extraction methods for links, tags, mentions, and OpenGraph data.
  # These helpers are included in Extractor and available to the main RichTextExtraction module.
  #
  # @see RichTextExtraction::Extractor
  # @see RichTextExtraction
  #
  module ExtractionHelpers
    # Extracts URLs from text and strips trailing punctuation.
    # @param text [String]
    # @return [Array<String>] Array of URLs
    def extract_links(text)
      URI.extract(text, %w[http https]).map { |url| url.sub(/[.,!?:;]+$/, '') }
    end

    # Extracts @mentions from text.
    # @param text [String]
    # @return [Array<String>] Array of mentions (without @)
    def extract_mentions(text)
      text.scan(/@(\w+)/).flatten
    end

    # Extracts #tags from text.
    # @param text [String]
    # @return [Array<String>] Array of tags (without #)
    def extract_tags(text)
      text.scan(/#(\w+)/).flatten
    end

    # Fetches and parses OpenGraph metadata from a URL, with optional caching.
    # @param url [String]
    # @param cache [Hash, Symbol, nil] Optional cache object or :rails
    # @param cache_options [Hash] Options for cache (e.g., :expires_in, :key_prefix)
    # @return [Hash] OpenGraph metadata or error
    def extract_opengraph(url, cache: nil, cache_options: {})
      key_prefix = opengraph_key_prefix(cache_options)
      cached = opengraph_read_cache(url, cache, cache_options, key_prefix)
      return cached if cached

      og_data = fetch_opengraph_data(url)
      opengraph_write_cache(url, og_data, cache, cache_options, key_prefix)
      og_data
    rescue StandardError => e
      { error: e.message }
    end

    private

    def opengraph_key_prefix(cache_options)
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

    def opengraph_read_cache(url, cache, cache_options, key_prefix)
      return opengraph_rails_cache_read(url, cache_options, key_prefix) if opengraph_use_rails_cache?(cache)

      cache[url] if cache && cache != :rails && cache[url]
    end

    def opengraph_use_rails_cache?(cache)
      cache == :rails && defined?(Rails) && Rails.respond_to?(:cache)
    end

    def opengraph_rails_cache_read(url, cache_options, key_prefix)
      cache_key = key_prefix ? "opengraph:#{key_prefix}:#{url}" : url
      Rails.cache.read(cache_key, **cache_options.except(:key_prefix))
    end

    def opengraph_write_cache(url, og_data, cache, cache_options, key_prefix)
      if cache == :rails && defined?(Rails) && Rails.respond_to?(:cache)
        cache_key = key_prefix ? "opengraph:#{key_prefix}:#{url}" : url
        Rails.cache.write(cache_key, og_data, **cache_options.except(:key_prefix))
      elsif cache && cache != :rails
        cache[url] = og_data
      end
    end

    def fetch_opengraph_data(url)
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
