# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['-A']
end

task default: %i[rubocop spec]

desc 'Generate YARD Documentation'
task yard: :environment do
  sh 'yard doc --output-dir docs/api'
end

desc 'Create a new changelog post (interactive)'
task 'docs:new_changelog' => :environment do
  Rails.logger.debug 'Running bin/new_changelog_post.rb...'
  system('ruby bin/new_changelog_post.rb')
end

desc 'Regenerate tag pages for changelog posts'
task 'docs:generate_tags' => :environment do
  Rails.logger.debug 'Running bin/generate_tag_pages.rb...'
  system('ruby bin/generate_tag_pages.rb')
end

desc 'Generate YARD API documentation (output to docs/api)'
task 'docs:yard' => :environment do
  sh 'yard doc --output-dir docs/api'
end

desc 'Run all docs automation tasks (YARD API, changelog, tags)'
task 'docs:all' => ['docs:yard', 'docs:new_changelog', 'docs:generate_tags']

desc 'Run RuboCop for code linting'
task rubocop: :environment do
  Rails.logger.debug 'Running RuboCop...'
  sh 'bundle exec rubocop'
end

desc 'Lint Markdown files'
task 'lint:markdown' => :environment do
  Rails.logger.debug 'Running markdownlint...'
  sh 'npx markdownlint "docs/**/*.md"'
end

desc 'Spell check docs'
task 'lint:spell' => :environment do
  Rails.logger.debug 'Running cspell...'
  sh 'npx cspell "docs/**/*.md"'
end

desc 'Check built HTML for issues'
task 'lint:html' => :environment do
  Rails.logger.debug 'Running html-proofer...'
  sh 'bundle exec htmlproofer ./docs/_site'
end

desc 'Run all linting/quality checks'
task 'quality' => [:rubocop, 'lint:markdown', 'lint:spell', 'lint:html']

desc 'Run the test suite (with all quality/linting checks)'
task test: :quality do
  Rails.logger.debug 'Running tests...'
  sh 'bundle exec rspec'
end

desc 'Extract test scenarios from documentation and run doc-driven tests and doc generation (drift detection)'
task 'test:scenarios_from_docs' do
  puts 'Running doc-driven validator tests from VALIDATOR_EXAMPLES...'
  sh 'ruby bin/doc_driven_validator_spec.rb'
  puts 'Generating validator documentation from VALIDATOR_EXAMPLES...'
  sh 'ruby bin/generate_validator_docs.rb'
end
