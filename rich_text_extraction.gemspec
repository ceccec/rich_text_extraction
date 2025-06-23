# frozen_string_literal: true

require_relative 'lib/rich_text_extraction/version'

Gem::Specification.new do |spec|
  spec.name = 'rich_text_extraction'
  spec.version = RichTextExtraction::VERSION
  spec.authors = ['Tsvetan Rouschev']
  spec.email = ['675674+ceccec@users.noreply.github.com']

  spec.summary = 'Extract links, tags, mentions, and more from rich text or Markdown. Safe Markdown for Rails.'
  spec.description = <<~DESC
    RichTextExtraction provides extraction of links, tags, mentions, emails, phone numbers, and more from rich text or Markdown. It also offers safe Markdown rendering using Redcarpet, Kramdown, or CommonMarker, and integrates with ActionText in Rails.

    Features:
    - Modular architecture with service classes and focused extractors
    - Safe Markdown rendering with sanitization
    - OpenGraph metadata extraction and caching
    - Rails and ActionText integration
    - Comprehensive configuration system
    - Background job support
  DESC
  spec.homepage = 'https://github.com/ceccec/rich_text_extraction'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0', '< 4.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ceccec/rich_text_extraction'
  spec.metadata['changelog_uri'] = 'https://github.com/ceccec/rich_text_extraction/blob/main/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://ceccec.github.io/rich_text_extraction/'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/ceccec/rich_text_extraction/issues'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.end_with?('.gem') ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies (alphabetical order)
  spec.add_dependency 'activesupport', '< 8.0'
  spec.add_dependency 'commonmarker', '>= 0.23', '< 1.0'
  spec.add_dependency 'kramdown', '>= 2.4', '< 3.0'
  spec.add_dependency 'redcarpet', '>= 3.6', '< 4.0'
  spec.add_dependency 'sanitize', '>= 6.0', '< 7.0'

  # Development dependencies
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.0'
  spec.add_development_dependency 'yard', '~> 0.9'

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
