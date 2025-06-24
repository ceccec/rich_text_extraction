# frozen_string_literal: true

# RichTextExtraction::Extractors::Validators provides validation logic and ActiveModel validators for all supported identifiers and patterns.
module RichTextExtraction
  module Extractors
    module Validators
      # ISBN checksum validation (ISBN-10/13, ISO 2108)
      def self.valid_isbn?(isbn)
        digits = isbn.gsub(/[^0-9Xx]/, '').upcase
        result = if digits.length == 10
                   sum = digits.chars.each_with_index.sum { |d, i| (d == 'X' ? 10 : d.to_i) * (10 - i) }
                   (sum % 11).zero?
                 elsif digits.length == 13
                   sum = digits.chars.each_with_index.sum { |d, i| d.to_i * (i.even? ? 1 : 3) }
                   (sum % 10).zero?
                 else
                   false
                 end
        Rails.logger.debug { "[DEBUG] valid_isbn?(#{isbn.inspect}) => #{result}" }
        result
      end

      # VIN check digit validation (ISO 3779)
      def self.valid_vin?(vin)
        map = ('A'..'Z').to_a.zip([1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5, 6, 7]).to_h
        weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
        vin = vin.upcase
        result = if vin.length == 17
                   sum = vin.chars.each_with_index.sum do |char, i|
                     value = /\d/.match?(char) ? char.to_i : map[char] || 0
                     value * weights[i]
                   end
                   check = sum % 11
                   check_char = check == 10 ? 'X' : check.to_s
                   vin[8] == check_char
                 else
                   false
                 end
        Rails.logger.debug { "[DEBUG] valid_vin?(#{vin.inspect}) => #{result}" }
        result
      end

      # ISSN checksum validation (mod-11, ISO 3297)
      def self.valid_issn?(issn)
        digits = issn.delete('-').upcase.chars
        result = if digits.length == 8
                   sum = digits[0..6].each_with_index.sum { |d, i| d.to_i * (8 - i) }
                   check = (11 - (sum % 11)) % 11
                   check_char = check == 10 ? 'X' : check.to_s
                   digits[7] == check_char
                 else
                   false
                 end
        Rails.logger.debug { "[DEBUG] valid_issn?(#{issn.inspect}) => #{result}" }
        result
      end

      # IBAN mod-97 validation (ISO 13616)
      def self.valid_iban?(iban)
        iban = iban.gsub(/\s+/, '').upcase
        result = begin
          rearranged = iban.drop(4) + iban[0..3]
          numeric = rearranged.chars.map { |c| /[A-Z]/.match?(c) ? (c.ord - 'A'.ord + 10).to_s : c }.join
          numeric.to_i % 97 == 1
        rescue StandardError
          false
        end
        Rails.logger.debug { "[DEBUG] valid_iban?(#{iban.inspect}) => #{result}" }
        result
      end

      # Luhn algorithm for credit cards, IMEI, etc. (ISO/IEC 7812)
      def self.luhn_valid?(number)
        digits = number.gsub(/\D/, '').chars.map(&:to_i)
        sum = digits.reverse.each_slice(2).sum do |odd, even|
          [odd, (if even
                   even * 2 > 9 ? even * 2 - 9 : even * 2
                 else
                   0
                 end)].sum
        end
        result = (sum % 10).zero?
        Rails.logger.debug { "[DEBUG] luhn_valid?(#{number.inspect}) => #{result}" }
        result
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
  require_relative '../validators/isbn_validator'
  require_relative '../validators/vin_validator'
  require_relative '../validators/issn_validator'
  require_relative '../validators/iban_validator'
  require_relative '../validators/luhn_validator'
  require_relative '../validators/ean13_validator'
  require_relative '../validators/upca_validator'
  require_relative '../validators/uuid_validator'
  require_relative '../validators/hex_color_validator'
  require_relative '../validators/ip_validator'
  require_relative '../validators/mac_address_validator'
  require_relative '../validators/hashtag_validator'
  require_relative '../validators/mention_validator'
  require_relative '../validators/twitter_handle_validator'
  require_relative '../validators/instagram_handle_validator'
  require_relative '../validators/url_validator'
end
