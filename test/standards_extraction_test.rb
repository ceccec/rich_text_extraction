# frozen_string_literal: true

require_relative '../lib/rich_text_extraction'

def extract_from_text(text)
  extractor = RichTextExtraction::Extractor.new(text)
  {
    links: extractor.links,
    tags: extractor.tags,
    mentions: extractor.mentions
  }
end

Rails.logger.debug '== Plain Text =='
plain = 'Hello @alice, check out #ruby and visit https://example.com'
Rails.logger.debug extract_from_text(plain)

Rails.logger.debug '== DOCX =='
begin
  require 'docx'
  doc = Docx::Document.open('test/fixtures/example.docx')
  text = doc.paragraphs.map(&:text).join("\n")
  Rails.logger.debug extract_from_text(text)
rescue LoadError, Errno::ENOENT
  Rails.logger.debug 'DOCX test skipped (missing gem or file)'
end

Rails.logger.debug '== PDF =='
begin
  require 'pdf-reader'
  reader = PDF::Reader.new('test/fixtures/example.pdf')
  text = reader.pages.map(&:text).join("\n")
  Rails.logger.debug extract_from_text(text)
rescue LoadError, Errno::ENOENT
  Rails.logger.debug 'PDF test skipped (missing gem or file)'
end

Rails.logger.debug '== HTML =='
begin
  require 'nokogiri'
  html = File.read('test/fixtures/example.html')
  text = Nokogiri::HTML(html).text
  Rails.logger.debug extract_from_text(text)
rescue LoadError, Errno::ENOENT
  Rails.logger.debug 'HTML test skipped (missing gem or file)'
end

Rails.logger.debug '== Markdown =='
begin
  text = File.read('test/fixtures/example.md')
  Rails.logger.debug extract_from_text(text)
rescue Errno::ENOENT
  Rails.logger.debug 'Markdown test skipped (missing file)'
end

Rails.logger.debug '== CSV =='
begin
  require 'csv'
  text = CSV.read('test/fixtures/example.csv').flatten.join("\n")
  Rails.logger.debug extract_from_text(text)
rescue LoadError, Errno::ENOENT
  Rails.logger.debug 'CSV test skipped (missing gem or file)'
end

Rails.logger.debug '== JSON =='
begin
  require 'json'
  data = JSON.parse(File.read('test/fixtures/example.json'))
  # Flatten all string values (simple approach)
  text = data.values.flatten.join("\n")
  Rails.logger.debug extract_from_text(text)
rescue LoadError, Errno::ENOENT
  Rails.logger.debug 'JSON test skipped (missing gem or file)'
end

Rails.logger.debug '== Unified DRY Extraction =='
%w[
  example.txt
  example.md
  example.html
  example.docx
  example.pdf
  example.csv
  example.json
  example.odt
  example.epub
  example.rtf
  example.xlsx
  example.pptx
  example.xml
  example.yaml
  example.tex
].each do |filename|
  path = File.join('test/fixtures', filename)
  if File.exist?(path)
    begin
      result = RichTextExtraction.extract_from_file(path)
      Rails.logger.debug { "Results for #{filename}:" }
      Rails.logger.debug result.inspect
    rescue LoadError => e
      Rails.logger.debug { "#{filename} skipped (missing gem): #{e.message}" }
    rescue StandardError => e
      Rails.logger.debug { "#{filename} error: #{e.class}: #{e.message}" }
    end
  else
    Rails.logger.debug { "#{filename} skipped (missing file)" }
  end
end

Rails.logger.debug '== Identifier Extraction =='
identifier_text = 'EAN: 9781234567897 UPC: 123456789012 ISBN: 978-3-16-148410-0 UUID: 123e4567-e89b-12d3-a456-426614174000 Card: 4111 1111 1111 1111 Color: #fff IP: 192.168.1.1'
extractor = RichTextExtraction::Extractor.new(identifier_text)
Rails.logger.debug { "EAN-13:        #{extractor.extract(:ean13)}" }
Rails.logger.debug { "UPC-A:         #{extractor.extract(:upca)}" }
Rails.logger.debug { "ISBN:          #{extractor.extract(:isbn)}" }
Rails.logger.debug { "UUID:          #{extractor.extract(:uuid)}" }
Rails.logger.debug { "Credit Cards:  #{extractor.extract(:credit_cards)}" }
Rails.logger.debug { "Hex Colors:    #{extractor.extract(:hex_colors)}" }
Rails.logger.debug { "IPs:           #{extractor.extract(:ips)}" }
Rails.logger.debug { "VIN:           #{extractor.extract(:vin)}" }
Rails.logger.debug { "IMEI:          #{extractor.extract(:imei)}" }
Rails.logger.debug { "ISSN:          #{extractor.extract(:issn)}" }
Rails.logger.debug { "MAC:           #{extractor.extract(:mac)}" }
Rails.logger.debug { "IBAN:          #{extractor.extract(:iban)}" }

Rails.logger.debug '== IBAN Validation =='
iban_text = 'Valid: GB82WEST12345698765432 Invalid: GB82WEST12345698765431'
iban_extractor = RichTextExtraction::Extractor.new(iban_text)
Rails.logger.debug { "Extracted IBANs: #{iban_extractor.extract(:iban)}" } # Should only include the valid one

Rails.logger.debug '== Credit Card Validation =='
cc_text = 'Valid: 4111 1111 1111 1111 Invalid: 4111 1111 1111 1112'
cc_extractor = RichTextExtraction::Extractor.new(cc_text)
# Should only include the valid one
Rails.logger.debug do
  "Extracted Credit Cards: #{cc_extractor.extract(:credit_cards)}"
end
Rails.logger.debug '== ISBN Validation =='
isbn_text = 'Valid: 978-3-16-148410-0 Invalid: 978-3-16-148410-1'
isbn_extractor = RichTextExtraction::Extractor.new(isbn_text)
Rails.logger.debug { "Extracted ISBNs: #{isbn_extractor.extract(:isbn)}" } # Should only include the valid one

Rails.logger.debug '== VIN Validation =='
vin_text = 'Valid: 1HGCM82633A004352 Invalid: 1HGCM82633A004353'
vin_extractor = RichTextExtraction::Extractor.new(vin_text)
Rails.logger.debug { "Extracted VINs: #{vin_extractor.extract(:vin)}" } # Should only include the valid one

# Add ODT and other formats as needed
