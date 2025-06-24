# frozen_string_literal: true

require 'redcarpet'
require_relative 'rich_text_extraction/version'
require_relative 'rich_text_extraction/constants'
require_relative 'rich_text_extraction/extraction_patterns'
require_relative 'rich_text_extraction/cache_operations'
require_relative 'rich_text_extraction/cache_configuration'
require_relative 'rich_text_extraction/configuration'
require_relative 'rich_text_extraction/services/opengraph_service'
require_relative 'rich_text_extraction/services/markdown_service'
require_relative 'rich_text_extraction/extractors/link_extractor'
require_relative 'rich_text_extraction/extractors/social_extractor'
require 'erb'
require 'uri'
require 'nokogiri'
require 'httparty'
require_relative 'rich_text_extraction/markdown_helpers'
require_relative 'rich_text_extraction/opengraph_helpers'
require_relative 'rich_text_extraction/instance_helpers'
require_relative 'rich_text_extraction/error'
require_relative 'rich_text_extraction/extractor'
require_relative 'rich_text_extraction/extraction_helpers'

require_relative 'rich_text_extraction/rails' if defined?(Rails)

##
# RichTextExtraction provides a suite of helpers and extensions for extracting and processing rich text content,
# such as links, tags, mentions, emails, attachments, phone numbers, dates, and more. It also integrates with Rails
# and ActionText for seamless rich text handling and caching.
#
# @see https://github.com/ceccec/rich_text_extraction Documentation and usage examples
# @note This module is automatically included in ActionText::RichText if ActionText is loaded.
#
module RichTextExtraction
  extend OpenGraphHelpers
  extend MarkdownHelpers
  include InstanceHelpers
  include LinkExtractor
  include SocialExtractor
  include ExtractionPatterns
  include CacheOperations

  # Make all instance methods from InstanceHelpers publicly accessible
  # @!visibility public
  public(*InstanceHelpers.instance_methods(false))

  # Public API
  def self.render_markdown(text, options = {})
    options = configuration.merge(options)
    MarkdownService.new.render(text, options)
  end

  def self.opengraph_preview(og_data, format: :html)
    super
  end

  # Clears OpenGraph cache entries for all links in the plain text.
  # @param cache [Hash, Symbol, nil] Optional cache object or :rails
  # @param cache_options [Hash] Options for cache (e.g., :expires_in, :key_prefix)
  def clear_link_cache(cache: nil, cache_options: {})
    links = extract_links(plain_text)
    clear_cache_for_urls(links, cache, cache_options)
  end

  public :links, :tags, :mentions, :emails, :excerpt, :attachments, :phone_numbers, :dates, :markdown_links,
         :image_urls, :twitter_handles, :link_objects

  private

  # Instance methods for ActionText::RichText and other consumers
  def plain_text
    to_plain_text
  end

  def links
    extract_links(plain_text)
  end

  def tags
    extract_hashtags(plain_text)
  end

  def mentions
    extract_mentions(plain_text)
  end

  def emails
    extract_emails(plain_text)
  end

  def excerpt(length = nil)
    length ||= RichTextExtraction.configuration.default_excerpt_length
    create_excerpt(plain_text, length)
  end

  def attachments
    extract_attachment_urls(plain_text)
  end

  def phone_numbers
    extract_phone_numbers(plain_text)
  end

  def dates
    extract_dates(plain_text)
  end

  def markdown_links
    extract_markdown_links(plain_text)
  end

  def image_urls
    extract_image_urls(plain_text)
  end

  def twitter_handles
    extract_twitter_handles(plain_text)
  end

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

##
# CustomMarkdownRenderer customizes Redcarpet's HTML rendering for links, images, and code blocks.
class CustomMarkdownRenderer < Redcarpet::Render::HTML
  def link(link, _title, content)
    "<a href=\"#{link}\" target=\"_blank\" rel=\"noopener\">#{content}</a>"
  end

  def image(link, _title, alt_text)
    "<img src=\"#{link}\" alt=\"#{alt_text}\" class=\"markdown-image\" />"
  end

  def block_code(code, language)
    lang_class = language ? "language-#{language}" : ''
    "<pre><code class=\"#{lang_class}\">#{ERB::Util.html_escape(code)}</code></pre>"
  end
end

# Auto-include in ActionText::RichText if Rails and ActionText are loaded
ActionText::RichText.include(RichTextExtraction) if defined?(ActionText::RichText)
