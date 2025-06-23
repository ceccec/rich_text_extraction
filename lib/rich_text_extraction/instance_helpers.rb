# frozen_string_literal: true

module RichTextExtraction
  ##
  # InstanceHelpers provides instance-level extraction and utility methods for rich text content.
  # These are included in RichTextExtraction and available to ActionText::RichText and other consumers.
  #
  # @see RichTextExtraction
  #
  module InstanceHelpers
    # Returns the plain text representation.
    # @return [String]
    def plain_text
      to_plain_text
    end

    # Extracts all links from the plain text.
    # @return [Array<String>]
    def links
      extract_links(plain_text)
    end

    # Extracts all tags from the plain text.
    # @return [Array<String>]
    def tags
      extract_tags(plain_text)
    end

    # Extracts all mentions from the plain text.
    # @return [Array<String>]
    def mentions
      extract_mentions(plain_text)
    end

    # Extracts all emails from the plain text.
    # @return [Array<String>]
    def emails
      email_regex = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}\b/i
      plain_text.scan(email_regex)
    end

    # Returns a truncated excerpt of the plain text.
    # @param length [Integer]
    # @return [String]
    def excerpt(length = 200)
      text = plain_text
      text.length > length ? "#{text[0...length].rstrip}…" : text
    end

    # Extracts all attachment URLs from the plain text.
    # @return [Array<String>]
    def attachments
      attachment_regex = %r{https?://[\w\-.?,'/\\+&%$#_=:()~]+\.(pdf|docx?|xlsx?|pptx?|jpg|jpeg|png|gif|svg)}i
      plain_text.scan(attachment_regex).map { |match| match.is_a?(Array) ? match[0] : match }
    end

    # Extracts all phone numbers from the plain text.
    # @return [Array<String>]
    def phone_numbers
      phone_regex = /\b\+?\d[\d\s\-()]{7,}\b/
      plain_text.scan(phone_regex)
    end

    # Extracts all dates from the plain text.
    # @return [Array<String>]
    def dates
      date_regex = %r{\b\d{4}-\d{2}-\d{2}\b|\b\d{2}/\d{2}/\d{4}\b}
      plain_text.scan(date_regex)
    end

    # Extracts all Markdown links from the plain text.
    # @return [Array<Hash>]
    def markdown_links
      md_link_regex = %r{\[([^\]]+)\]\((https?://[^)]+)\)}
      plain_text.scan(md_link_regex).map { |text, url| { text: text, url: url } }
    end

    # Extracts all image URLs from the plain text.
    # @return [Array<String>]
    def image_urls
      image_regex = %r{https?://[^\s]+?\.(jpg|jpeg|png|gif|svg)}
      plain_text.scan(image_regex).map { |match| match.is_a?(Array) ? match[0] : match }
    end

    # Extracts all Twitter handles from the plain text.
    # @return [Array<String>]
    def twitter_handles
      twitter_regex = /@([A-Za-z0-9_]{1,15})/
      plain_text.scan(twitter_regex).flatten.uniq
    end

    # Returns link objects, optionally with OpenGraph data.
    # @param with_opengraph [Boolean]
    # @param cache [Hash, Symbol, nil]
    # @param cache_options [Hash]
    # @return [Array<Hash>]
    def link_objects(with_opengraph: false, cache: nil, cache_options: {})
      if with_opengraph
        extract_links(plain_text).map do |url|
          { url: url, opengraph: extract_opengraph(url, cache: cache, cache_options: cache_options) }
        end
      else
        extract_links(plain_text).map { |url| { url: url } }
      end
    end
  end
end
