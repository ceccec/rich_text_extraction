# frozen_string_literal: true

require 'spec_helper'
require 'active_model'
require 'rich_text_extraction'
require 'rich_text_extraction/extractors/validators'
require 'rich_text_extraction/validators/validators_module'
require 'rich_text_extraction/core/constants'

# Load all validators
require 'rich_text_extraction/validators/isbn_validator'
require 'rich_text_extraction/validators/vin_validator'
require 'rich_text_extraction/validators/issn_validator'
require 'rich_text_extraction/validators/iban_validator'
require 'rich_text_extraction/validators/luhn_validator'
require 'rich_text_extraction/validators/ean13_validator'
require 'rich_text_extraction/validators/upca_validator'
require 'rich_text_extraction/validators/uuid_validator'
require 'rich_text_extraction/validators/hex_color_validator'
require 'rich_text_extraction/validators/ip_validator'
require 'rich_text_extraction/validators/mac_address_validator'
require 'rich_text_extraction/validators/hashtag_validator'
require 'rich_text_extraction/validators/mention_validator'
require 'rich_text_extraction/validators/twitter_handle_validator'
require 'rich_text_extraction/validators/instagram_handle_validator'
require 'rich_text_extraction/validators/url_validator'

RSpec.describe 'ActiveModel Validators' do
  # Minimal model for testing
  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      attr_accessor :value

      def self.name = 'TestModel'
    end
  end

  # Map validator symbol to class - validators are defined in RichTextExtraction::Validators namespace
  VALIDATOR_CLASS_MAP = {
    isbn: RichTextExtraction::Validators::IsbnValidator,
    vin: RichTextExtraction::Validators::VinValidator,
    issn: RichTextExtraction::Validators::IssnValidator,
    iban: RichTextExtraction::Validators::IbanValidator,
    luhn: RichTextExtraction::Validators::LuhnValidator,
    ean13: RichTextExtraction::Validators::Ean13Validator,
    upca: RichTextExtraction::Validators::UpcaValidator,
    uuid: RichTextExtraction::Validators::UuidValidator,
    hex_color: RichTextExtraction::Validators::HexColorValidator,
    ip: RichTextExtraction::Validators::IpValidator,
    mac_address: RichTextExtraction::Validators::MacAddressValidator,
    hashtag: RichTextExtraction::Validators::HashtagValidator,
    mention: RichTextExtraction::Validators::MentionValidator,
    twitter_handle: RichTextExtraction::Validators::TwitterHandleValidator,
    instagram_handle: RichTextExtraction::Validators::InstagramHandleValidator,
    url: RichTextExtraction::Validators::UrlValidator
  }.freeze

  shared_examples 'a generic validator' do |klass, valid, invalid, validator_symbol|
    let(:model) do
      Class.new(model_class) do
        validates_with klass, attributes: [:value]
      end
    end
    it "accepts valid \\#{validator_symbol}" do
      valid.each do |v|
        m = model.new(value: v)
        expect(m).to be_valid, "Expected '#{v}' to be valid for \\#{validator_symbol}"
      end
    end
    it "rejects invalid \\#{validator_symbol}" do
      invalid.each do |v|
        m = model.new(value: v)
        expect(m).not_to be_valid, "Expected '#{v}' to be invalid for \\#{validator_symbol}"
      end
    end
  end

  RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES.each do |validator_symbol, examples|
    klass = VALIDATOR_CLASS_MAP[validator_symbol]
    next unless klass

    valid = examples[:valid]
    invalid = examples[:invalid]
    include_examples 'a generic validator', klass, valid, invalid, validator_symbol
  end
end
