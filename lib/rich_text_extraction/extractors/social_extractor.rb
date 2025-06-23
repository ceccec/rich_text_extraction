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
      text.scan(/#(\w+)/).flatten
    end

    ##
    # Extracts @mentions from text.
    #
    # @param text [String] The text to extract mentions from
    # @return [Array<String>] Array of mentions (without @)
    #
    def extract_mentions(text)
      text.scan(/@(\w+)/).flatten
    end

    ##
    # Extracts Twitter handles from text.
    #
    # @param text [String] The text to extract Twitter handles from
    # @return [Array<String>] Array of Twitter handles (without @)
    #
    def extract_twitter_handles(text)
      twitter_regex = /@([A-Za-z0-9_]{1,15})/
      text.scan(twitter_regex).flatten.uniq
    end

    ##
    # Extracts Instagram handles from text.
    #
    # @param text [String] The text to extract Instagram handles from
    # @return [Array<String>] Array of Instagram handles (without @)
    #
    def extract_instagram_handles(text)
      instagram_regex = /@([A-Za-z0-9._]{1,30})/
      text.scan(instagram_regex).flatten.uniq
    end

    ##
    # Extracts hashtags with their context (surrounding text).
    #
    # @param text [String] The text to extract hashtags with context from
    # @param context_length [Integer] Number of characters around the hashtag
    # @return [Array<Hash>] Array of hashes with :tag and :context keys
    #
    def extract_tags_with_context(text, context_length = 50)
      text.scan(/#(\w+)/).map do |match|
        tag = match[0]
        start_pos = text.index("##{tag}")
        end_pos = start_pos + tag.length + 1
        
        context_start = [0, start_pos - context_length].max
        context_end = [text.length, end_pos + context_length].min
        
        {
          tag: tag,
          context: text[context_start...context_end].strip
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
      text.scan(/@(\w+)/).map do |match|
        mention = match[0]
        start_pos = text.index("@#{mention}")
        end_pos = start_pos + mention.length + 1
        
        context_start = [0, start_pos - context_length].max
        context_end = [text.length, end_pos + context_length].min
        
        {
          mention: mention,
          context: text[context_start...context_end].strip
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
      tag = tag.sub(/^#/, '') if tag.start_with?('#')
      tag.match?(/^[A-Za-z0-9_]+$/) && tag.length.between?(1, 50)
    end

    ##
    # Validates if a string is a valid mention.
    #
    # @param mention [String] The mention to validate (with or without @)
    # @return [Boolean] True if valid mention, false otherwise
    #
    def valid_mention?(mention)
      mention = mention.sub(/^@/, '') if mention.start_with?('@')
      mention.match?(/^[A-Za-z0-9_]+$/) && mention.length.between?(1, 30)
    end
  end
end 