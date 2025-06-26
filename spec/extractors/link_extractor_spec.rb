# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RichTextExtraction::LinkExtractor do
  let(:extractor) { described_class.new }

  describe 'initialization' do
    it 'creates a new link extractor' do
      expect(extractor).to be_a(described_class)
    end
  end

  describe '#extract' do
    it 'extracts HTTP URLs' do
      text = 'Check out http://example.com for more info'
      result = extractor.extract(text)
      
      expect(result).to include('http://example.com')
    end

    it 'extracts HTTPS URLs' do
      text = 'Secure site at https://secure.example.com'
      result = extractor.extract(text)
      
      expect(result).to include('https://secure.example.com')
    end

    it 'extracts URLs with query parameters' do
      text = 'Search at https://google.com?q=ruby&lang=en'
      result = extractor.extract(text)
      
      expect(result).to include('https://google.com?q=ruby&lang=en')
    end

    it 'extracts URLs with fragments' do
      text = 'Go to https://example.com/page#section1'
      result = extractor.extract(text)
      
      expect(result).to include('https://example.com/page#section1')
    end

    it 'extracts multiple URLs from text' do
      text = 'Visit http://site1.com and https://site2.org'
      result = extractor.extract(text)
      
      expect(result).to include('http://site1.com')
      expect(result).to include('https://site2.org')
      expect(result.length).to eq(2)
    end

    it 'returns empty array for text without URLs' do
      text = 'This is just plain text without any URLs'
      result = extractor.extract(text)
      
      expect(result).to be_empty
    end

    it 'handles nil input' do
      result = extractor.extract(nil)
      expect(result).to be_empty
    end

    it 'handles empty string' do
      result = extractor.extract('')
      expect(result).to be_empty
    end
  end

  describe 'URL validation' do
    it 'extracts valid URLs only' do
      text = 'Valid: https://example.com Invalid: not-a-url'
      result = extractor.extract(text)
      
      expect(result).to include('https://example.com')
      expect(result).not_to include('not-a-url')
    end

    it 'handles URLs with special characters' do
      text = 'Check https://example.com/path-with-dashes_and_underscores'
      result = extractor.extract(text)
      
      expect(result).to include('https://example.com/path-with-dashes_and_underscores')
    end

    it 'handles URLs with ports' do
      text = 'Local server at http://localhost:3000'
      result = extractor.extract(text)
      
      expect(result).to include('http://localhost:3000')
    end

    it 'handles URLs with subdomains' do
      text = 'API at https://api.example.com/v1'
      result = extractor.extract(text)
      
      expect(result).to include('https://api.example.com/v1')
    end
  end

  describe 'edge cases' do
    it 'handles URLs at the beginning of text' do
      text = 'https://example.com is a great site'
      result = extractor.extract(text)
      
      expect(result).to include('https://example.com')
    end

    it 'handles URLs at the end of text' do
      text = 'Great site at https://example.com'
      result = extractor.extract(text)
      
      expect(result).to include('https://example.com')
    end

    it 'handles URLs with trailing punctuation' do
      text = 'Visit https://example.com!'
      result = extractor.extract(text)
      
      expect(result).to include('https://example.com')
    end

    it 'handles URLs in parentheses' do
      text = 'Check out (https://example.com) for more info'
      result = extractor.extract(text)
      
      expect(result).to include('https://example.com')
    end

    it 'handles URLs in quotes' do
      text = 'Visit "https://example.com" today'
      result = extractor.extract(text)
      
      expect(result).to include('https://example.com')
    end
  end

  describe 'performance' do
    it 'handles large text efficiently' do
      text = 'a' * 10000 + ' https://example.com ' + 'b' * 10000
      
      start_time = Time.current
      result = extractor.extract(text)
      end_time = Time.current
      
      expect(result).to include('https://example.com')
      expect(end_time - start_time).to be < 0.1 # Should complete quickly
    end

    it 'handles multiple extractions efficiently' do
      text = 'https://example.com ' * 100
      
      start_time = Time.current
      10.times { extractor.extract(text) }
      end_time = Time.current
      
      expect(end_time - start_time).to be < 1.0 # Should complete within 1 second
    end
  end

  describe 'error handling' do
    it 'handles malformed input gracefully' do
      expect { extractor.extract('') }.not_to raise_error
      expect { extractor.extract(nil) }.not_to raise_error
      expect { extractor.extract('a' * 100000) }.not_to raise_error
    end

    it 'handles regex special characters' do
      text = 'Check https://example.com/path?param=value[1]&other=test'
      result = extractor.extract(text)
      
      expect(result).to include('https://example.com/path?param=value[1]&other=test')
    end
  end
end 