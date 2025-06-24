# frozen_string_literal: true

module RichTextExtraction
  module Extractors
    module Validators
      # ISBN checksum validation (ISBN-10/13, ISO 2108)
      def self.valid_isbn?(isbn)
        digits = isbn.gsub(/[^0-9Xx]/, '').upcase
        if digits.length == 10
          sum = digits.chars.each_with_index.sum { |d, i| (d == 'X' ? 10 : d.to_i) * (10 - i) }
          sum % 11 == 0
        elsif digits.length == 13
          sum = digits.chars.each_with_index.sum { |d, i| d.to_i * (i.even? ? 1 : 3) }
          sum % 10 == 0
        else
          false
        end
      end

      # VIN check digit validation (ISO 3779)
      def self.valid_vin?(vin)
        map = ('A'..'Z').to_a.zip([1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9,2,3,4,5,6,7]).to_h
        weights = [8,7,6,5,4,3,2,10,0,9,8,7,6,5,4,3,2]
        vin = vin.upcase
        return false unless vin.length == 17
        sum = vin.chars.each_with_index.sum do |char, i|
          value = char =~ /\d/ ? char.to_i : map[char] || 0
          value * weights[i]
        end
        check = sum % 11
        check_char = check == 10 ? 'X' : check.to_s
        vin[8] == check_char
      end

      # ISSN checksum validation (mod-11, ISO 3297)
      def self.valid_issn?(issn)
        digits = issn.delete('-').upcase.chars
        return false unless digits.length == 8
        sum = digits[0..6].each_with_index.sum { |d, i| d.to_i * (8 - i) }
        check = (11 - (sum % 11)) % 11
        check_char = check == 10 ? 'X' : check.to_s
        digits[7] == check_char
      end

      # IBAN mod-97 validation (ISO 13616)
      def self.valid_iban?(iban)
        iban = iban.gsub(/\s+/, '').upcase
        rearranged = iban[4..-1] + iban[0..3]
        numeric = rearranged.chars.map { |c| c =~ /[A-Z]/ ? (c.ord - 'A'.ord + 10).to_s : c }.join
        numeric.to_i % 97 == 1
      rescue
        false
      end

      # Luhn algorithm for credit cards, IMEI, etc. (ISO/IEC 7812)
      def self.luhn_valid?(number)
        digits = number.gsub(/\D/, '').chars.map(&:to_i)
        sum = digits.reverse.each_slice(2).sum do |odd, even|
          [odd, (even ? (even * 2 > 9 ? even * 2 - 9 : even * 2) : 0)].sum
        end
        sum % 10 == 0
      end
    end
  end
end

# == ActiveModel/ActiveRecord Validators ==
#
# Usage in Rails models:
#   validates :isbn, isbn: true
#   validates :vin, vin: true
#   validates :issn, issn: true
#   validates :iban, iban: true
#   validates :credit_card, luhn: true
#
# These validators can be used in any ActiveModel or ActiveRecord model.

if defined?(ActiveModel)
  class ISBNValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless RichTextExtraction::Extractors::Validators.valid_isbn?(value)
        record.errors.add(attribute, (options[:message] || 'is not a valid ISBN'))
      end
    end
  end

  class VINValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless RichTextExtraction::Extractors::Validators.valid_vin?(value)
        record.errors.add(attribute, (options[:message] || 'is not a valid VIN'))
      end
    end
  end

  class ISSNValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless RichTextExtraction::Extractors::Validators.valid_issn?(value)
        record.errors.add(attribute, (options[:message] || 'is not a valid ISSN'))
      end
    end
  end

  class IBANValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless RichTextExtraction::Extractors::Validators.valid_iban?(value)
        record.errors.add(attribute, (options[:message] || 'is not a valid IBAN'))
      end
    end
  end

  class LuhnValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless RichTextExtraction::Extractors::Validators.luhn_valid?(value)
        record.errors.add(attribute, (options[:message] || 'is not a valid number (Luhn check failed)'))
      end
    end
  end

  class Ean13Validator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.to_s.match?(/\A\d{13}\z/)
        record.errors.add(attribute, (options[:message] || 'is not a valid EAN-13 barcode'))
      end
    end
  end

  class UpcaValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.to_s.match?(/\A\d{12}\z/)
        record.errors.add(attribute, (options[:message] || 'is not a valid UPC-A barcode'))
      end
    end
  end

  class UuidValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.to_s.match?(/\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\z/)
        record.errors.add(attribute, (options[:message] || 'is not a valid UUID'))
      end
    end
  end

  class HexColorValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.to_s.match?(/\A#(?:[0-9a-fA-F]{3}){1,2}\z/)
        record.errors.add(attribute, (options[:message] || 'is not a valid hex color'))
      end
    end
  end

  class IpValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.to_s.match?(/\A(?:\d{1,3}\.){3}\d{1,3}\z/)
        record.errors.add(attribute, (options[:message] || 'is not a valid IPv4 address'))
      end
    end
  end

  class MacAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.to_s.match?(/\A(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\z/)
        record.errors.add(attribute, (options[:message] || 'is not a valid MAC address'))
      end
    end
  end

  class HashtagValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.to_s.match?(/\A\w+\z/)
        record.errors.add(attribute, (options[:message] || 'is not a valid hashtag'))
      end
    end
  end

  class MentionValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.to_s.match?(/\A\w+\z/)
        record.errors.add(attribute, (options[:message] || 'is not a valid mention'))
      end
    end
  end

  class TwitterHandleValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.to_s.match?(/\A\w{1,15}\z/)
        record.errors.add(attribute, (options[:message] || 'is not a valid Twitter handle'))
      end
    end
  end

  class InstagramHandleValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.to_s.match?(/\A\w{1,30}\z/)
        record.errors.add(attribute, (options[:message] || 'is not a valid Instagram handle'))
      end
    end
  end

  class UrlValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      require 'uri'
      unless value.is_a?(String) && URI::DEFAULT_PARSER.make_regexp(%w[http https]).match?(value)
        record.errors.add(attribute, (options[:message] || 'is not a valid URL'))
      end
    rescue URI::InvalidURIError
      record.errors.add(attribute, (options[:message] || 'is not a valid URL'))
    end
  end
end 