# frozen_string_literal: true

require 'redcarpet'
require_relative 'rich_text_extraction/version'
require_relative 'rich_text_extraction/configuration'
require_relative 'rich_text_extraction/cache_configuration'
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

if defined?(Rails)
  require_relative 'rich_text_extraction/railtie'
  require_relative 'rich_text_extraction/helpers'
  require_relative 'rich_text_extraction/extracts_rich_text'
end

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
    key_prefix = resolve_opengraph_key_prefix(cache_options)
    links = resolve_links
    links.each do |url|
      delete_opengraph_cache_entry(url, cache, cache_options, key_prefix)
    end
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
    extract_tags(plain_text)
  end

  def mentions
    extract_mentions(plain_text)
  end

  def emails
    email_regex = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}\b/i
    plain_text.scan(email_regex)
  end

  def excerpt(length = nil)
    length ||= RichTextExtraction.configuration.default_excerpt_length
    text = plain_text
    text.length > length ? "#{text[0...length].rstrip}…" : text
  end

  def attachments
    extract_attachment_urls(plain_text)
  end

  def phone_numbers
    phone_regex = /\b\+?\d[\d\s\-()]{7,}\b/
    plain_text.scan(phone_regex)
  end

  def dates
    date_regex = %r{\b\d{4}-\d{2}-\d{2}\b|\b\d{2}/\d{2}/\d{4}\b}
    plain_text.scan(date_regex)
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

  def build_opengraph_cache_key(url, key_prefix)
    key_prefix ? "opengraph:#{key_prefix}:#{url}" : url
  end

  def delete_opengraph_cache_entry(url, cache, cache_options, key_prefix)
    if cache == :rails && defined?(Rails) && Rails.respond_to?(:cache)
      cache_key = build_opengraph_cache_key(url, key_prefix)
      Rails.cache.delete(cache_key, **cache_options.except(:key_prefix))
    elsif cache && cache != :rails
      cache.delete(url)
    end
  end

  def resolve_opengraph_key_prefix(cache_options)
    if respond_to?(:opengraph_key_prefix)
      opengraph_key_prefix(cache_options)
    else
      RichTextExtraction.send(:opengraph_key_prefix, cache_options)
    end
  end

  def resolve_links
    if respond_to?(:extract_links)
      extract_links(plain_text)
    else
      RichTextExtraction.send(:extract_links, plain_text)
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
