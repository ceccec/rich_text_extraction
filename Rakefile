# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Generate YARD Documentation'
task :yard do
  sh 'yard doc --output-dir docs/api'
end
