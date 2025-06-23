# frozen_string_literal: true

module RichTextExtraction
  ##
  # SocialExtractor provides methods for extracting social media content from text.
  # This module focuses on tags, mentions, and social media handles.
  #
  # @example
  #   include SocialExtractor
  #   tags = extract_tags("Hello #welcome #ruby")
  #   mentions = extract_mentions("Hello @alice @bob")
  #
  module SocialExtractor
    ##
    # Extracts #tags from text.
    #
    # @param text [String] The text to extract tags from
    # @return [Array<String>] Array of tags (without #)
    #
    def extract_tags(text)
      return [] unless text.is_a?(String)

      text.scan(/#(\w+)/).flatten.uniq
    end

    ##
    # Extracts @mentions from text.
    #
    # @param text [String] The text to extract mentions from
    # @return [Array<String>] Array of mentions (without @)
    #
    def extract_mentions(text)
      return [] unless text.is_a?(String)

      text.scan(/@(\w+)/).flatten.uniq
    end

    ##
    # Extracts Twitter handles from text.
    #
    # @param text [String] The text to extract Twitter handles from
    # @return [Array<String>] Array of Twitter handles (without @)
    #
    def extract_twitter_handles(text)
      return [] unless text.is_a?(String)

      text.scan(/@(\w+)/).flatten.uniq
    end

    ##
    # Extracts Instagram handles from text.
    #
    # @param text [String] The text to extract Instagram handles from
    # @return [Array<String>] Array of Instagram handles (without @)
    #
    def extract_instagram_handles(text)
      return [] unless text.is_a?(String)

      text.scan(/@(\w+)/).flatten.uniq
    end

    ##
    # Extracts hashtags with their context (surrounding text).
    #
    # @param text [String] The text to extract hashtags with context from
    # @param context_length [Integer] Number of characters around the hashtag
    # @return [Array<Hash>] Array of hashes with :tag and :context keys
    #
    def extract_tags_with_context(text, context_length = 50)
      return [] unless text.is_a?(String)

      text.scan(/#(\w+)/).flatten.uniq.map do |tag|
        {
          tag: tag,
          context: extract_context_for_tag(text, tag, context_length)
        }
      end
    end

    ##
    # Extracts mentions with their context (surrounding text).
    #
    # @param text [String] The text to extract mentions with context from
    # @param context_length [Integer] Number of characters around the mention
    # @return [Array<Hash>] Array of hashes with :mention and :context keys
    #
    def extract_mentions_with_context(text, context_length = 50)
      return [] unless text.is_a?(String)

      text.scan(/@(\w+)/).flatten.uniq.map do |mention|
        {
          mention: mention,
          context: extract_context_for_mention(text, mention, context_length)
        }
      end
    end

    ##
    # Validates if a string is a valid hashtag.
    #
    # @param tag [String] The hashtag to validate (with or without #)
    # @return [Boolean] True if valid hashtag, false otherwise
    #
    def valid_hashtag?(tag)
      return false unless tag.is_a?(String)

      !tag.empty? && tag.match?(/^\w+$/)
    end

    ##
    # Validates if a string is a valid mention.
    #
    # @param mention [String] The mention to validate (with or without @)
    # @return [Boolean] True if valid mention, false otherwise
    #
    def valid_mention?(mention)
      return false unless mention.is_a?(String)

      !mention.empty? && mention.match?(/^\w+$/)
    end

    private

    # Extract context around a hashtag
    #
    # @param text [String] The full text
    # @param tag [String] The hashtag to find context for
    # @param context_length [Integer] Number of characters around the tag
    # @return [String] The context string
    def extract_context_for_tag(text, tag, context_length)
      match = text.match(/#{tag}/)
      return text unless match

      start_pos = [match.begin(0) - context_length / 2, 0].max
      end_pos = [match.end(0) + context_length / 2, text.length].min
      text[start_pos...end_pos].strip
    end

    # Extract context around a mention
    #
    # @param text [String] The full text
    # @param mention [String] The mention to find context for
    # @param context_length [Integer] Number of characters around the mention
    # @return [String] The context string
    def extract_context_for_mention(text, mention, context_length)
      match = text.match(/@#{mention}/)
      return text unless match

      start_pos = [match.begin(0) - context_length / 2, 0].max
      end_pos = [match.end(0) + context_length / 2, text.length].min
      text[start_pos...end_pos].strip
    end
  end
end
