# frozen_string_literal: true

require 'redcarpet'
require 'erb'
require 'uri'
require 'nokogiri'
require 'httparty'
require 'active_model'

# Core files
require_relative 'rich_text_extraction/core/constants'
require_relative 'rich_text_extraction/core/version'
require_relative 'rich_text_extraction/core/error'
require_relative 'rich_text_extraction/core/universal_sacred_core'
require_relative 'rich_text_extraction/core/vortex_engine'
require_relative 'rich_text_extraction/core/universal_registry'
require_relative 'rich_text_extraction/core/sacred_validator_factory'

# Registry (must be before extractors)
require_relative 'rich_text_extraction/registry'
require_relative 'rich_text_extraction/core/component_loader'

# Cache files (must be before configuration)
require_relative 'rich_text_extraction/cache/cache_operations'
require_relative 'rich_text_extraction/cache/cache_configuration'

# Configuration (depends on cache)
require_relative 'rich_text_extraction/core/configuration'

# Helpers (must be before extractors)
require_relative 'rich_text_extraction/helpers/markdown_helpers'
require_relative 'rich_text_extraction/helpers/opengraph_helpers'
require_relative 'rich_text_extraction/helpers/helpers_module'
require_relative 'rich_text_extraction/helpers/validator_helpers'

# Extractors
require_relative 'rich_text_extraction/extractors/base_extractor'
require_relative 'rich_text_extraction/extractors/validators'
require_relative 'rich_text_extraction/extractors/link_extractor'
require_relative 'rich_text_extraction/extractors/social_extractor'
require_relative 'rich_text_extraction/extractors/identifier_extractor'
require_relative 'rich_text_extraction/extractors/extraction_patterns'
require_relative 'rich_text_extraction/extractors/extraction_helpers'
require_relative 'rich_text_extraction/extractors/extractors'

# Instance helpers (depends on extractors)
require_relative 'rich_text_extraction/helpers/instance_helpers'

# API files (load unconditionally for testing)
require_relative 'rich_text_extraction/api/validator_api'

# Services
require_relative 'rich_text_extraction/services/opengraph_service'
require_relative 'rich_text_extraction/services/markdown_service'

# Validators
require_relative 'rich_text_extraction/validators/auto_loader'
require_relative 'rich_text_extraction/validators/base_validator'
require_relative 'rich_text_extraction/validators/validator_factory'
require_relative 'rich_text_extraction/validators/validators_module'

# Load validators using auto-loader pattern
RichTextExtraction::Validators::AutoLoader.load_all

# Load Rails integration if Rails is defined
if defined?(Rails)
  require 'rich_text_extraction/rails/engine'
  require 'rich_text_extraction/rails/railtie'
  require 'rich_text_extraction/rails/extracts_rich_text'
  require 'rich_text_extraction/api/validators_controller'
  require 'rich_text_extraction/concerns/validators_controller_concern'
end

# Universal Architecture Components
require_relative 'rich_text_extraction/interface_adapter'
require_relative 'rich_text_extraction/helper'
require_relative 'rich_text_extraction/interfaces/console_interface'
require_relative 'rich_text_extraction/testing/test_generator'
require_relative 'rich_text_extraction/testing/test_runner'

##
# RichTextExtraction is a universal, extensible gem for extracting links, identifiers, Markdown, OpenGraph, and more from any document or string.
# It provides comprehensive text processing capabilities with built-in validators and extractors.
#
# RichTextExtraction provides a suite of helpers and extensions for extracting and processing rich text content,
# such as links, tags, mentions, emails, attachments, phone numbers, dates, and more. It also integrates with Rails
# and ActionText for seamless rich text handling and caching.
#
# @see https://github.com/ceccec/rich_text_extraction Documentation and usage examples
# @note This module is automatically included in ActionText::RichText if ActionText is loaded.
#
module RichTextExtraction
  class << self
    # Configuration method
    def configuration
      @configuration ||= RichTextExtraction::Core::Configuration.new
    end

    # Configure method for setting up the gem
    def configure
      yield(configuration) if block_given?
      configuration
    end

    # Universal extract method
    def extract(text, type = :all, **opts)
      RichTextExtraction::Extractors::ExtractionHelpers.extract(text, type, **opts)
    end

    # Universal extract_opengraph method
    def extract_opengraph(url, cache: nil, cache_options: {})
      RichTextExtraction::Extractors::ExtractionHelpers.extract_opengraph(url, cache: cache,
                                                                               cache_options: cache_options)
    end

    # Get the Extractor class
    def Extractor
      RichTextExtraction::Extractors::Extractor
    end

    extend RichTextExtraction::Helpers::OpenGraphHelpers
    extend RichTextExtraction::Helpers::MarkdownHelpers
    extend RichTextExtraction::Extractors::ExtractionHelpers
    include RichTextExtraction::Helpers::InstanceHelpers
    # include RichTextExtraction::Extractors::LinkExtractor
    # include RichTextExtraction::Extractors::SocialExtractor
    include RichTextExtraction::Extractors::ExtractionPatterns
    include RichTextExtraction::Cache::CacheOperations

    # Only make methods public if they are actually defined at this level
    public(*RichTextExtraction::Helpers::InstanceHelpers.instance_methods(false))
    # Remove :dates from the public list if not defined at this level

    # Public API
    def render_markdown(text, options = {})
      options = configuration.merge(options)
      MarkdownService.new.render(text, options)
    end

    def opengraph_preview(og_data, format: :html)
      case format
      when :html
        render_html_preview(og_data)
      when :markdown
        render_markdown_preview(og_data)
      when :text
        render_text_preview(og_data)
      else
        render_html_preview(og_data)
      end
    end

    # Clears OpenGraph cache entries for all links in the plain text.
    # @param cache [Hash, Symbol, nil] Optional cache object or :rails
    # @param cache_options [Hash] Options for cache (e.g., :expires_in, :key_prefix)
    def clear_link_cache(cache: nil, cache_options: {})
      links = extract_links(plain_text)
      clear_cache_for_urls(links, cache, cache_options)
    end

    public :links, :tags, :mentions, :emails, :excerpt, :attachments, :phone_numbers, :markdown_links,
           :image_urls, :twitter_handles, :extract_opengraph

    # Extracts text and metadata from a file, supporting multiple formats.
    # Dispatches to a handler based on file extension.
    # @param path [String] Path to the file
    # @return [Hash] { text:, links:, tags:, mentions: }
    def extract_from_file(path)
      ext = File.extname(path).downcase
      handler = file_extractors[ext] || method(:extract_txt)
      text = handler.call(path)
      extractor = Extractor.new(text)
      {
        text: text,
        links: extractor.links,
        tags: extractor.tags,
        mentions: extractor.mentions
      }
    end

    # Helper to create file extractor mappings
    def create_file_extractors
      {
        # Text files
        '.txt' => ->(path) { extract_txt(path) },
        '' => ->(path) { extract_txt(path) },
        '.md' => ->(path) { extract_md(path) },
        '.tex' => ->(path) { extract_txt(path) },

        # Web files
        '.html' => ->(path) { extract_html(path) },
        '.htm' => ->(path) { extract_html(path) },
        '.xml' => ->(path) { extract_xml(path) },

        # Office files
        '.docx' => ->(path) { extract_docx(path) },
        '.pdf' => ->(path) { extract_pdf(path) },
        '.odt' => ->(path) { extract_odt(path) },
        '.rtf' => ->(path) { extract_rtf(path) },
        '.xlsx' => ->(path) { extract_xlsx(path) },
        '.pptx' => ->(path) { extract_pptx(path) },

        # Data files
        '.csv' => ->(path) { extract_csv(path) },
        '.tsv' => ->(path) { extract_tsv(path) },
        '.json' => ->(path) { extract_json(path) },
        '.yml' => ->(path) { extract_yaml(path) },
        '.yaml' => ->(path) { extract_yaml(path) },

        # Media files
        '.epub' => ->(path) { extract_epub(path) }
      }.freeze
    end

    # Handler methods for each file type
    def extract_txt(path)
      File.read(path)
    end

    def extract_md(path)
      extract_txt(path) # Same as extract_txt
    end

    def extract_html(path)
      require_with_fallback('nokogiri') do
        Nokogiri::HTML(File.read(path)).text
      end
    end

    def extract_docx(path)
      require_with_fallback('docx') do
        Docx::Document.open(path).paragraphs.map(&:text).join("\n")
      end
    end

    def extract_pdf(path)
      require_with_fallback('pdf-reader') do
        PDF::Reader.new(path).pages.map(&:text).join("\n")
      end
    end

    def extract_csv(path)
      extract_delimited_file(path, ',')
    end

    def extract_tsv(path)
      extract_delimited_file(path, "\t")
    end

    # Shared method for extracting delimited files (CSV, TSV)
    def extract_delimited_file(path, separator)
      require_with_fallback('csv') do
        CSV.read(path, col_sep: separator).flatten.join("\n")
      end
    end

    def extract_json(path)
      require_with_fallback('json') do
        JSON.parse(File.read(path)).values.flatten.join("\n")
      end
    end

    def extract_odt(path)
      require_with_fallback('odf-report') do
        doc = ODFReport::Report.new(path)
        doc.instance_variable_get(:@doc).text
      end
    end

    def extract_epub(path)
      require_with_fallback('epub/parser') do
        book = EPUB::Parser.parse(path)
        book.each_page.map(&:content_document).map(&:text).join("\n")
      end
    end

    def extract_rtf(path)
      require_with_fallback('rtf') do
        doc = RTF::Document.new(File.read(path))
        doc.to_text
      end
    end

    def extract_xlsx(path)
      require_with_fallback('roo') do
        xlsx = Roo::Excelx.new(path)
        xlsx.sheets.map { |sheet| xlsx.sheet(sheet).to_a.flatten }.flatten.join("\n")
      end
    end

    def extract_pptx(path)
      require_with_fallback('roo') do
        pptx = Roo::Powerpoint.new(path)
        pptx.slides.map(&:text).join("\n")
      end
    end

    def extract_xml(path)
      require_with_fallback('nokogiri') do
        Nokogiri::XML(File.read(path)).text
      end
    end

    def extract_yaml(path)
      require_with_fallback('yaml') do
        data = YAML.load_file(path)
        data.values.flatten.join("\n")
      end
    end

    # Shared method for handling gem requirements with fallback
    def require_with_fallback(gem_name)
      require gem_name
      yield
    rescue LoadError
      warn "#{gem_name.capitalize} extraction requires the #{gem_name} gem."
      ''
    end

    private

    # Configuration for instance methods - maps method name to extraction method
    INSTANCE_METHODS = {
      links: 'extract_links',
      tags: 'extract_hashtags',
      mentions: 'extract_mentions',
      emails: 'extract_emails',
      attachments: 'extract_attachment_urls',
      phone_numbers: 'extract_phone_numbers',
      dates: 'extract_dates',
      markdown_links: 'extract_markdown_links',
      image_urls: 'extract_image_urls',
      twitter_handles: 'extract_twitter_handles'
    }.freeze

    # Generate instance methods dynamically
    INSTANCE_METHODS.each do |method_name, extraction_method|
      define_method(method_name) do
        send(extraction_method, plain_text)
      end
    end

    # Instance methods for ActionText::RichText and other consumers
    def plain_text
      to_plain_text
    end

    def excerpt(length = nil)
      length ||= RichTextExtraction.configuration.default_excerpt_length
      create_excerpt(plain_text, length)
    end

    # Universal interface methods for maximum shared functionality
    def extract_universal(text, interface_type = :console, options = {})
      InterfaceAdapter.adapt_request(interface_type, { text: text }.merge(options))
    end

    def extract_console(text, options = {})
      extract_universal(text, :console, options)
    end

    def extract_web(text, options = {})
      extract_universal(text, :web, options)
    end

    def extract_javascript(text, options = {})
      extract_universal(text, :javascript, options)
    end

    def run_universal_tests
      Testing::TestRunner.new.run_all_tests
    end

    def generate_universal_tests
      Testing::TestGenerator.new.generate_all_tests
    end

    # Get file extractors (lazy initialization)
    def file_extractors
      @file_extractors ||= create_file_extractors
    end

    def render_html_preview(og)
      title = og[:title] || og['title'] || 'No title'
      url = og[:url] || og['url'] || '#'
      description = og[:description] || og['description'] || 'No description'

      "<div class='opengraph-preview'>
        <h3>#{title}</h3>
        <p>#{description}</p>
        <a href='#{url}'>#{url}</a>
      </div>"
    end

    def render_markdown_preview(og)
      title = og[:title] || og['title'] || 'No title'
      url = og[:url] || og['url'] || '#'
      description = og[:description] || og['description'] || 'No description'

      "## #{title}\n\n#{description}\n\n[#{url}](#{url})"
    end

    def render_text_preview(og)
      title = og[:title] || og['title'] || 'No title'
      url = og[:url] || og['url'] || '#'
      description = og[:description] || og['description'] || 'No description'

      "#{title}\n\n#{description}\n\n#{url}"
    end
  end

  # Auto-include in ActionText::RichText if Rails and ActionText are loaded
  # @!parse
  #   ActionText::RichText.include(RichTextExtraction) if defined?(ActionText::RichText)
  ActiveSupport.on_load(:action_text_rich_text) { include RichTextExtraction } if defined?(ActionText::RichText)
end

# Centralized component registration using Rails conventions
if defined?(RichTextExtraction::Registry)
  loader = RichTextExtraction::Core::ComponentLoader.new
  loader.load_all!
end
