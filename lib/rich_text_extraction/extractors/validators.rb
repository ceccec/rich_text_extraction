# frozen_string_literal: true

# RichTextExtraction::Extractors::Validators provides validation logic and ActiveModel validators for all supported identifiers and patterns.
# This module contains the core validation methods used by the validator classes.
module RichTextExtraction
  module Extractors
    module Validators
      # ISBN checksum validation (ISBN-10/13, ISO 2108)
      # @param isbn [String]
      # @return [Boolean]
      def self.valid_isbn?(isbn)
        digits = extract_digits(isbn, /[^0-9Xx]/)
        return false unless [10, 13].include?(digits.length)

        result = digits.length == 10 ? valid_isbn10?(digits) : valid_isbn13?(digits)
        log_result('valid_isbn?', isbn, result)
        result
      end

      # VIN check digit validation (ISO 3779)
      # @param vin [String]
      # @return [Boolean]
      def self.valid_vin?(vin)
        vin = vin.upcase
        return false unless vin.length == 17

        result = valid_vin_core?(vin)
        log_result('valid_vin?', vin, result)
        result
      end

      # ISSN checksum validation (mod-11, ISO 3297)
      # @param issn [String]
      # @return [Boolean]
      def self.valid_issn?(issn)
        digits = issn.delete('-').upcase.chars
        return false unless digits.length == 8

        result = valid_issn_core?(digits)
        log_result('valid_issn?', issn, result)
        result
      end

      # IBAN mod-97 validation (ISO 13616)
      # @param iban [String]
      # @return [Boolean]
      def self.valid_iban?(iban)
        iban = iban.gsub(/\s+/, '').upcase
        result = valid_iban_core?(iban)
        log_result('valid_iban?', iban, result)
        result
      end

      # Luhn algorithm for credit cards, IMEI, etc. (ISO/IEC 7812)
      # @param number [String]
      # @return [Boolean]
      def self.luhn_valid?(number)
        digits = number.gsub(/\D/, '').chars.map(&:to_i)
        result = luhn_valid_core?(digits)
        log_result('luhn_valid?', number, result)
        result
      end

      # URL validation using URI module
      # @param url [String]
      # @return [Boolean]
      def self.valid_url?(url)
        return false if url.nil? || url.strip.empty?

        begin
          uri = URI.parse(url)
          result = uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
          log_result('valid_url?', url, result)
          result
        rescue URI::InvalidURIError
          log_result('valid_url?', url, false)
          false
        end
      end

      def self.extract_digits(str, regex)
        str.gsub(regex, '').upcase
      end

      def self.valid_isbn10?(digits)
        sum = digits.chars.each_with_index.sum { |d, i| (d == 'X' ? 10 : d.to_i) * (10 - i) }
        (sum % 11).zero?
      end

      def self.valid_isbn13?(digits)
        sum = digits.chars.each_with_index.sum { |d, i| d.to_i * (i.even? ? 1 : 3) }
        (sum % 10).zero?
      end

      def self.valid_vin_core?(vin)
        map = ('A'..'Z').to_a.zip([1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5, 6, 7]).to_h
        weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
        sum = vin.chars.each_with_index.sum do |char, i|
          value = /\d/.match?(char) ? char.to_i : map[char] || 0
          value * weights[i]
        end
        check = sum % 11
        check_char = check == 10 ? 'X' : check.to_s
        vin[8] == check_char
      end

      def self.valid_issn_core?(digits)
        sum = digits[0..6].each_with_index.sum { |d, i| d.to_i * (8 - i) }
        check = (11 - (sum % 11)) % 11
        check_char = check == 10 ? 'X' : check.to_s
        digits[7] == check_char
      end

      def self.valid_iban_core?(iban)
        rearranged = iban[4..] + iban[0..3]
        numeric = rearranged.chars.map { |c| /[A-Z]/.match?(c) ? (c.ord - 'A'.ord + 10).to_s : c }.join
        numeric.to_i % 97 == 1
      rescue StandardError
        false
      end

      def self.luhn_valid_core?(digits)
        sum = digits.reverse.each_slice(2).sum do |odd, even|
          [odd, (if even
                   even * 2 > 9 ? even * 2 - 9 : even * 2
                 else
                   0
                 end)].sum
        end
        (sum % 10).zero?
      end

      def self.log_result(method, value, result)
        return unless defined?(::Rails) && ::Rails.logger

        ::Rails.logger.debug do
          "[DEBUG] #{method}(#{value.inspect}) => #{result}"
        end
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
