#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'json'

yaml = YAML.load_file('docs/_data/translations.yml')
yaml.each do |lang, translations|
  File.write("docs/assets/i18n/#{lang}.json", JSON.pretty_generate(translations))
end
Rails.logger.debug 'Synced translations to JS JSON files.'
