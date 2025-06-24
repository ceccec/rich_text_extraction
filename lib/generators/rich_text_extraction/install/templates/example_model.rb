# frozen_string_literal: true

# Example model demonstrating RichTextExtraction usage
# This is a sample model - you can delete it or use it as a reference

class ExamplePost < ApplicationRecord
  include RichTextExtraction::ExtractsRichText
  
  has_rich_text :content
  
  validates :title, presence: true
  validates :content, presence: true

  # Extract links from content
  def extract_links
    content.links
  end

  # Get OpenGraph data for all links
  def extract_opengraph_data
    content.link_objects(with_opengraph: true)
  end

  # Extract social content
  def extract_social_content
    {
      tags: content.tags,
      mentions: content.mentions,
      emails: content.emails,
      phone_numbers: content.phone_numbers
    }
  end

  # Generate excerpt from content
  def excerpt(length = 300)
    content.excerpt(length)
  end

  # Check if content has links
  def has_links?
    content.links.any?
  end

  # Get link count
  def link_count
    content.links.count
  end

  # Process links in background
  def process_links_async
    ProcessLinksJob.perform_later(self) if has_links?
  end

  private

  # Clear cache when content changes
  def clear_content_cache
    content.clear_link_cache(cache: :rails) if content.present?
  end
end 