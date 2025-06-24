# frozen_string_literal: true

require_relative 'validators'

module RichTextExtraction
  module IdentifierExtractor
    # EAN-13 barcode (13 digits, pattern only, no checksum)
    def self.extract_ean13(text)
      text.to_s.scan(/\b\d{13}\b/)
    end

    # UPC-A barcode (12 digits, pattern only, no checksum)
    def self.extract_upca(text)
      text.to_s.scan(/\b\d{12}\b/)
    end

    # ISBN-10 or ISBN-13 (checksum validation, ISO 2108)
    def self.extract_isbn(text)
      text.to_s.scan(/\b(?:ISBN(?:-1[03])?:? )?(?=[-0-9 ]{13,17}$)97[89][- ]?\d{1,5}[- ]?\d{1,7}[- ]?\d{1,7}[- ]?\d\b|\b\d{9}[\dXx]\b/).select { |isbn| RichTextExtraction::Extractors::Validators.valid_isbn?(isbn) }
    end

    # UUID/GUID (pattern only, RFC 4122)
    def self.extract_uuids(text)
      text.to_s.scan(/\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b/)
    end

    # Credit card numbers (Luhn validation, ISO/IEC 7812)
    def self.extract_credit_cards(text)
      text.to_s.scan(/\b(?:\d[ -]*?){13,16}\b/).select { |cc| RichTextExtraction::Extractors::Validators.luhn_valid?(cc) }
    end

    # Hex colors (pattern only, CSS)
    def self.extract_hex_colors(text)
      text.to_s.scan(/#(?:[0-9a-fA-F]{3}){1,2}\b/)
    end

    # IP addresses (pattern only, IPv4)
    def self.extract_ips(text)
      text.to_s.scan(/\b(?:\d{1,3}\.){3}\d{1,3}\b/)
    end

    # VIN (17 chars, check digit validation, ISO 3779)
    def self.extract_vins(text)
      text.to_s.scan(/\b[A-HJ-NPR-Z0-9]{17}\b/i).select { |vin| RichTextExtraction::Extractors::Validators.valid_vin?(vin) }
    end

    # IMEI (15 digits, Luhn validation, 3GPP TS 23.003)
    def self.extract_imeis(text)
      text.to_s.scan(/\b\d{15}\b/).select { |imei| RichTextExtraction::Extractors::Validators.luhn_valid?(imei) }
    end

    # ISSN (8 digits, checksum validation, ISO 3297)
    def self.extract_issns(text)
      text.to_s.scan(/\b\d{4}-?\d{3}[\dXx]\b/).select { |issn| RichTextExtraction::Extractors::Validators.valid_issn?(issn) }
    end

    # MAC address (pattern only)
    def self.extract_mac_addresses(text)
      text.to_s.scan(/\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b/)
    end

    # IBAN (mod-97 validation, ISO 13616)
    def self.extract_ibans(text)
      text.to_s.scan(/\b[A-Z]{2}\d{2}[A-Z0-9]{11,30}\b/).select { |iban| RichTextExtraction::Extractors::Validators.valid_iban?(iban) }
    end
  end
end 