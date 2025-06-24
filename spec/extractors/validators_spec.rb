# frozen_string_literal: true

require 'spec_helper'
require 'active_model'
require 'rich_text_extraction'
require 'rich_text_extraction/extractors/validators'
require 'rich_text_extraction/validators'
require 'rich_text_extraction/constants'

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

  # Map validator symbol to class
  VALIDATOR_CLASS_MAP = {
    isbn: IsbnValidator,
    vin: VinValidator,
    issn: IssnValidator,
    iban: IbanValidator,
    luhn: LuhnValidator,
    ean13: Ean13Validator,
    upca: UpcaValidator,
    uuid: UuidValidator,
    hex_color: HexColorValidator,
    ip: IpValidator,
    mac_address: MacAddressValidator,
    hashtag: HashtagValidator,
    mention: MentionValidator,
    twitter_handle: TwitterHandleValidator,
    instagram_handle: InstagramHandleValidator,
    url: UrlValidator
  }.freeze

  shared_examples 'a validator' do |validator_symbol, valid:, invalid:, options: {}|
    let(:klass) do
      Class.new(model_class) do
        validates_with VALIDATOR_CLASS_MAP[validator_symbol], attributes: [:value]
      end
    end
    it "accepts valid \\#{validator_symbol}" do
      valid.each do |v|
        m = klass.new(value: v)
        expect(m).to be_valid, "Expected '#{v}' to be valid for \\#{validator_symbol}"
      end
    end
    it "rejects invalid \\#{validator_symbol}" do
      invalid.each do |v|
        m = klass.new(value: v)
        expect(m).not_to be_valid, "Expected '#{v}' to be invalid for \\#{validator_symbol}"
      end
    end
  end

  RichTextExtraction::Constants::VALIDATOR_EXAMPLES.each do |validator_symbol, examples|
    include_examples 'a validator', validator_symbol, valid: examples[:valid], invalid: examples[:invalid]
  end
end
