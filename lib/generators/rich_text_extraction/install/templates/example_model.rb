# frozen_string_literal: true

# Example model demonstrating RichTextExtraction usage
# This is a sample model - you can delete it or use it as a reference

class ExamplePost < ApplicationRecord
  include RichTextExtraction::ExtractsRichText

  has_rich_text :content

  validates :title, presence: true
  validates :content, presence: true

  # === Advanced RichTextExtraction Validator Usage ===

  # Basic usage for all supported validators
  validates :isbn, isbn: true
  validates :vin, vin: true
  validates :issn, issn: true
  validates :iban, iban: true
  validates :credit_card, luhn: true
  validates :ean, ean13: true
  validates :upc, upca: true
  validates :uuid, uuid: true
  validates :imei, luhn: true
  validates :mac, mac_address: true
  validates :color, hex_color: true
  validates :ip, ip: true
  validates :hashtag, hashtag: true
  validates :mention, mention: true
  validates :twitter, twitter_handle: true
  validates :instagram, instagram_handle: true
  validates :website, url: true

  # Custom error message
  validates :isbn, isbn: { message: 'must be a valid ISBN-10 or ISBN-13' }

  # Conditional validation
  validates :vin, vin: true, if: -> { vin.present? }

  # Multiple fields with the same validator
  validates :primary_email, :secondary_email, email: true, allow_blank: true

  # Using validates_with for custom logic (example)
  # class CustomValidator < ActiveModel::Validator
  #   def validate(record)
  #     record.errors.add(:base, 'Custom error') unless record.isbn.present? || record.vin.present?
  #   end
  # end
  # validates_with CustomValidator

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
