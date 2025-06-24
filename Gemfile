# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rich_text_extraction.gemspec
gemspec

gem 'irb'
gem 'rake', '~> 13.0'

gem 'activesupport', '< 8.0'
gem 'httparty'
gem 'nokogiri'
gem 'rspec', '~> 3.0'

gem 'jekyll', '>= 4.0', '< 5.0', group: :docs

# Pin erb to a version compatible with Ruby 3.1
gem 'erb', '~> 4.0'

group :development, :test do
  gem 'appraisal', require: false
  gem 'minitest'
  gem 'rails', '>= 6.0', '< 8.0'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'yard', require: false
  gem 'docx'
  gem 'pdf-reader'
  gem 'nokogiri'
  gem 'csv'
  gem 'json'
  gem 'rtf'
  gem 'roo'
end

ruby '>= 3.1.0', '< 4.0'
