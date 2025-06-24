# frozen_string_literal: true

module RichTextExtraction
  ##
  # Constants provides centralized regex patterns and common values used across RichTextExtraction.
  # This module helps maintain consistency and reduces duplication.
  #
  module Constants
    # Email regex pattern
    EMAIL_REGEX = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}\b/i

    # Phone number regex pattern
    PHONE_REGEX = /\b\+?\d[\d\s\-()]{7,}\b/

    # Date regex patterns (ISO and US formats)
    DATE_REGEX = %r{\b\d{4}-\d{2}-\d{2}\b|\b\d{2}/\d{2}/\d{4}\b}

    # Image file extensions
    IMAGE_EXTENSIONS = %w[jpg jpeg png gif svg webp].freeze

    # Attachment file extensions
    ATTACHMENT_EXTENSIONS = %w[pdf docx doc xlsx xls pptx ppt txt csv zip rar 7z].freeze

    # Image URL regex pattern
    IMAGE_REGEX = %r{https?://[^\s]+?\.(#{IMAGE_EXTENSIONS.join('|')})}

    # Attachment URL regex pattern
    ATTACHMENT_REGEX = %r{https?://[\w\-.?,'/\\+&%$#_=:()~]+\.(#{ATTACHMENT_EXTENSIONS.join('|')})}i

    # Twitter handle regex pattern
    TWITTER_REGEX = /@([A-Za-z0-9_]{1,15})/

    # Markdown link regex pattern
    MARKDOWN_LINK_REGEX = %r{\[([^\]]+)\]\((https?://[^)]+)\)}

    # Hashtag regex pattern
    HASHTAG_REGEX = /#(\w+)/

    # Mention regex pattern
    MENTION_REGEX = /@(\w+)/

    # Default cache TTL in seconds (1 hour)
    DEFAULT_CACHE_TTL = 3600

    # Default excerpt length
    DEFAULT_EXCERPT_LENGTH = 300

    # Default OpenGraph timeout in seconds
    DEFAULT_OPENGRAPH_TIMEOUT = 15

    # Default max redirects
    DEFAULT_MAX_REDIRECTS = 3

    # Default user agent
    DEFAULT_USER_AGENT = 'RichTextExtraction/1.0'

    # Default cache prefix
    DEFAULT_CACHE_PREFIX = 'rte'

    # Default cache store
    DEFAULT_CACHE_STORE = :memory_store
  end
end
