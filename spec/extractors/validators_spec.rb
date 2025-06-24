# frozen_string_literal: true

require 'spec_helper'
require 'active_model'
require 'rich_text_extraction'

RSpec.describe 'ActiveModel Validators' do
  # Minimal model for testing
  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      attr_accessor :value
      def self.name; 'TestModel'; end
    end
  end

  shared_examples 'a validator' do |validator, valid:, invalid:, options: {}|
    let(:klass) do
      Class.new(model_class) do
        validates :value, validator => true
      end
    end
    it "accepts valid #{validator}" do
      valid.each do |v|
        m = klass.new(value: v)
        expect(m).to be_valid, "Expected '#{v}' to be valid for #{validator}"
      end
    end
    it "rejects invalid #{validator}" do
      invalid.each do |v|
        m = klass.new(value: v)
        expect(m).not_to be_valid, "Expected '#{v}' to be invalid for #{validator}"
      end
    end
  end

  include_examples 'a validator', :isbn, valid: ['978-3-16-148410-0', '0-306-40615-2'], invalid: ['978-3-16-148410-1', '123']
  include_examples 'a validator', :vin, valid: ['1HGCM82633A004352'], invalid: ['1HGCM82633A004353', '123']
  include_examples 'a validator', :issn, valid: ['2049-3630'], invalid: ['2049-3631', '123']
  include_examples 'a validator', :iban, valid: ['GB82WEST12345698765432'], invalid: ['GB82WEST12345698765431', '123']
  include_examples 'a validator', :luhn, valid: ['4111 1111 1111 1111', '79927398713'], invalid: ['4111 1111 1111 1112', '123']
  include_examples 'a validator', :ean13, valid: ['4006381333931'], invalid: ['400638133393', 'abc']
  include_examples 'a validator', :upca, valid: ['036000291452'], invalid: ['03600029145', 'abc']
  include_examples 'a validator', :uuid, valid: ['123e4567-e89b-12d3-a456-426614174000'], invalid: ['123e4567-e89b-12d3-a456-42661417400', 'abc']
  include_examples 'a validator', :hex_color, valid: ['#fff', '#abcdef'], invalid: ['fff', '#abcd', '#12345g']
  include_examples 'a validator', :ip, valid: ['192.168.1.1'], invalid: ['999.999.999.999', 'abc']
  include_examples 'a validator', :mac_address, valid: ['00:1A:2B:3C:4D:5E', '00-1A-2B-3C-4D-5E'], invalid: ['00:1A:2B:3C:4D', 'abc']
  include_examples 'a validator', :hashtag, valid: ['hashtag', 'ruby123'], invalid: ['hash tag', '#hashtag', '']
  include_examples 'a validator', :mention, valid: ['mention', 'user123'], invalid: ['@mention', 'user name', '']
  include_examples 'a validator', :twitter_handle, valid: ['jack', 'user123'], invalid: ['user_name_too_long_for_twitter', '']
  include_examples 'a validator', :instagram_handle, valid: ['instauser', 'user123'], invalid: ['user_name_that_is_way_too_long_for_instagram_because_it_is_over_30_chars', '']
  include_examples 'a validator', :url, valid: ['https://example.com', 'http://test.com'], invalid: ['not a url', 'ftp://example.com']
end 