#!/usr/bin/env ruby
require 'yaml'

BANNER = <<~BANNER
  # This file is auto-generated from docs/_data/test_scenarios.yml.
  # Do not edit directly! Edit the YAML and run bin/generate_scenario_tests.rb.
BANNER

yaml = YAML.load_file('docs/_data/test_scenarios.yml')
validators = yaml['validators'] || {}

File.open('spec/generated_scenarios_spec.rb', 'w') do |f|
  f.puts BANNER
  f.puts "require 'rails_helper'"
  f.puts
  f.puts "RSpec.describe 'Doc-driven Validator Scenarios', type: :model do"
  validators.each do |validator, cases|
    Array(cases['valid']).each do |example|
      f.puts "  it '#{validator} accepts valid example: #{example.inspect}' do"
      f.puts "    expect(RichTextExtraction::ValidatorAPI.validate(:#{validator}, #{example.inspect})[:valid]).to be true"
      f.puts "  end"
    end
    Array(cases['invalid']).each do |example|
      f.puts "  it '#{validator} rejects invalid example: #{example.inspect}' do"
      f.puts "    expect(RichTextExtraction::ValidatorAPI.validate(:#{validator}, #{example.inspect})[:valid]).to be false"
      f.puts "  end"
    end
  end
  f.puts "end"
end
puts "Generated spec/generated_scenarios_spec.rb from docs/_data/test_scenarios.yml." 