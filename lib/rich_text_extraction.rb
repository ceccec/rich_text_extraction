# frozen_string_literal: true

require 'redcarpet'
require_relative "rich_text_extraction/version"
require "erb"
require 'uri'
require 'nokogiri'
require 'httparty'

if defined?(Rails)
  require_relative "rich_text_extraction/railtie"
  require_relative "rich_text_extraction/helpers"
  require_relative "rich_text_extraction/extracts_rich_text"
end

module RichTextExtraction
  class Error < StandardError; end
  # Your code goes here...

  module ExtractionHelpers
    def extract_links(text)
      URI.extract(text, ["http", "https"]).map { |url| url.sub(/[\.,!?:;]+$/, '') }
    end

    def extract_mentions(text)
      text.scan(/@([\w]+)/).flatten
    end

    def extract_tags(text)
      text.scan(/#([\w]+)/).flatten
    end

    def extract_opengraph(url, cache: nil, cache_options: {})
      key_prefix = cache_options[:key_prefix]
      if key_prefix.nil? && defined?(Rails) && Rails.respond_to?(:application)
        key_prefix = Rails.application.class.module_parent_name rescue nil
      end
      if cache == :rails && defined?(Rails) && Rails.respond_to?(:cache)
        cache_key = key_prefix ? "opengraph:#{key_prefix}:#{url}" : url
        cached = Rails.cache.read(cache_key, **cache_options.except(:key_prefix))
        return cached if cached
      elsif cache && cache != :rails && cache[url]
        return cache[url]
      end
      response = HTTParty.get(url)
      return {} unless response.success?
      doc = Nokogiri::HTML(response.body)
      og_data = {}
      doc.css('meta[property^="og:"]').each do |meta|
        property = meta.attr('property')
        content = meta.attr('content')
        og_data[property.sub('og:', '')] = content if property && content
      end
      if cache == :rails && defined?(Rails) && Rails.respond_to?(:cache)
        cache_key = key_prefix ? "opengraph:#{key_prefix}:#{url}" : url
        Rails.cache.write(cache_key, og_data, **cache_options.except(:key_prefix))
      elsif cache && cache != :rails
        cache[url] = og_data
      end
      og_data
    rescue => e
      { error: e.message }
    end
  end

  class Extractor
    include ExtractionHelpers
    attr_reader :text

    def initialize(text)
      @text = text
    end

    def links
      extract_links(text)
    end

    def mentions
      extract_mentions(text)
    end

    def tags
      extract_tags(text)
    end

    def opengraph_data_for_links
      links.map { |url| { url: url, opengraph: extract_opengraph(url) } }
    end

    def link_objects(with_opengraph: false, cache: nil, cache_options: {})
      if with_opengraph
        links.map { |url| { url: url, opengraph: extract_opengraph(url, cache: cache, cache_options: cache_options) } }
      else
        links.map { |url| { url: url } }
      end
    end

    def clear_link_cache(cache: nil, cache_options: {})
      key_prefix = cache_options[:key_prefix]
      if key_prefix.nil? && defined?(Rails) && Rails.respond_to?(:application)
        key_prefix = Rails.application.class.module_parent_name rescue nil
      end
      links.each do |url|
        if cache == :rails && defined?(Rails) && Rails.respond_to?(:cache)
          cache_key = key_prefix ? "opengraph:#{key_prefix}:#{url}" : url
          Rails.cache.delete(cache_key, **cache_options.except(:key_prefix))
        elsif cache && cache != :rails
          cache.delete(url)
        end
      end
    end
  end

  # Generate a preview snippet from OpenGraph data
  # og_data: hash with keys like 'title', 'description', 'image', 'url'
  # format: :html (default), :markdown, or :text
  def self.opengraph_preview(og_data, format: :html)
    title = og_data["title"] || og_data[:title] || ""
    description = og_data["description"] || og_data[:description] || ""
    image = og_data["image"] || og_data[:image]
    url = og_data["url"] || og_data[:url]

    case format
    when :html
      html = String.new
      html << "<a href='#{url}' target='_blank' rel='noopener'>" if url
      html << "<img src='#{image}' alt='#{title}' style='max-width:200px;'><br>" if image
      html << "<strong>#{title}</strong>" unless title.empty?
      html << "</a>" if url
      html << "<p>#{description}</p>" unless description.empty?
      html
    when :markdown
      md = String.new
      if image && url
        md << "[![](#{image})](#{url})\n"
      elsif image
        md << "![](#{image})\n"
      end
      md << "**#{title}**\n" unless title.empty?
      md << "#{description}\n" unless description.empty?
      md << "[#{url}](#{url})" if url
      md
    when :text
      txt = String.new
      txt << "#{title}\n" unless title.empty?
      txt << "#{description}\n" unless description.empty?
      txt << "#{url}\n" if url
      txt
    else
      ""
    end
  end
end

class CustomMarkdownRenderer < Redcarpet::Render::HTML
  def link(link, title, content)
    "<a href=\"#{link}\" target=\"_blank\" rel=\"noopener\">#{content}</a>"
  end

  def image(link, title, alt_text)
    "<img src=\"#{link}\" alt=\"#{alt_text}\" class=\"markdown-image\" />"
  end

  def block_code(code, language)
    lang_class = language ? "language-#{language}" : ""
    "<pre><code class=\"#{lang_class}\">#{ERB::Util.html_escape(code)}</code></pre>"
  end
end

module RichTextExtraction
  include ExtractionHelpers
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

  def excerpt(length = 200)
    text = plain_text
    text.length > length ? text[0...length].rstrip + "…" : text
  end

  def attachments
    attachment_regex = %r{https?://[\w\-\.\?\,\'/\\\+&%\$#_=:\(\)~]+\.(pdf|docx?|xlsx?|pptx?|jpg|jpeg|png|gif|svg)}i
    plain_text.scan(attachment_regex).map { |match| match.is_a?(Array) ? match[0] : match }
  end

  def phone_numbers
    phone_regex = /\b\+?\d[\d\s\-\(\)]{7,}\b/
    plain_text.scan(phone_regex)
  end

  def dates
    date_regex = /\b\d{4}-\d{2}-\d{2}\b|\b\d{2}\/\d{2}\/\d{4}\b/
    plain_text.scan(date_regex)
  end

  def markdown_links
    md_link_regex = /\[([^\]]+)\]\((https?:\/\/[^\)]+)\)/
    plain_text.scan(md_link_regex).map { |text, url| { text: text, url: url } }
  end

  def image_urls
    image_regex = %r{https?://[^\s]+?\.(jpg|jpeg|png|gif|svg)}
    plain_text.scan(image_regex).map { |match| match.is_a?(Array) ? match[0] : match }
  end

  def twitter_handles
    twitter_regex = /@([A-Za-z0-9_]{1,15})/
    plain_text.scan(twitter_regex).flatten.uniq
  end

  def markdown
    html = if defined?(Redcarpet)
      renderer = CustomMarkdownRenderer.new(filter_html: true, hard_wrap: true)
      markdown = Redcarpet::Markdown.new(
        renderer,
        fenced_code_blocks: true,
        autolink: true,
        tables: true,
        strikethrough: true,
        superscript: true,
        underline: true,
        highlight: true,
        quote: true,
        footnotes: true
      )
      markdown.render(to_plain_text || "")
    elsif defined?(Kramdown)
      Kramdown::Document.new(to_plain_text || "", input: "GFM").to_html
    elsif defined?(CommonMarker)
      CommonMarker.render_html(to_plain_text || "", :DEFAULT, %i[table strikethrough autolink])
    else
      ActionController::Base.helpers.simple_format(to_plain_text)
    end
    ActionController::Base.helpers.sanitize(
      html,
      tags: %w[a img p h1 h2 h3 h4 h5 h6 ul ol li em strong code pre blockquote table thead tbody tr th td sup sub del span],
      attributes: %w[href src alt title class target rel]
    )
  end

  def self.render_markdown(text)
    renderer = CustomMarkdownRenderer.new(filter_html: true, hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, extensions = {fenced_code_blocks: true, autolink: true, tables: true})
    markdown.render(text)
  end

  def link_objects(with_opengraph: false, cache: nil, cache_options: {})
    if with_opengraph
      extract_links(plain_text).map { |url| { url: url, opengraph: extract_opengraph(url, cache: cache, cache_options: cache_options) } }
    else
      extract_links(plain_text).map { |url| { url: url } }
    end
  end

  def clear_link_cache(cache: nil, cache_options: {})
    key_prefix = cache_options[:key_prefix]
    if key_prefix.nil? && defined?(Rails) && Rails.respond_to?(:application)
      key_prefix = Rails.application.class.module_parent_name rescue nil
    end
    extract_links(plain_text).each do |url|
      if cache == :rails && defined?(Rails) && Rails.respond_to?(:cache)
        cache_key = key_prefix ? "opengraph:#{key_prefix}:#{url}" : url
        Rails.cache.delete(cache_key, **cache_options.except(:key_prefix))
      elsif cache && cache != :rails
        cache.delete(url)
      end
    end
  end
end

if defined?(ActionText::RichText)
  ActionText::RichText.include(RichTextExtraction)
end
