# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RichTextExtraction::RegistryComponent, type: :model do
  let(:valid_attributes) do
    {
      name: 'TestExtractor',
      type: 'extractor',
      class_name: 'TestExtractorClass',
      description: 'A test extractor component'
    }
  end

  let(:component) { described_class.new(valid_attributes) }

  describe 'initialization' do
    it 'creates a component with valid attributes' do
      expect(component.name).to eq('TestExtractor')
      expect(component.type).to eq('extractor')
      expect(component.class_name).to eq('TestExtractorClass')
      expect(component.description).to eq('A test extractor component')
    end

    it 'sets default values' do
      expect(component.active).to be true
      expect(component.metadata).to eq({})
      expect(component.children).to eq([])
      expect(component.parent).to be_nil
    end

    it 'sets timestamps' do
      expect(component.created_at).to be_a(Time)
      expect(component.updated_at).to be_a(Time)
    end

    it 'handles custom timestamps' do
      custom_time = Time.new(2024, 1, 1, 12, 0, 0)
      component = described_class.new(valid_attributes.merge(
        created_at: custom_time,
        updated_at: custom_time
      ))
      expect(component.created_at).to eq(custom_time)
      expect(component.updated_at).to eq(custom_time)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(component).to be_valid
    end

    it 'requires name' do
      component.name = nil
      expect(component).not_to be_valid
      expect(component.errors[:name]).to include("can't be blank")
    end

    it 'requires type' do
      component.type = nil
      expect(component).not_to be_valid
      expect(component.errors[:type]).to include("can't be blank")
    end

    it 'requires class_name' do
      component.class_name = nil
      expect(component).not_to be_valid
      expect(component.errors[:class_name]).to include("can't be blank")
    end

    it 'validates type inclusion' do
      component.type = 'invalid_type'
      expect(component).not_to be_valid
      expect(component.errors[:type]).to include('must be one of: extractor, validator, helper, service, job, controller')
    end

    it 'accepts all valid types' do
      %w[extractor validator helper service job controller].each do |type|
        component.type = type
        expect(component).to be_valid
      end
    end
  end

  describe 'ActiveRecord-style methods' do
    before do
      allow(RichTextExtraction::Registry.instance).to receive(:register_component)
      allow(RichTextExtraction::Registry.instance).to receive(:unregister_component)
      allow(RichTextExtraction::Registry.instance).to receive(:component_exists?).and_return(false)
    end

    describe '#save!' do
      it 'saves valid component to registry' do
        expect(RichTextExtraction::Registry.instance).to receive(:register_component).with(component)
        allow(RichTextExtraction::Registry.instance).to receive(:component_exists?).and_return(true)
        component.save!
        expect(component).to be_persisted
      end

      it 'raises error for invalid component' do
        component.name = nil
        expect { component.save! }.to raise_error(ActiveModel::ValidationError)
      end
    end

    describe '#save' do
      it 'returns true for valid save' do
        expect(component.save).to be true
      end

      it 'returns false for invalid save' do
        component.name = nil
        expect(component.save).to be false
      end
    end

    describe '#update!' do
      it 'updates attributes and calls registry update' do
        expect(RichTextExtraction::Registry.instance).to receive(:update_component).with(component)
        component.update!(description: 'Updated description')
        expect(component.description).to eq('Updated description')
      end

      it 'updates timestamp' do
        original_time = component.updated_at
        sleep(0.001) # Ensure time difference
        component.update!(description: 'Updated')
        expect(component.updated_at).to be > original_time
      end
    end

    describe '#update' do
      it 'returns true for successful update' do
        expect(component.update(description: 'Updated')).to be true
      end

      it 'returns true even for failed validation since we bypass save!' do
        component.name = nil
        expect(component.update(description: 'Updated')).to be true
      end
    end

    describe '#destroy!' do
      it 'removes component from registry' do
        expect(RichTextExtraction::Registry.instance).to receive(:unregister_component).with(component)
        component.destroy!
      end
    end

    describe '#destroy' do
      it 'returns true for successful destroy' do
        expect(component.destroy).to be true
      end

      it 'returns false for failed destroy' do
        allow(RichTextExtraction::Registry.instance).to receive(:unregister_component).and_raise(StandardError)
        expect(component.destroy).to be false
      end
    end

    describe '#persisted?' do
      it 'returns false for new record' do
        expect(component).not_to be_persisted
      end

      it 'returns true for saved record' do
        allow(RichTextExtraction::Registry.instance).to receive(:component_exists?).and_return(true)
        expect(component).to be_persisted
      end
    end

    describe '#new_record?' do
      it 'returns true for new record' do
        expect(component).to be_new_record
      end

      it 'returns false for saved record' do
        allow(RichTextExtraction::Registry.instance).to receive(:component_exists?).and_return(true)
        expect(component).not_to be_new_record
      end
    end
  end

  describe 'status methods' do
    describe '#active?' do
      it 'returns true when active' do
        component.active = true
        expect(component).to be_active
      end

      it 'returns false when inactive' do
        component.active = false
        expect(component).not_to be_active
      end
    end

    describe '#inactive?' do
      it 'returns true when inactive' do
        component.active = false
        expect(component).to be_inactive
      end

      it 'returns false when active' do
        component.active = true
        expect(component).not_to be_inactive
      end
    end

    describe '#activate!' do
      it 'activates component and calls registry update' do
        component.active = false
        expect(RichTextExtraction::Registry.instance).to receive(:update_component).with(component)
        component.activate!
        expect(component).to be_active
      end
    end

    describe '#deactivate!' do
      it 'deactivates component and calls registry update' do
        component.active = true
        expect(RichTextExtraction::Registry.instance).to receive(:update_component).with(component)
        component.deactivate!
        expect(component).not_to be_active
      end
    end
  end

  describe 'associations' do
    let(:parent) { described_class.new(name: 'Parent', type: 'extractor', class_name: 'ParentClass') }
    let(:child) { described_class.new(name: 'Child', type: 'validator', class_name: 'ChildClass') }

    describe '#add_child' do
      it 'adds child to parent' do
        parent.add_child(child)
        expect(parent.children).to include(child)
        expect(child.parent).to eq(parent)
      end

      it 'maintains parent reference' do
        parent.add_child(child)
        expect(child.parent).to eq(parent)
      end
    end

    describe '#remove_child' do
      it 'removes child from parent' do
        parent.add_child(child)
        parent.remove_child(child)
        expect(parent.children).not_to include(child)
        expect(child.parent).to be_nil
      end
    end

    describe '#has_children?' do
      it 'returns true when has children' do
        parent.add_child(child)
        expect(parent).to have_children
      end

      it 'returns false when no children' do
        expect(parent).not_to have_children
      end
    end

    describe '#root?' do
      it 'returns true when no parent' do
        expect(component).to be_root
      end

      it 'returns false when has parent' do
        parent.add_child(component)
        expect(component).not_to be_root
      end
    end

    describe '#leaf?' do
      it 'returns true when no children' do
        expect(component).to be_leaf
      end

      it 'returns false when has children' do
        component.add_child(child)
        expect(component).not_to be_leaf
      end
    end
  end

  describe 'OpenGraph compatibility' do
    let(:component_with_metadata) do
      described_class.new(
        name: 'AdvancedExtractor',
        type: 'extractor',
        class_name: 'AdvancedExtractorClass',
        description: 'Advanced extraction component',
        metadata: {
          version: '2.0',
          category: 'advanced',
          priority: 1,
          tags: ['extraction', 'advanced']
        }
      )
    end

    describe '#as_opengraph' do
      it 'returns basic OpenGraph attributes' do
        og_data = component.as_opengraph
        expect(og_data['og:title']).to eq('TestExtractor')
        expect(og_data['og:type']).to eq('extractor')
        expect(og_data['og:description']).to eq('A test extractor component')
      end

      it 'includes timestamp attributes' do
        og_data = component.as_opengraph
        expect(og_data['og:created_time']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
        expect(og_data['og:updated_time']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
      end

      it 'includes metadata with og: prefix' do
        og_data = component_with_metadata.as_opengraph
        expect(og_data['og:version']).to eq('2.0')
        expect(og_data['og:category']).to eq('advanced')
        expect(og_data['og:priority']).to eq(1)
        expect(og_data['og:tags']).to eq(['extraction', 'advanced'])
      end

      it 'handles empty metadata' do
        og_data = component.as_opengraph
        expect(og_data.keys).not_to include('og:version', 'og:category')
      end

      it 'handles nil metadata' do
        component.metadata = nil
        og_data = component.as_opengraph
        expect(og_data.keys).not_to include('og:version', 'og:category')
      end
    end
  end

  describe 'class methods' do
    before do
      allow(described_class).to receive(:all).and_return([
        described_class.new(name: 'Extractor1', type: 'extractor', class_name: 'Class1'),
        described_class.new(name: 'Validator1', type: 'validator', class_name: 'Class2'),
        described_class.new(name: 'Extractor2', type: 'extractor', class_name: 'Class3', active: false)
      ])
    end

    describe '.active' do
      it 'returns only active components' do
        active_components = described_class.active
        expect(active_components.length).to eq(2)
        expect(active_components.map(&:name)).to match_array(['Extractor1', 'Validator1'])
      end
    end

    describe '.inactive' do
      it 'returns only inactive components' do
        inactive_components = described_class.inactive
        expect(inactive_components.length).to eq(1)
        expect(inactive_components.first.name).to eq('Extractor2')
      end
    end

    describe '.by_type' do
      it 'returns components of specific type' do
        extractors = described_class.by_type('extractor')
        expect(extractors.length).to eq(2)
        expect(extractors.map(&:name)).to match_array(['Extractor1', 'Extractor2'])
      end
    end

    describe '.find_by_name' do
      it 'finds component by name' do
        component = described_class.find_by_name('Extractor1')
        expect(component.name).to eq('Extractor1')
      end

      it 'returns nil for non-existent component' do
        component = described_class.find_by_name('NonExistent')
        expect(component).to be_nil
      end
    end

    describe '.find_by_type' do
      it 'finds components by type' do
        validators = described_class.find_by_type('validator')
        expect(validators.length).to eq(1)
        expect(validators.first.name).to eq('Validator1')
      end
    end

    describe '.types' do
      it 'returns all valid types' do
        expect(described_class.types).to eq(%w[extractor validator helper service job controller])
      end
    end
  end

  describe 'attributes' do
    describe '#attributes' do
      it 'returns all attributes as hash' do
        attrs = component.attributes
        expect(attrs[:name]).to eq('TestExtractor')
        expect(attrs[:type]).to eq('extractor')
        expect(attrs[:class_name]).to eq('TestExtractorClass')
        expect(attrs[:description]).to eq('A test extractor component')
        expect(attrs[:active]).to be true
        expect(attrs[:metadata]).to eq({})
        expect(attrs[:parent]).to be_nil
        expect(attrs[:children]).to eq([])
        expect(attrs[:created_at]).to be_a(Time)
        expect(attrs[:updated_at]).to be_a(Time)
      end
    end

    describe '#attributes=' do
      it 'sets multiple attributes' do
        component.attributes = {
          name: 'UpdatedName',
          description: 'Updated description',
          active: false
        }
        expect(component.name).to eq('UpdatedName')
        expect(component.description).to eq('Updated description')
        expect(component.active).to be false
      end
    end
  end

  describe 'callbacks' do
    describe 'before_validation' do
      it 'sets defaults before validation' do
        component = described_class.new(name: 'Test', type: 'extractor', class_name: 'Class')
        component.valid? # Triggers before_validation
        expect(component.active).to be true
        expect(component.metadata).to eq({})
        expect(component.children).to eq([])
      end
    end

    describe 'before_save' do
      it 'updates timestamp before save' do
        original_time = component.updated_at
        sleep(0.001) # Ensure time difference
        component.send(:update_timestamps)
        expect(component.updated_at).to be > original_time
      end
    end
  end

  describe 'error handling' do
    describe 'validation errors' do
      it 'collects multiple validation errors' do
        invalid_component = described_class.new(
          name: '', # Invalid
          type: 'invalid_type', # Invalid
          class_name: '' # Invalid
        )
        expect(invalid_component).not_to be_valid
        expect(invalid_component.errors.count).to eq(3)
        expect(invalid_component.errors[:name]).to include("can't be blank")
        expect(invalid_component.errors[:type]).to include('must be one of: extractor, validator, helper, service, job, controller')
        expect(invalid_component.errors[:class_name]).to include("can't be blank")
      end
    end

    describe 'save errors' do
      it 'raises validation error on save!' do
        component.name = nil
        expect { component.save! }.to raise_error(ActiveModel::ValidationError)
      end
    end
  end

  describe 'integration with Registry' do
    let(:registry) { RichTextExtraction::Registry.instance }

    before do
      allow(registry).to receive(:register_component)
      allow(registry).to receive(:unregister_component)
      allow(registry).to receive(:component_exists?).and_return(false)
    end

    it 'registers with registry on save' do
      expect(registry).to receive(:register_component).with(component)
      component.save!
    end

    it 'unregisters from registry on destroy' do
      expect(registry).to receive(:unregister_component).with(component)
      component.destroy!
    end

    it 'checks persistence with registry' do
      allow(registry).to receive(:component_exists?).with('TestExtractor', 'extractor').and_return(true)
      expect(component).to be_persisted
    end
  end

  describe 'complex scenarios' do
    describe 'component hierarchy' do
      let(:root) { described_class.new(name: 'Root', type: 'extractor', class_name: 'RootClass') }
      let(:child1) { described_class.new(name: 'Child1', type: 'validator', class_name: 'Child1Class') }
      let(:child2) { described_class.new(name: 'Child2', type: 'helper', class_name: 'Child2Class') }
      let(:grandchild) { described_class.new(name: 'Grandchild', type: 'service', class_name: 'GrandchildClass') }

      it 'builds complex hierarchy' do
        root.add_child(child1)
        root.add_child(child2)
        child1.add_child(grandchild)

        expect(root.children).to match_array([child1, child2])
        expect(child1.children).to eq([grandchild])
        expect(child2.children).to eq([])
        expect(grandchild.parent).to eq(child1)
        expect(child1.parent).to eq(root)
        expect(child2.parent).to eq(root)
        expect(root.parent).to be_nil
      end

      it 'maintains hierarchy integrity' do
        root.add_child(child1)
        child1.add_child(grandchild)

        # Remove child should update all relationships
        root.remove_child(child1)
        expect(root.children).to eq([])
        expect(child1.parent).to be_nil
        expect(grandchild.parent).to eq(child1) # Grandchild still belongs to child1
      end
    end

    describe 'OpenGraph with hierarchy' do
      let(:parent) { described_class.new(name: 'Parent', type: 'extractor', class_name: 'ParentClass') }
      let(:child) { described_class.new(name: 'Child', type: 'validator', class_name: 'ChildClass') }

      it 'includes hierarchy in OpenGraph metadata' do
        parent.add_child(child)
        parent.metadata = { has_children: true, child_count: 1 }
        child.metadata = { parent_name: 'Parent' }

        parent_og = parent.as_opengraph
        child_og = child.as_opengraph

        expect(parent_og['og:has_children']).to be true
        expect(parent_og['og:child_count']).to eq(1)
        expect(child_og['og:parent_name']).to eq('Parent')
      end
    end
  end
end 