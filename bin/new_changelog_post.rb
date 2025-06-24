#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'fileutils'

POSTS_DIR = File.expand_path('../docs/_posts', __dir__)
INDEX_PATH = File.expand_path('../docs/changelog.md', __dir__)

# Prompt for version and date
def prompt(msg, default = nil)
  Rails.logger.debug { "#{msg}#{default ? " [#{default}]" : ''}: " }
  input = gets.strip
  input.empty? && default ? default : input
end

def create_post(version, date)
  filename = "#{date}-changelog-v#{version}.md"
  path = File.join(POSTS_DIR, filename)
  if File.exist?(path)
    Rails.logger.debug { "Post already exists: #{path}" }
    return
  end
  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts "title: \"Changelog v#{version}\""
    f.puts "date: #{date}"
    f.puts 'categories: changelog'
    f.puts '---'
    f.puts
    f.puts "## [v#{version}] - #{date}"
    f.puts
    f.puts "### Added\n- "
    f.puts "\n### Changed\n- "
    f.puts "\n### Fixed\n- "
    f.puts "\n### Docs\n- "
  end
  Rails.logger.debug { "Created: #{path}" }
end

def update_index
  posts = Dir[File.join(POSTS_DIR, '*.md')]
  posts = posts.map { |p| File.basename(p) }.sort.reverse
  File.open(INDEX_PATH, 'w') do |f|
    f.puts "# Changelog\n"
    f.puts "All notable changes are documented as posts:\n"
    posts.each do |post|
      # Extract version and date from filename
      next unless post =~ /(\d{4}-\d{2}-\d{2})-changelog-v([\d.]+)\.md/

      date = Regexp.last_match(1)
      version = Regexp.last_match(2)
      f.puts "- [v#{version} - #{date}](_posts/#{post})"
    end
    f.puts "\nOr browse all [changelog posts](_posts/)."
  end
  Rails.logger.debug { "Updated: #{INDEX_PATH}" }
end

# Main
version = prompt('Version', '1.2.0')
date = prompt('Date (YYYY-MM-DD)', Date.today.to_s)
create_post(version, date)
update_index
