# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RichTextExtraction::Validators::UrlValidator do
  let(:validator) { described_class.new }

  describe 'initialization' do
    it 'creates a new URL validator' do
      expect(validator).to be_a(described_class)
    end
  end

  describe '#valid?' do
    it 'validates HTTP URLs' do
      expect(validator.valid?('http://example.com')).to be true
      expect(validator.valid?('http://www.example.com')).to be true
      expect(validator.valid?('http://subdomain.example.com')).to be true
    end

    it 'validates HTTPS URLs' do
      expect(validator.valid?('https://example.com')).to be true
      expect(validator.valid?('https://www.example.com')).to be true
      expect(validator.valid?('https://secure.example.com')).to be true
    end

    it 'validates URLs with paths' do
      expect(validator.valid?('https://example.com/path')).to be true
      expect(validator.valid?('https://example.com/path/to/page')).to be true
      expect(validator.valid?('https://example.com/path-with-dashes')).to be true
    end

    it 'validates URLs with query parameters' do
      expect(validator.valid?('https://example.com?param=value')).to be true
      expect(validator.valid?('https://example.com?param1=value1&param2=value2')).to be true
      expect(validator.valid?('https://example.com/path?param=value')).to be true
    end

    it 'validates URLs with fragments' do
      expect(validator.valid?('https://example.com#section')).to be true
      expect(validator.valid?('https://example.com/path#section')).to be true
      expect(validator.valid?('https://example.com?param=value#section')).to be true
    end

    it 'validates URLs with ports' do
      expect(validator.valid?('http://localhost:3000')).to be true
      expect(validator.valid?('https://example.com:8080')).to be true
    end

    it 'validates URLs with special characters' do
      expect(validator.valid?('https://example.com/path_with_underscores')).to be true
      expect(validator.valid?('https://example.com/path-with-dashes')).to be true
      expect(validator.valid?('https://example.com/path.with.dots')).to be true
    end
  end

  describe 'invalid URLs' do
    it 'rejects invalid protocols' do
      expect(validator.valid?('ftp://example.com')).to be false
      expect(validator.valid?('smtp://example.com')).to be false
      expect(validator.valid?('javascript:alert(1)')).to be false
    end

    it 'rejects malformed URLs' do
      expect(validator.valid?('not-a-url')).to be false
      expect(validator.valid?('example.com')).to be false
      expect(validator.valid?('http://')).to be false
      expect(validator.valid?('https://')).to be false
    end

    it 'rejects empty or nil values' do
      expect(validator.valid?('')).to be false
      expect(validator.valid?(nil)).to be false
    end

    it 'rejects URLs with invalid characters' do
      expect(validator.valid?('http://example.com/<script>')).to be false
      expect(validator.valid?('http://example.com/alert(1)')).to be false
    end
  end

  describe 'edge cases' do
    it 'handles very long URLs' do
      long_url = "https://example.com/#{'a' * 1000}"
      expect(validator.valid?(long_url)).to be true
    end

    it 'handles URLs with unicode characters' do
      expect(validator.valid?('https://example.com/path/with/unicode/ñáéíóú')).to be true
    end

    it 'handles URLs with numbers' do
      expect(validator.valid?('https://example123.com')).to be true
      expect(validator.valid?('https://123example.com')).to be true
    end

    it 'handles URLs with mixed case' do
      expect(validator.valid?('HTTP://EXAMPLE.COM')).to be true
      expect(validator.valid?('HttPs://ExAmPlE.cOm')).to be true
    end
  end

  describe 'performance' do
    it 'validates URLs efficiently' do
      urls = [
        'https://example.com',
        'http://test.org',
        'https://sub.domain.co.uk/path?param=value#section'
      ]
      
      start_time = Time.current
      1000.times do
        urls.each { |url| validator.valid?(url) }
      end
      end_time = Time.current
      
      expect(end_time - start_time).to be < 1.0 # Should complete within 1 second
    end
  end

  describe 'error handling' do
    it 'handles malformed input gracefully' do
      expect { validator.valid?('') }.not_to raise_error
      expect { validator.valid?(nil) }.not_to raise_error
      expect { validator.valid?('a' * 10000) }.not_to raise_error
    end

    it 'handles regex special characters in URLs' do
      special_urls = [
        'https://example.com/path?param=value[1]',
        'https://example.com/path?param=value(1)',
        'https://example.com/path?param=value{1}'
      ]
      
      special_urls.each do |url|
        expect { validator.valid?(url) }.not_to raise_error
      end
    end
  end

  describe 'integration with registry' do
    it 'can be registered in the registry' do
      component = RichTextExtraction::RegistryComponent.new(
        name: 'url_validator',
        type: 'validator',
        class_name: 'RichTextExtraction::Validators::UrlValidator'
      )
      
      expect { component.save! }.not_to raise_error
      expect(component.persisted?).to be true
    end

    it 'can be retrieved from the registry' do
      validator_class = RichTextExtraction::Registry.get_validator('url_validator')
      expect(validator_class).to eq(RichTextExtraction::Validators::UrlValidator)
    end
  end
end 