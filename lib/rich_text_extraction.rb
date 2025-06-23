# frozen_string_literal: true

require 'redcarpet'
require_relative "rich_text_extraction/version"
require "erb"
require 'uri'

module RichTextExtraction
  class Error < StandardError; end
  # Your code goes here...

  class Extractor
    attr_reader :text

    def initialize(text)
      @text = text
    end

    def links
      # Extract URLs from the text and strip trailing punctuation
      URI.extract(text, ["http", "https"]).map { |url| url.sub(/[\.,!?:;]+$/, '') }
    end

    def mentions
      # Extract @mentions from the text
      text.scan(/@([\w]+)/).flatten
    end

    def tags
      # Extract #tags from the text
      text.scan(/#([\w]+)/).flatten
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
  def plain_text
    to_plain_text
  end

  def links
    url_regex = %r{https?://[\w\-\.\?\,\'/\\\+&%\$#_=:\(\)~]+}
    plain_text.scan(url_regex)
  end

  def tags
    tag_regex = /#\w+/
    plain_text.scan(tag_regex)
  end

  def mentions
    mention_regex = /@\w+/
    plain_text.scan(mention_regex)
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
end

if defined?(ActionText::RichText)
  ActionText::RichText.include(RichTextExtraction)
end
