require_relative '../lib/rich_text_extraction'

def extract_from_text(text)
  extractor = RichTextExtraction::Extractor.new(text)
  {
    links: extractor.links,
    tags: extractor.tags,
    mentions: extractor.mentions
  }
end

puts "== Plain Text =="
plain = "Hello @alice, check out #ruby and visit https://example.com"
puts extract_from_text(plain)

puts "== DOCX =="
begin
  require 'docx'
  doc = Docx::Document.open('test/fixtures/example.docx')
  text = doc.paragraphs.map(&:text).join("\n")
  puts extract_from_text(text)
rescue LoadError, Errno::ENOENT
  puts "DOCX test skipped (missing gem or file)"
end

puts "== PDF =="
begin
  require 'pdf-reader'
  reader = PDF::Reader.new('test/fixtures/example.pdf')
  text = reader.pages.map(&:text).join("\n")
  puts extract_from_text(text)
rescue LoadError, Errno::ENOENT
  puts "PDF test skipped (missing gem or file)"
end

puts "== HTML =="
begin
  require 'nokogiri'
  html = File.read('test/fixtures/example.html')
  text = Nokogiri::HTML(html).text
  puts extract_from_text(text)
rescue LoadError, Errno::ENOENT
  puts "HTML test skipped (missing gem or file)"
end

puts "== Markdown =="
begin
  text = File.read('test/fixtures/example.md')
  puts extract_from_text(text)
rescue Errno::ENOENT
  puts "Markdown test skipped (missing file)"
end

puts "== CSV =="
begin
  require 'csv'
  text = CSV.read('test/fixtures/example.csv').flatten.join("\n")
  puts extract_from_text(text)
rescue LoadError, Errno::ENOENT
  puts "CSV test skipped (missing gem or file)"
end

puts "== JSON =="
begin
  require 'json'
  data = JSON.parse(File.read('test/fixtures/example.json'))
  # Flatten all string values (simple approach)
  text = data.values.flatten.join("\n")
  puts extract_from_text(text)
rescue LoadError, Errno::ENOENT
  puts "JSON test skipped (missing gem or file)"
end

puts "== Unified DRY Extraction =="
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
      puts "Results for #{filename}:"
      puts result.inspect
    rescue LoadError => e
      puts "#{filename} skipped (missing gem): #{e.message}"
    rescue => e
      puts "#{filename} error: #{e.class}: #{e.message}"
    end
  else
    puts "#{filename} skipped (missing file)"
  end
end

puts "== Identifier Extraction =="
identifier_text = "EAN: 9781234567897 UPC: 123456789012 ISBN: 978-3-16-148410-0 UUID: 123e4567-e89b-12d3-a456-426614174000 Card: 4111 1111 1111 1111 Color: #fff IP: 192.168.1.1"
extractor = RichTextExtraction::Extractor.new(identifier_text)
puts "EAN-13:        #{extractor.extract(:ean13)}"
puts "UPC-A:         #{extractor.extract(:upca)}"
puts "ISBN:          #{extractor.extract(:isbn)}"
puts "UUID:          #{extractor.extract(:uuid)}"
puts "Credit Cards:  #{extractor.extract(:credit_cards)}"
puts "Hex Colors:    #{extractor.extract(:hex_colors)}"
puts "IPs:           #{extractor.extract(:ips)}"
puts "VIN:           #{extractor.extract(:vin)}"
puts "IMEI:          #{extractor.extract(:imei)}"
puts "ISSN:          #{extractor.extract(:issn)}"
puts "MAC:           #{extractor.extract(:mac)}"
puts "IBAN:          #{extractor.extract(:iban)}"

puts "== IBAN Validation =="
iban_text = "Valid: GB82WEST12345698765432 Invalid: GB82WEST12345698765431"
iban_extractor = RichTextExtraction::Extractor.new(iban_text)
puts "Extracted IBANs: #{iban_extractor.extract(:iban)}" # Should only include the valid one

puts "== Credit Card Validation =="
cc_text = "Valid: 4111 1111 1111 1111 Invalid: 4111 1111 1111 1112"
cc_extractor = RichTextExtraction::Extractor.new(cc_text)
puts "Extracted Credit Cards: #{cc_extractor.extract(:credit_cards)}" # Should only include the valid one

puts "== ISBN Validation =="
isbn_text = "Valid: 978-3-16-148410-0 Invalid: 978-3-16-148410-1"
isbn_extractor = RichTextExtraction::Extractor.new(isbn_text)
puts "Extracted ISBNs: #{isbn_extractor.extract(:isbn)}" # Should only include the valid one

puts "== VIN Validation =="
vin_text = "Valid: 1HGCM82633A004352 Invalid: 1HGCM82633A004353"
vin_extractor = RichTextExtraction::Extractor.new(vin_text)
puts "Extracted VINs: #{vin_extractor.extract(:vin)}" # Should only include the valid one

# Add ODT and other formats as needed 