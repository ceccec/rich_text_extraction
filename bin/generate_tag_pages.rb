#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'yaml'

POSTS_DIR = File.expand_path('../docs/_posts', __dir__)
TAGS_DIR = File.expand_path('../docs/tag', __dir__)
FileUtils.mkdir_p(TAGS_DIR)

# Optional: Tag descriptions
TAG_DESCRIPTIONS = {
  'feature' => 'New features and enhancements.',
  'bugfix' => 'Bug fixes and stability improvements.',
  'breaking' => 'Breaking changes requiring migration.',
  'docs' => 'Documentation updates and improvements.',
  'security' => 'Security-related changes.',
  'performance' => 'Performance improvements.'
}.freeze

# Collect all tags and posts
posts = Dir[File.join(POSTS_DIR, '*.md')]
tags_map = Hash.new { |h, k| h[k] = [] }

posts.each do |post_path|
  content = File.read(post_path)
  next unless content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m

  front_matter = YAML.safe_load(Regexp.last_match(1))
  tags = front_matter['tags'] || []
  tags = [tags] if tags.is_a?(String)
  tags.each do |tag|
    tags_map[tag] << File.basename(post_path)
  end
end

# Generate navigation for all tags
all_tags = tags_map.keys.sort
nav_html = "<nav><strong>Tags:</strong> #{all_tags.map { |t| "<a href='#{t}.html'>#{t}</a>" }.join(', ')}</nav>"

# Generate a tag page for each tag
TAGS_DIR_REL = 'tag'
tags_map.each do |tag, post_files|
  tag_slug = tag.downcase.gsub(/[^a-z0-9]+/, '-')
  path = File.join(TAGS_DIR, "#{tag_slug}.md")
  description = TAG_DESCRIPTIONS[tag] || ''
  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: default'
    f.puts "title: 'Changelog: #{tag}'"
    f.puts "tag: #{tag}"
    f.puts '---'
    f.puts
    f.puts nav_html
    f.puts "\n# Changelog: #{tag}\n"
    f.puts "<p>#{description}</p>" unless description.empty?
    f.puts "<input type='text' id='tag-search' placeholder='Search within #{tag}...'>"
    f.puts "<ul id='tag-list'>"
    post_files.sort.reverse_each do |post_file|
      next unless post_file =~ /(\d{4}-\d{2}-\d{2})-changelog-v([\d.]+)\.md/

      date = Regexp.last_match(1)
      version = Regexp.last_match(2)
      title = "v#{version} - #{date}"
      f.puts "  <li><a href='../_posts/#{post_file}'>#{title}</a></li>"
    end
    f.puts '</ul>'
    f.puts <<~JS
      <script>
      document.addEventListener('DOMContentLoaded', function() {
        var search = document.getElementById('tag-search');
        if (!search) return;
        var list = document.getElementById('tag-list');
        var items = list.getElementsByTagName('li');
        search.addEventListener('input', function() {
          var val = search.value.toLowerCase();
          for (var i = 0; i < items.length; i++) {
            var text = items[i].textContent.toLowerCase();
            items[i].style.display = text.includes(val) ? '' : 'none';
          }
        });
      });
      </script>
    JS
  end
  Rails.logger.debug { "Generated tag page: #{path}" }
end
