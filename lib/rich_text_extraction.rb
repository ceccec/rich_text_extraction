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
  # @!method plain_text
  # @!method links
  # @!method tags
  # @!method mentions
  # @!method emails
  # @!method excerpt
  # @!method attachments
  # @!method phone_numbers
  # @!method dates
  # @!method markdown_links
  # @!method image_urls
  # @!method twitter_handles
  # @!method link_objects
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

  # Unified DRY extraction from any supported file format
  #
  # Usage: RichTextExtraction.extract_from_file('path/to/file')
  # Returns: { text: ..., links: [...], tags: [...], mentions: [...] }
  def self.extract_from_file(path)
    ext = File.extname(path).downcase
    text = case ext
    when '.txt', ''
      File.read(path)
    when '.md'
      File.read(path)
    when '.html', '.htm'
      begin
        require 'nokogiri'
        Nokogiri::HTML(File.read(path)).text
      rescue LoadError
        warn 'HTML extraction requires the nokogiri gem.'
        ''
      end
    when '.docx'
      begin
        require 'docx'
        Docx::Document.open(path).paragraphs.map(&:text).join("\n")
      rescue LoadError
        warn 'DOCX extraction requires the docx gem.'
        ''
      end
    when '.pdf'
      begin
        require 'pdf-reader'
        PDF::Reader.new(path).pages.map(&:text).join("\n")
      rescue LoadError
        warn 'PDF extraction requires the pdf-reader gem.'
        ''
      end
    when '.csv', '.tsv'
      begin
        require 'csv'
        CSV.read(path, col_sep: (ext == '.tsv' ? "\t" : ",")).flatten.join("\n")
      rescue LoadError
        warn 'CSV/TSV extraction requires the csv gem.'
        ''
      end
    when '.json'
      begin
        require 'json'
        JSON.parse(File.read(path)).values.flatten.join("\n")
      rescue LoadError
        warn 'JSON extraction requires the json gem.'
        ''
      end
    when '.odt'
      begin
        require 'odf-report'
        doc = ODFReport::Report.new(path)
        doc.instance_variable_get(:@doc).text
      rescue LoadError
        warn 'ODT extraction requires the odf-report gem.'
        ''
      end
    when '.epub'
      begin
        require 'epub/parser'
        book = EPUB::Parser.parse(path)
        book.each_page.map(&:content_document).map(&:text).join("\n")
      rescue LoadError
        warn 'EPUB extraction requires the epub-parser gem.'
        ''
      end
    when '.rtf'
      begin
        require 'rtf'
        doc = RTF::Document.new(File.read(path))
        doc.to_text
      rescue LoadError
        warn 'RTF extraction requires the rtf gem.'
        ''
      end
    when '.xlsx'
      begin
        require 'roo'
        xlsx = Roo::Excelx.new(path)
        xlsx.sheets.map { |sheet| xlsx.sheet(sheet).to_a.flatten }.flatten.join("\n")
      rescue LoadError
        warn 'XLSX extraction requires the roo gem.'
        ''
      end
    when '.pptx'
      begin
        require 'roo'
        pptx = Roo::Powerpoint.new(path)
        pptx.slides.map(&:text).join("\n")
      rescue LoadError
        warn 'PPTX extraction requires the roo gem.'
        ''
      end
    when '.xml'
      begin
        require 'nokogiri'
        Nokogiri::XML(File.read(path)).text
      rescue LoadError
        warn 'XML extraction requires the nokogiri gem.'
        ''
      end
    when '.yml', '.yaml'
      require 'yaml'
      data = YAML.load_file(path)
      data.values.flatten.join("\n")
    when '.tex'
      File.read(path)
    else
      File.read(path)
    end
    extractor = RichTextExtraction::Extractor.new(text)
    {
      text: text,
      links: extractor.links,
      tags: extractor.tags,
      mentions: extractor.mentions
    }
  end

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

  def extract_opengraph(url, cache: nil, cache_options: {})
    RichTextExtraction.extract_opengraph(url, cache: cache, cache_options: cache_options)
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
# @!parse
#   ActionText::RichText.include(RichTextExtraction) if defined?(ActionText::RichText)
ActionText::RichText.include(RichTextExtraction) if defined?(ActionText::RichText)
