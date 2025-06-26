# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RichTextExtraction::InterfaceAdapter do
  let(:adapter) { described_class.new }

  describe 'initialization' do
    it 'creates a new interface adapter' do
      expect(adapter).to be_a(described_class)
    end
  end

  describe '#extract_links' do
    it 'extracts links from text' do
      text = 'Check out https://example.com and http://test.org'
      result = adapter.extract_links(text)
      
      expect(result).to include('https://example.com')
      expect(result).to include('http://test.org')
    end

    it 'returns empty array for text without links' do
      text = 'This is just plain text without any links'
      result = adapter.extract_links(text)
      
      expect(result).to be_empty
    end

    it 'handles nil input' do
      result = adapter.extract_links(nil)
      expect(result).to be_empty
    end
  end

  describe '#extract_mentions' do
    it 'extracts mentions from text' do
      text = 'Hello @user1 and @user2, how are you?'
      result = adapter.extract_mentions(text)
      
      expect(result).to include('@user1')
      expect(result).to include('@user2')
    end

    it 'returns empty array for text without mentions' do
      text = 'This is just plain text without any mentions'
      result = adapter.extract_mentions(text)
      
      expect(result).to be_empty
    end

    it 'handles nil input' do
      result = adapter.extract_mentions(nil)
      expect(result).to be_empty
    end
  end

  describe '#extract_hashtags' do
    it 'extracts hashtags from text' do
      text = 'Check out #ruby #rails and #testing'
      result = adapter.extract_hashtags(text)
      
      expect(result).to include('#ruby')
      expect(result).to include('#rails')
      expect(result).to include('#testing')
    end

    it 'returns empty array for text without hashtags' do
      text = 'This is just plain text without any hashtags'
      result = adapter.extract_hashtags(text)
      
      expect(result).to be_empty
    end

    it 'handles nil input' do
      result = adapter.extract_hashtags(nil)
      expect(result).to be_empty
    end
  end

  describe '#validate_url' do
    it 'validates valid URLs' do
      valid_urls = [
        'https://example.com',
        'http://test.org',
        'https://sub.domain.co.uk/path?param=value'
      ]
      
      valid_urls.each do |url|
        expect(adapter.validate_url(url)).to be true
      end
    end

    it 'rejects invalid URLs' do
      invalid_urls = [
        'not-a-url',
        'ftp://example.com',
        'javascript:alert(1)',
        ''
      ]
      
      invalid_urls.each do |url|
        expect(adapter.validate_url(url)).to be false
      end
    end

    it 'handles nil input' do
      expect(adapter.validate_url(nil)).to be false
    end
  end

  describe '#extract_all' do
    it 'extracts all types of content from text' do
      text = 'Check out https://example.com and @user1 with #ruby hashtag'
      result = adapter.extract_all(text)
      
      expect(result[:links]).to include('https://example.com')
      expect(result[:mentions]).to include('@user1')
      expect(result[:hashtags]).to include('#ruby')
    end

    it 'returns empty results for text without extractable content' do
      text = 'This is just plain text'
      result = adapter.extract_all(text)
      
      expect(result[:links]).to be_empty
      expect(result[:mentions]).to be_empty
      expect(result[:hashtags]).to be_empty
    end

    it 'handles nil input' do
      result = adapter.extract_all(nil)
      
      expect(result[:links]).to be_empty
      expect(result[:mentions]).to be_empty
      expect(result[:hashtags]).to be_empty
    end
  end

  describe 'error handling' do
    it 'handles malformed input gracefully' do
      expect { adapter.extract_links('') }.not_to raise_error
      expect { adapter.extract_mentions('') }.not_to raise_error
      expect { adapter.extract_hashtags('') }.not_to raise_error
      expect { adapter.validate_url('') }.not_to raise_error
      expect { adapter.extract_all('') }.not_to raise_error
    end

    it 'handles very long input' do
      long_text = 'a' * 10000 + ' https://example.com ' + 'b' * 10000
      result = adapter.extract_links(long_text)
      
      expect(result).to include('https://example.com')
    end
  end

  describe 'performance' do
    it 'handles multiple extractions efficiently' do
      text = 'https://example.com @user1 #ruby ' * 100
      
      start_time = Time.current
      100.times { adapter.extract_all(text) }
      end_time = Time.current
      
      elapsed_time = end_time - start_time
      expect(elapsed_time).to be < 1.0 # Should complete within 1 second
    end
  end
end 