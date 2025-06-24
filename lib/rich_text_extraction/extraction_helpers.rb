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
    include CacheOperations

    # Extracts URLs from text and strips trailing punctuation.
    # @param text [String]
    # @return [Array<String>] Array of URLs
    def extract_links(text)
      return [] unless text.is_a?(String)

      URI.extract(text, %w[http https]).map { |url| url.sub(/[.,!?:;]+$/, '') }
    end

    # Extracts @mentions from text.
    # @param text [String]
    # @return [Array<String>] Array of mentions (without @)
    def extract_mentions(text)
      return [] unless text.is_a?(String)

      text.scan(/@(\w+)/).flatten
    end

    # Extracts #tags from text.
    # @param text [String]
    # @return [Array<String>] Array of tags (without #)
    def extract_tags(text)
      return [] unless text.is_a?(String)

      text.scan(/#(\w+)/).flatten
    end

    # Fetches and parses OpenGraph metadata from a URL, with optional caching.
    # @param url [String]
    # @param cache [Hash, Symbol, nil] Optional cache object or :rails
    # @param cache_options [Hash] Options for cache (e.g., :expires_in, :key_prefix)
    # @return [Hash] OpenGraph metadata or error
    def extract_opengraph(url, cache: nil, cache_options: {})
      key_prefix = opengraph_key_prefix(cache_options)
      cached = read_cache(opengraph_cache_key(url, key_prefix), cache, cache_options)
      return cached if cached

      og_data = fetch_opengraph_data(url)
      write_cache(opengraph_cache_key(url, key_prefix), og_data, cache, cache_options)
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

    # Fetches OpenGraph data from a URL using HTTParty.
    # @param url [String]
    # @return [Hash] OpenGraph metadata
    def fetch_opengraph_data(url)
      response = HTTParty.get(url, timeout: RichTextExtraction.configuration.opengraph_timeout)
      return { error: 'HTTP request failed' } unless response.success?

      doc = Nokogiri::HTML(response.body)
      build_opengraph_data(doc, url)
    end

    # Builds OpenGraph data hash from parsed HTML document.
    # @param doc [Nokogiri::HTML::Document]
    # @param url [String]
    # @return [Hash] OpenGraph metadata
    def build_opengraph_data(doc, url)
      {
        'title' => extract_og_title(doc),
        'description' => extract_og_description(doc),
        'image' => extract_og_image(doc),
        'url' => extract_og_url(doc, url),
        'site_name' => extract_og_site_name(doc),
        'type' => extract_og_type(doc)
      }
    end

    # Extracts OpenGraph title from HTML document.
    # @param doc [Nokogiri::HTML::Document]
    # @return [String, nil]
    def extract_og_title(doc)
      doc.at_css('meta[property="og:title"]')&.[]('content') ||
        doc.at_css('title')&.text
    end

    # Extracts OpenGraph description from HTML document.
    # @param doc [Nokogiri::HTML::Document]
    # @return [String, nil]
    def extract_og_description(doc)
      doc.at_css('meta[property="og:description"]')&.[]('content') ||
        doc.at_css('meta[name="description"]')&.[]('content')
    end

    # Extracts OpenGraph image from HTML document.
    # @param doc [Nokogiri::HTML::Document]
    # @return [String, nil]
    def extract_og_image(doc)
      doc.at_css('meta[property="og:image"]')&.[]('content')
    end

    # Extracts OpenGraph URL from HTML document.
    # @param doc [Nokogiri::HTML::Document]
    # @param fallback_url [String]
    # @return [String]
    def extract_og_url(doc, fallback_url)
      doc.at_css('meta[property="og:url"]')&.[]('content') || fallback_url
    end

    # Extracts OpenGraph site name from HTML document.
    # @param doc [Nokogiri::HTML::Document]
    # @return [String, nil]
    def extract_og_site_name(doc)
      doc.at_css('meta[property="og:site_name"]')&.[]('content')
    end

    # Extracts OpenGraph type from HTML document.
    # @param doc [Nokogiri::HTML::Document]
    # @return [String, nil]
    def extract_og_type(doc)
      doc.at_css('meta[property="og:type"]')&.[]('content')
    end
  end
end
