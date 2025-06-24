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
# RichTextExtraction is a universal, extensible gem for extracting links, identifiers, Markdown, OpenGraph, and more from any document or string.
#
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
  # Only make methods public if they are actually defined at this level
  public(*InstanceHelpers.instance_methods(false))
  # Remove :dates from the public list if not defined at this level
  # public :dates, :links, :tags, :mentions, :emails, :excerpt, :attachments, :phone_numbers, :markdown_links, :image_urls, :twitter_handles, :link_objects

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

  public :links, :tags, :mentions, :emails, :excerpt, :attachments, :phone_numbers, :markdown_links,
         :image_urls, :twitter_handles, :link_objects

  # Extracts text and metadata from a file, supporting multiple formats.
  # Dispatches to a handler based on file extension.
  # @param path [String] Path to the file
  # @return [Hash] { text:, links:, tags:, mentions: }
  def self.extract_from_file(path)
    ext = File.extname(path).downcase
    handler = FILE_EXTRACTORS[ext] || method(:extract_txt)
    text = handler.call(path)
    extractor = RichTextExtraction::Extractor.new(text)
    {
      text: text,
      links: extractor.links,
      tags: extractor.tags,
      mentions: extractor.mentions
    }
  end

  # Dispatch table for file extension handlers (must use lambdas to avoid NameError)
  FILE_EXTRACTORS = {
    '.txt'   => ->(path) { extract_txt(path) },
    ''      => ->(path) { extract_txt(path) },
    '.md'   => ->(path) { extract_md(path) },
    '.html' => ->(path) { extract_html(path) },
    '.htm'  => ->(path) { extract_html(path) },
    '.docx' => ->(path) { extract_docx(path) },
    '.pdf'  => ->(path) { extract_pdf(path) },
    '.csv'  => ->(path) { extract_csv(path) },
    '.tsv'  => ->(path) { extract_tsv(path) },
    '.json' => ->(path) { extract_json(path) },
    '.odt'  => ->(path) { extract_odt(path) },
    '.epub' => ->(path) { extract_epub(path) },
    '.rtf'  => ->(path) { extract_rtf(path) },
    '.xlsx' => ->(path) { extract_xlsx(path) },
    '.pptx' => ->(path) { extract_pptx(path) },
    '.xml'  => ->(path) { extract_xml(path) },
    '.yml'  => ->(path) { extract_yaml(path) },
    '.yaml' => ->(path) { extract_yaml(path) },
    '.tex'  => ->(path) { extract_txt(path) }
  }

  # Handler methods for each file type
  def self.extract_txt(path)
    File.read(path)
  end

  def self.extract_md(path)
    File.read(path)
  end

  def self.extract_html(path)
    require 'nokogiri'
    Nokogiri::HTML(File.read(path)).text
  rescue LoadError
    warn 'HTML extraction requires the nokogiri gem.'
    ''
  end

  def self.extract_docx(path)
    require 'docx'
    Docx::Document.open(path).paragraphs.map(&:text).join("\n")
  rescue LoadError
    warn 'DOCX extraction requires the docx gem.'
    ''
  end

  def self.extract_pdf(path)
    require 'pdf-reader'
    PDF::Reader.new(path).pages.map(&:text).join("\n")
  rescue LoadError
    warn 'PDF extraction requires the pdf-reader gem.'
    ''
  end

  def self.extract_csv(path)
    require 'csv'
    CSV.read(path, col_sep: ',').flatten.join("\n")
  rescue LoadError
    warn 'CSV extraction requires the csv gem.'
    ''
  end

  def self.extract_tsv(path)
    require 'csv'
    CSV.read(path, col_sep: "\t").flatten.join("\n")
  rescue LoadError
    warn 'TSV extraction requires the csv gem.'
    ''
  end

  def self.extract_json(path)
    require 'json'
    JSON.parse(File.read(path)).values.flatten.join("\n")
  rescue LoadError
    warn 'JSON extraction requires the json gem.'
    ''
  end

  def self.extract_odt(path)
    require 'odf-report'
    doc = ODFReport::Report.new(path)
    doc.instance_variable_get(:@doc).text
  rescue LoadError
    warn 'ODT extraction requires the odf-report gem.'
    ''
  end

  def self.extract_epub(path)
    require 'epub/parser'
    book = EPUB::Parser.parse(path)
    book.each_page.map(&:content_document).map(&:text).join("\n")
  rescue LoadError
    warn 'EPUB extraction requires the epub-parser gem.'
    ''
  end

  def self.extract_rtf(path)
    require 'rtf'
    doc = RTF::Document.new(File.read(path))
    doc.to_text
  rescue LoadError
    warn 'RTF extraction requires the rtf gem.'
    ''
  end

  def self.extract_xlsx(path)
    require 'roo'
    xlsx = Roo::Excelx.new(path)
    xlsx.sheets.map { |sheet| xlsx.sheet(sheet).to_a.flatten }.flatten.join("\n")
  rescue LoadError
    warn 'XLSX extraction requires the roo gem.'
    ''
  end

  def self.extract_pptx(path)
    require 'roo'
    pptx = Roo::Powerpoint.new(path)
    pptx.slides.map(&:text).join("\n")
  rescue LoadError
    warn 'PPTX extraction requires the roo gem.'
    ''
  end

  def self.extract_xml(path)
    require 'nokogiri'
    Nokogiri::XML(File.read(path)).text
  rescue LoadError
    warn 'XML extraction requires the nokogiri gem.'
    ''
  end

  def self.extract_yaml(path)
    require 'yaml'
    data = YAML.load_file(path)
    data.values.flatten.join("\n")
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
ActiveSupport.on_load(:action_text_rich_text) { include RichTextExtraction } if defined?(ActionText::RichText)
