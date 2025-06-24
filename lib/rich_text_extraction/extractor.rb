# frozen_string_literal: true

require_relative 'extraction_helpers'

module RichTextExtraction
  ##
  # Extractor provides an object-oriented interface for extracting links, mentions, tags, and OpenGraph data from text.
  #
  # @see RichTextExtraction::ExtractionHelpers
  # @see RichTextExtraction
  #
  class Extractor
    include RichTextExtraction::ExtractionHelpers
    attr_reader :text

    # Initializes a new Extractor.
    # @param text [String] The text to extract from
    def initialize(text)
      @text = text
    end

    # Returns all links in the text.
    # @return [Array<String>]
    def links
      extract_links(text)
    end

    # Returns all @mentions in the text.
    # @return [Array<String>]
    def mentions
      extract_mentions(text)
    end

    # Returns all #tags in the text.
    # @return [Array<String>]
    def tags
      extract_tags(text)
    end

    # Returns an array of hashes for each link, optionally with OpenGraph data.
    # @param with_opengraph [Boolean]
    # @param cache [Hash, Symbol, nil]
    # @param cache_options [Hash]
    # @return [Array<Hash>]
    def link_objects(with_opengraph: false, cache: nil, cache_options: {})
      if with_opengraph
        links.map { |url| { url: url, opengraph: extract_opengraph(url, cache: cache, cache_options: cache_options) } }
      else
        links.map { |url| { url: url } }
      end
    end

    # Returns OpenGraph data for all links in the text.
    # @return [Array<Hash>]
    def opengraph_data_for_links
      links.map { |url| { url: url, opengraph: extract_opengraph(url) } }
    end

    def extract_links(text = nil)
      RichTextExtraction.extract(text || to_s, :links)
    end

    def extract_tags(text = nil)
      RichTextExtraction.extract(text || to_s, :hashtags)
    end

    def extract_mentions(text = nil)
      RichTextExtraction.extract(text || to_s, :mentions)
    end

    def extract_emails(text = nil)
      RichTextExtraction.extract(text || to_s, :emails)
    end

    def extract_phones(text = nil)
      RichTextExtraction.extract(text || to_s, :phones)
    end

    def extract_dates(text = nil)
      RichTextExtraction.extract(text || to_s, :dates)
    end

    def extract_images(text = nil)
      RichTextExtraction.extract(text || to_s, :images)
    end

    def extract_markdown_tables(text = nil)
      RichTextExtraction.extract(text || to_s, :markdown_tables)
    end

    def extract_markdown_code(text = nil)
      RichTextExtraction.extract(text || to_s, :markdown_code)
    end

    def extract_opengraph(url, cache: nil, cache_options: {})
      RichTextExtraction.extract_opengraph(url, cache: cache, cache_options: cache_options)
    end

    # Returns all emails in the text.
    # @return [Array<String>]
    def emails
      extract_emails(text)
    end
  end
end
