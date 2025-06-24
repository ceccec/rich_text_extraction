#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/rich_text_extraction/constants'
require_relative '../lib/rich_text_extraction/validator_api'

DOC_PATH = File.expand_path('../docs/validator_reference.md', __dir__)

# Expanded logical groupings for crosslinks
groups = {
  social: %i[twitter_handle instagram_handle mention hashtag],
  barcodes: %i[ean13 upca isbn issn vin],
  network: %i[ip mac_address uuid],
  financial: %i[iban luhn credit_card],
  web: %i[url email markdown_link],
  color: %i[hex_color],
  identifier: %i[uuid iban luhn mac_address ip]
}

# Build a reverse lookup for each symbol to its group(s)
symbol_to_groups = Hash.new { |h, k| h[k] = [] }
groups.each { |group, syms| syms.each { |sym| symbol_to_groups[sym] << group } }

# Build schema.org type crosslinks
schema_type_map = Hash.new { |h, k| h[k] = [] }
RichTextExtraction::Constants::VALIDATOR_EXAMPLES.each do |symbol, entry|
  schema_type_map[entry[:schema_type]] << symbol if entry[:schema_type]
end

# API endpoint base
api_base = '/validators/'

# Drift/gap detection
missing_classes = []
missing_regex = []
RichTextExtraction::Constants::VALIDATOR_EXAMPLES.each do |symbol, entry|
  begin
    Object.const_get("#{symbol.to_s.camelize}Validator")
  rescue NameError
    missing_classes << symbol
  end
  missing_regex << symbol if entry[:regex] && !RichTextExtraction::ExtractionPatterns.const_defined?(entry[:regex])
end

# Mermaid diagram generation
def mermaid_diagram(groups, schema_type_map)
  diagram = ["graph TD"]
  groups.each do |group, syms|
    syms.each do |sym|
      diagram << "  #{group}_group[\"#{group}\"] --> #{sym}"
    end
  end
  schema_type_map.each do |stype, syms|
    next unless stype && syms.size > 1
    syms.combination(2) do |a, b|
      diagram << "  #{a} -- schema.org:#{stype} --> #{b}"
    end
  end
  diagram.join("\n")
end

File.open(DOC_PATH, 'w') do |f|
  f.puts "# Validator Reference\n"
  f.puts "> **DRY, Doc-Driven, and Always In Sync!**\n> This documentation is auto-generated from the single source of truth: `VALIDATOR_EXAMPLES`.\n> All validator logic, tests, and docs are always in sync. To add or update a validator, just edit `VALIDATOR_EXAMPLES`.\n"
  if missing_classes.any? || missing_regex.any?
    f.puts "> **Warning:** Drift detected!\n>"
    f.puts "> The following issues were found and must be fixed for full DRYness and test coverage:\n>"
    f.puts "> - Missing validator classes: #{missing_classes.map(&:to_s).join(', ')}\n>" if missing_classes.any?
    f.puts "> - Missing regex constants: #{missing_regex.map(&:to_s).join(', ')}\n>" if missing_regex.any?
    f.puts "> Please update the codebase so all validators in VALIDATOR_EXAMPLES have a class and (if needed) a regex.\n>"
  end
  f.puts "> **Note:** This documentation is the source of truth for both the API and automated tests. All examples below are used as test scenarios and match the API structure.\n"
  f.puts "This file is auto-generated from the gem's DRY validator structure.\n"
  f.puts "[Usage Guide](usage.md) | [API Reference](api.markdown)\n"
  f.puts "\n## Validator Relationships\n"
  f.puts "```mermaid\n#{mermaid_diagram(groups, schema_type_map)}\n```\n"
  RichTextExtraction::Constants::VALIDATOR_EXAMPLES.each do |symbol, entry|
    meta = RichTextExtraction::ValidatorAPI.metadata(symbol)
    ex = RichTextExtraction::ValidatorAPI.examples(symbol)
    regex = RichTextExtraction::ValidatorAPI.regex(symbol)
    f.puts "## `#{symbol}`"
    f.puts "- **Schema.org Type:** [`#{meta[:schema_type]}`](https://schema.org/#{meta[:schema_type]})" if meta[:schema_type]
    f.puts "- **Schema.org Property:** [`#{meta[:schema_property]}`](https://schema.org/#{meta[:schema_property]})" if meta[:schema_property]
    f.puts "- **Description:** #{meta[:description]}" if meta[:description]
    f.puts "- **Regex:** `#{regex}`" if regex
    f.puts "- **Valid examples:** `#{Array(ex[:valid]).join('`, `')}`"
    f.puts "- **Invalid examples:** `#{Array(ex[:invalid]).join('`, `')}`"
    # Add See also crosslinks by group
    related = symbol_to_groups[symbol].flat_map { |g| groups[g] }.uniq - [symbol]
    if related.any?
      f.puts "- **See also (group):** " + related.map { |s| "[`#{s}`](##{s})" }.join(', ')
    end
    # Add schema.org crosslinks
    stype = meta[:schema_type]
    if stype && schema_type_map[stype].size > 1
      related_schema = schema_type_map[stype] - [symbol]
      if related_schema.any?
        f.puts "- **See also (schema.org):** " + related_schema.map { |s| "[`#{s}`](##{s})" }.join(', ')
      end
    end
    # Add API endpoint crosslink
    f.puts "- **API endpoint:** [`POST #{api_base}#{symbol}/validate`](api.markdown#validatorsidvalidate)"
    # Add usage guide crosslink
    f.puts "- **Usage example:** [Usage Guide](usage.md#using-validators-in-rails-models)"
    f.puts
    # Test Scenarios Table
    f.puts "### Test Scenarios\n"
    f.puts "| Input | Expected Result | Example API Request | Example API Response |"
    f.puts "|-------|----------------|--------------------|---------------------|"
    Array(ex[:valid]).each do |v|
      req = "{\"value\": \"#{v}\"}"
      res = "{\"valid\": true, \"errors\": []}"
      f.puts "| `#{v}` | ✅ valid | <pre>#{req}</pre> | <pre>#{res}</pre> |"
    end
    Array(ex[:invalid]).each do |v|
      req = "{\"value\": \"#{v}\"}"
      res = "{\"valid\": false, \"errors\": [\"..."]}" # error message is dynamic
      f.puts "| `#{v}` | ❌ invalid | <pre>#{req}</pre> | <pre>#{res}</pre> |"
    end
    f.puts
  end
end

puts "Documentation generated at #{DOC_PATH}"

if missing_classes.any? || missing_regex.any?
  exit 1
end 