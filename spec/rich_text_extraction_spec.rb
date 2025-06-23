# frozen_string_literal: true

require 'spec_helper'
require 'rich_text_extraction'
require 'active_support'
require 'active_support/cache'
require_relative '../lib/rich_text_extraction/helpers'
require_relative '../lib/rich_text_extraction/extracts_rich_text'

# Dummy classes for test stubs
class DummyJob
  def self.perform(url)
    RichTextExtraction::Extractor.new(url).link_objects(with_opengraph: true)
  end
end

class ActionTextJob
  def self.perform(body)
    body.link_objects(with_opengraph: true)
  end
end

RSpec.describe RichTextExtraction do
  it 'has a version number' do
    expect(RichTextExtraction::VERSION).not_to be nil
  end
end

RSpec.describe RichTextExtraction::Extractor do
  it 'extracts links from text' do
    text = 'Visit https://example.com and http://test.com.'
    extractor = described_class.new(text)
    expect(extractor.links).to contain_exactly('https://example.com', 'http://test.com')
  end

  it 'extracts tags and mentions' do
    text = 'Hello @alice #welcome'
    extractor = described_class.new(text)
    expect(extractor.mentions).to eq(['alice'])
    expect(extractor.tags).to eq(['welcome'])
  end

  it 'renders markdown to HTML' do
    html = RichTextExtraction.render_markdown('**Bold** [link](https://example.com)')
    expect(html).to include('<strong>Bold</strong>')
    expect(html).to include('<a href="https://example.com"')
  end
end

RSpec.describe 'Rails integration: cache clearing' do
  before do
    stub_const('Rails', Class.new)
    Rails.singleton_class.class_eval do
      attr_accessor :cache, :application
    end
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.application = double('App', class: double(module_parent_name: 'TestApp'))
  end
  it 'clears cache for links in the body via the concern' do
    dummy = Class.new do
      include RichTextExtraction::ExtractsRichText
      def body
        @body ||= RichTextExtraction::Extractor.new('https://example.com')
      end
    end.new
    dummy.body.link_objects(with_opengraph: true, cache: :rails)
    expect(Rails.cache.exist?('opengraph:TestApp:https://example.com')).to be true
    dummy.clear_rich_text_link_cache
    expect(Rails.cache.exist?('opengraph:TestApp:https://example.com')).to be false
  end
end

RSpec.describe 'Rails integration: view helper' do
  it 'renders opengraph preview in the view helper' do
    helper = Class.new { include RichTextExtraction::Helpers }.new
    html = helper.opengraph_preview_for({ 'title' => 'Test', 'url' => 'https://test.com' })
    expect(html).to include('Test')
    expect(html).to include('https://test.com')
  end
end

RSpec.describe 'Advanced usage: cache options' do
  it 'uses custom cache options and key prefix' do
    cache = {}
    extractor = RichTextExtraction::Extractor.new('https://example.com')
    allow(HTTParty).to receive(:get).and_return(double(success?: true,
                                                       body: '<meta property="og:title" content="Title">'))
    extractor.link_objects(with_opengraph: true, cache: cache, cache_options: { key_prefix: 'custom' })
    expect(cache['https://example.com']).to be_a(Hash)
  end
end

RSpec.describe 'Advanced usage: view helper formats' do
  it 'renders view helper with markdown and text formats' do
    helper = Class.new { include RichTextExtraction::Helpers }.new
    og = { 'title' => 'Test', 'url' => 'https://test.com' }
    expect(helper.opengraph_preview_for(og, format: :markdown)).to include('**Test**')
    expect(helper.opengraph_preview_for(og, format: :text)).to include('Test')
  end
end

RSpec.describe 'Advanced usage: Extractor direct' do
  it 'uses the Extractor directly outside Rails' do
    extractor = RichTextExtraction::Extractor.new('https://example.com')
    allow(HTTParty).to receive(:get).and_return(double(success?: true,
                                                       body: '<meta property="og:title" content="Title">'))
    result = extractor.link_objects(with_opengraph: true)
    expect(result.first[:url]).to eq('https://example.com')
    expect(result.first[:opengraph]['title']).to eq('Title')
  end
end

RSpec.describe 'Advanced usage: error handling' do
  it 'handles errors in OpenGraph extraction' do
    extractor = RichTextExtraction::Extractor.new('https://badurl.com')
    allow(HTTParty).to receive(:get).and_raise(StandardError.new('fail'))
    result = extractor.link_objects(with_opengraph: true)
    expect(result.first[:opengraph][:error]).to eq('fail')
  end
end

RSpec.describe 'Advanced usage: background job' do
  it 'can be used in a background job (stub)' do
    allow(HTTParty).to receive(:get).and_return(double(success?: true,
                                                       body: '<meta property="og:title" content="Title">'))
    result = DummyJob.perform('https://example.com')
    expect(result.first[:opengraph]['title']).to eq('Title')
  end
end

RSpec.describe 'ActionText and background jobs' do
  it 'fetches OpenGraph data for ActionText::RichText' do
    body = RichTextExtraction::Extractor.new('https://example.com')
    allow(HTTParty).to receive(:get).and_return(double(success?: true,
                                                       body: '<meta property="og:title" content="Title">'))
    expect(body.link_objects(with_opengraph: true).first[:opengraph]['title']).to eq('Title')
  end
  it 'can be used in a background job for ActionText' do
    body = RichTextExtraction::Extractor.new('https://example.com')
    allow(HTTParty).to receive(:get).and_return(double(success?: true,
                                                       body: '<meta property="og:title" content="Title">'))
    result = ActionTextJob.perform(body)
    expect(result.first[:opengraph]['title']).to eq('Title')
  end
end
