# frozen_string_literal: true

require_relative 'validators'
require_relative '../extraction_patterns'

# RichTextExtraction::IdentifierExtractor provides extraction methods for barcodes, UUIDs, credit cards, colors, IPs, VINs, IMEIs, ISSNs, MAC addresses, and IBANs.
module RichTextExtraction
  module IdentifierExtractor
    # EAN-13 barcode (13 digits, pattern only, no checksum)
    def self.extract_ean13(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::EAN13_REGEX)
    end

    # UPC-A barcode (12 digits, pattern only, no checksum)
    def self.extract_upca(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::UPCA_REGEX)
    end

    # ISBN-10 or ISBN-13 (checksum validation, ISO 2108)
    def self.extract_isbn(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::ISBN_REGEX).select do |isbn|
        RichTextExtraction::Extractors::Validators.valid_isbn?(isbn)
      end
    end

    # UUID/GUID (pattern only, RFC 4122)
    def self.extract_uuids(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::UUID_REGEX)
    end

    # Credit card numbers (Luhn validation, ISO/IEC 7812)
    def self.extract_credit_cards(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::CREDIT_CARD_REGEX).select { |cc| RichTextExtraction::Extractors::Validators.luhn_valid?(cc) }
    end

    # Hex colors (pattern only, CSS)
    def self.extract_hex_colors(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::HEX_COLOR_REGEX)
    end

    # IP addresses (pattern only, IPv4)
    def self.extract_ips(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::IP_REGEX)
    end

    # VIN (17 chars, check digit validation, ISO 3779)
    def self.extract_vins(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::VIN_REGEX).select { |vin| RichTextExtraction::Extractors::Validators.valid_vin?(vin) }
    end

    # IMEI (15 digits, Luhn validation, 3GPP TS 23.003)
    def self.extract_imeis(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::IMEI_REGEX).select { |imei| RichTextExtraction::Extractors::Validators.luhn_valid?(imei) }
    end

    # ISSN (8 digits, checksum validation, ISO 3297)
    def self.extract_issns(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::ISSN_REGEX).select { |issn| RichTextExtraction::Extractors::Validators.valid_issn?(issn) }
    end

    # MAC address (pattern only)
    def self.extract_mac_addresses(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::MAC_ADDRESS_REGEX)
    end

    # IBAN (mod-97 validation, ISO 13616)
    def self.extract_ibans(text)
      text.to_s.scan(RichTextExtraction::ExtractionPatterns::IBAN_REGEX).select { |iban| RichTextExtraction::Extractors::Validators.valid_iban?(iban) }
    end
  end
end
