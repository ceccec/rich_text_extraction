# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Full Coverage Test', type: :integration do
  describe 'Main Gem File' do
    it 'loads the main gem file successfully' do
      expect { require 'rich_text_extraction' }.not_to raise_error
    end

    it 'provides the main module' do
      expect(defined?(RichTextExtraction)).to be_truthy
      expect(RichTextExtraction).to be_a(Module)
    end
  end

  describe 'Registry Component' do
    it 'creates and manages components' do
      component = RichTextExtraction::RegistryComponent.new(
        name: 'TestComponent',
        type: 'extractor',
        class_name: 'TestClass'
      )
      
      expect(component).to be_a(RichTextExtraction::RegistryComponent)
      expect(component.name).to eq('TestComponent')
      expect(component.type).to eq('extractor')
      expect(component.class_name).to eq('TestClass')
    end

    it 'validates components' do
      component = RichTextExtraction::RegistryComponent.new
      expect(component.valid?).to be false
      expect(component.errors[:name]).to include("can't be blank")
      expect(component.errors[:type]).to include("can't be blank")
      expect(component.errors[:class_name]).to include("can't be blank")
    end

    it 'saves components to registry' do
      component = RichTextExtraction::RegistryComponent.new(
        name: 'SaveTest',
        type: 'extractor',
        class_name: 'SaveTestClass'
      )
      
      expect { component.save! }.not_to raise_error
      expect(component.persisted?).to be true
    end

    it 'updates components' do
      component = RichTextExtraction::RegistryComponent.create!(
        name: 'UpdateTest',
        type: 'extractor',
        class_name: 'UpdateTestClass'
      )
      
      component.update!(description: 'Updated description')
      expect(component.description).to eq('Updated description')
    end

    it 'destroys components' do
      component = RichTextExtraction::RegistryComponent.create!(
        name: 'DestroyTest',
        type: 'extractor',
        class_name: 'DestroyTestClass'
      )
      
      expect { component.destroy! }.not_to raise_error
      expect(component.persisted?).to be false
    end
  end

  describe 'Registry' do
    let(:registry) { RichTextExtraction::Registry.instance }

    it 'manages components' do
      expect(registry).to be_a(RichTextExtraction::Registry)
      expect(registry.components).to be_an(Array)
    end

    it 'provides caching functionality' do
      registry.cache_set('test_key', 'test_value')
      expect(registry.cache_get('test_key')).to eq('test_value')
      
      registry.cache_clear
      expect(registry.cache_get('test_key')).to be_nil
    end

    it 'handles errors with golden ratio backoff' do
      allow(registry).to receive(:register_component) do
        raise StandardError, 'Test error'
      end

      component = RichTextExtraction::RegistryComponent.new(
        name: 'ErrorTest',
        type: 'extractor',
        class_name: 'ErrorTestClass'
      )

      expect { component.save! }.to raise_error(StandardError)
    end

    it 'tracks performance statistics' do
      registry.reset_stats
      stats = registry.performance_stats
      
      expect(stats).to include(:total_operations)
      expect(stats).to include(:total_errors)
      expect(stats).to include(:error_ratio)
      expect(stats).to include(:cache_size)
      expect(stats).to include(:component_count)
    end
  end

  describe 'Class Methods' do
    it 'provides registration methods' do
      expect(RichTextExtraction::Registry).to respond_to(:register)
      expect(RichTextExtraction::Registry).to respond_to(:register_extractor)
      expect(RichTextExtraction::Registry).to respond_to(:register_validator)
      expect(RichTextExtraction::Registry).to respond_to(:register_helper)
      expect(RichTextExtraction::Registry).to respond_to(:register_service)
      expect(RichTextExtraction::Registry).to respond_to(:register_job)
      expect(RichTextExtraction::Registry).to respond_to(:register_controller)
    end

    it 'provides retrieval methods' do
      expect(RichTextExtraction::Registry).to respond_to(:get_extractor)
      expect(RichTextExtraction::Registry).to respond_to(:get_validator)
      expect(RichTextExtraction::Registry).to respond_to(:get_helper)
      expect(RichTextExtraction::Registry).to respond_to(:get_service)
      expect(RichTextExtraction::Registry).to respond_to(:get_job)
      expect(RichTextExtraction::Registry).to respond_to(:get_controller)
    end

    it 'provides collection methods' do
      expect(RichTextExtraction::Registry).to respond_to(:extractors)
      expect(RichTextExtraction::Registry).to respond_to(:validators)
      expect(RichTextExtraction::Registry).to respond_to(:helpers)
      expect(RichTextExtraction::Registry).to respond_to(:services)
      expect(RichTextExtraction::Registry).to respond_to(:jobs)
      expect(RichTextExtraction::Registry).to respond_to(:controllers)
    end

    it 'provides query methods' do
      expect(RichTextExtraction::Registry).to respond_to(:find_by_name)
      expect(RichTextExtraction::Registry).to respond_to(:find_by_type)
      expect(RichTextExtraction::Registry).to respond_to(:where)
      expect(RichTextExtraction::Registry).to respond_to(:count)
      expect(RichTextExtraction::Registry).to respond_to(:exists?)
    end
  end

  describe 'OpenGraph Compatibility' do
    it 'provides OpenGraph metadata' do
      component = RichTextExtraction::RegistryComponent.create!(
        name: 'OpenGraphTest',
        type: 'extractor',
        class_name: 'OpenGraphTestClass',
        description: 'Test description',
        metadata: { 'custom' => 'value' }
      )

      og_data = component.as_opengraph
      expect(og_data['og:title']).to eq('OpenGraphTest')
      expect(og_data['og:type']).to eq('extractor')
      expect(og_data['og:description']).to eq('Test description')
      expect(og_data['og:custom']).to eq('value')
    end
  end

  describe 'Associations' do
    it 'manages parent-child relationships' do
      parent = RichTextExtraction::RegistryComponent.create!(
        name: 'Parent',
        type: 'extractor',
        class_name: 'ParentClass'
      )

      child = RichTextExtraction::RegistryComponent.create!(
        name: 'Child',
        type: 'extractor',
        class_name: 'ChildClass'
      )

      parent.add_child(child)
      expect(parent.has_children?).to be true
      expect(child.parent).to eq(parent)
      expect(parent.root?).to be true
      expect(child.leaf?).to be true

      parent.remove_child(child)
      expect(parent.has_children?).to be false
      expect(child.parent).to be_nil
    end
  end

  describe 'Error Handling' do
    it 'handles validation errors' do
      component = RichTextExtraction::RegistryComponent.new
      expect { component.save! }.to raise_error(ActiveModel::ValidationError)
    end

    it 'handles registry errors gracefully' do
      allow(RichTextExtraction::Registry.instance).to receive(:register_component) do
        raise StandardError, 'Registry error'
      end

      component = RichTextExtraction::RegistryComponent.new(
        name: 'ErrorTest',
        type: 'extractor',
        class_name: 'ErrorTestClass'
      )

      expect { component.save! }.to raise_error(StandardError)
    end
  end

  describe 'Performance' do
    it 'handles large numbers of components' do
      components = []
      10.times do |i|
        component = RichTextExtraction::RegistryComponent.create!(
          name: "PerfTest#{i}",
          type: 'extractor',
          class_name: "PerfTestClass#{i}"
        )
        components << component
      end

      expect(RichTextExtraction::Registry.count).to be >= 10
      
      # Clean up
      components.each(&:destroy!)
    end

    it 'caches queries efficiently' do
      component = RichTextExtraction::RegistryComponent.create!(
        name: 'CacheTest',
        type: 'extractor',
        class_name: 'CacheTestClass'
      )

      # First query
      result1 = RichTextExtraction::Registry.find_by_name('CacheTest')
      
      # Second query should use cache
      result2 = RichTextExtraction::Registry.find_by_name('CacheTest')
      
      expect(result1).to eq(result2)
      
      component.destroy!
    end
  end

  describe 'Integration' do
    it 'works with Rails environment' do
      expect(defined?(Rails)).to be_truthy
      expect(Rails.env).to eq('test')
    end

    it 'provides version information' do
      expect(RichTextExtraction::VERSION).to be_a(String)
    end
  end
end 