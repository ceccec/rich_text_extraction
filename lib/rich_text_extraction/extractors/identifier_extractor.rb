# frozen_string_literal: true

require_relative 'validators'
require_relative '../extractors/extraction_patterns'
require_relative 'base_extractor'

module RichTextExtraction
  module Extractors
    # RichTextExtraction::IdentifierExtractor provides extraction methods for barcodes, UUIDs, credit cards, colors, IPs, VINs, IMEIs, ISSNs, MAC addresses, and IBANs.
    # It uses the BaseExtractor module to eliminate code duplication and provide consistent extraction patterns.
    class IdentifierExtractor
      extend RichTextExtraction::Extractors::BaseExtractor

      def extract(text, options = {})
        {
          ean13: self.class.extract_ean13(text),
          upca: self.class.extract_upca(text),
          isbn: self.class.extract_isbn(text),
          uuids: self.class.extract_uuids(text),
          credit_cards: self.class.extract_credit_cards(text),
          hex_colors: self.class.extract_hex_colors(text),
          ips: self.class.extract_ips(text),
          vins: self.class.extract_vins(text),
          imeis: self.class.extract_imeis(text),
          issns: self.class.extract_issns(text),
          mac_addresses: self.class.extract_mac_addresses(text),
          ibans: self.class.extract_ibans(text)
        }
      end

      # Class method for consistent API
      def self.extract(text, options = {})
        new.extract(text, options)
      end

      # EAN-13 barcode (13 digits, pattern only, no checksum)
      def self.extract_ean13(text)
        extract_pattern(text, RichTextExtraction::Extractors::ExtractionPatterns::EAN13_REGEX)
      end

      # UPC-A barcode (12 digits, pattern only, no checksum)
      def self.extract_upca(text)
        extract_pattern(text, RichTextExtraction::Extractors::ExtractionPatterns::UPCA_REGEX)
      end

      # ISBN-10 or ISBN-13 (checksum validation, ISO 2108)
      def self.extract_isbn(text)
        extract_with_validation(text, RichTextExtraction::Extractors::ExtractionPatterns::ISBN_REGEX, :valid_isbn?)
      end

      # UUID/GUID (pattern only, RFC 4122)
      def self.extract_uuids(text)
        extract_pattern(text, RichTextExtraction::Extractors::ExtractionPatterns::UUID_REGEX)
      end

      # Credit card numbers (Luhn validation, ISO/IEC 7812)
      def self.extract_credit_cards(text)
        extract_with_validation(text, RichTextExtraction::Extractors::ExtractionPatterns::CREDIT_CARD_REGEX,
                                :luhn_valid?)
      end

      # Hex colors (pattern only, CSS)
      def self.extract_hex_colors(text)
        extract_pattern(text, RichTextExtraction::Extractors::ExtractionPatterns::HEX_COLOR_REGEX)
      end

      # IP addresses (pattern only, IPv4)
      def self.extract_ips(text)
        extract_pattern(text, RichTextExtraction::Extractors::ExtractionPatterns::IP_REGEX)
      end

      # VIN (17 chars, check digit validation, ISO 3779)
      def self.extract_vins(text)
        extract_with_validation(text, RichTextExtraction::Extractors::ExtractionPatterns::VIN_REGEX, :valid_vin?)
      end

      # IMEI (15 digits, Luhn validation, 3GPP TS 23.003)
      def self.extract_imeis(text)
        extract_with_validation(text, RichTextExtraction::Extractors::ExtractionPatterns::IMEI_REGEX, :luhn_valid?)
      end

      # ISSN (8 digits, checksum validation, ISO 3297)
      def self.extract_issns(text)
        extract_with_validation(text, RichTextExtraction::Extractors::ExtractionPatterns::ISSN_REGEX, :valid_issn?)
      end

      # MAC address (pattern only)
      def self.extract_mac_addresses(text)
        extract_pattern(text, RichTextExtraction::Extractors::ExtractionPatterns::MAC_ADDRESS_REGEX)
      end

      # IBAN (mod-97 validation, ISO 13616)
      def self.extract_ibans(text)
        extract_with_validation(text, RichTextExtraction::Extractors::ExtractionPatterns::IBAN_REGEX, :valid_iban?)
      end

      # Delegate validation methods to the Validators module
      def self.valid_isbn?(value)
        RichTextExtraction::Extractors::Validators.valid_isbn?(value)
      end

      def self.luhn_valid?(value)
        RichTextExtraction::Extractors::Validators.luhn_valid?(value)
      end

      def self.valid_vin?(value)
        RichTextExtraction::Extractors::Validators.valid_vin?(value)
      end

      def self.valid_issn?(value)
        RichTextExtraction::Extractors::Validators.valid_issn?(value)
      end

      def self.valid_iban?(value)
        RichTextExtraction::Extractors::Validators.valid_iban?(value)
      end
    end
  end
end
