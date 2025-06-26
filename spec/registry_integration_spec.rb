# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registry Integration', type: :integration do
  let(:registry) { RichTextExtraction::Registry.instance }

  before do
    # Clear registry before each test
    registry.instance_variable_set(:@components, [])
    registry.instance_variable_set(:@component_index, {})
  end

  describe 'Registry with RegistryComponent integration' do
    describe 'component registration' do
      it 'registers components through RegistryComponent' do
        component = RichTextExtraction::RegistryComponent.new(
          name: 'TestExtractor',
          type: 'extractor',
          class_name: 'TestExtractorClass',
          description: 'Test component'
        )

        component.save!
        expect(registry.components).to include(component)
        expect(registry.component_exists?('TestExtractor', 'extractor')).to be true
      end

      it 'updates existing components' do
        component1 = RichTextExtraction::RegistryComponent.create!(
          name: 'TestExtractor',
          type: 'extractor',
          class_name: 'TestExtractorClass',
          description: 'Original description'
        )

        component2 = RichTextExtraction::RegistryComponent.new(
          name: 'TestExtractor',
          type: 'extractor',
          class_name: 'TestExtractorClass',
          description: 'Updated description'
        )

        component2.save!
        expect(registry.components.length).to eq(1)
        expect(registry.find_component('TestExtractor', 'extractor').description).to eq('Updated description')
      end

      it 'removes components on destroy' do
        component = RichTextExtraction::RegistryComponent.create!(
          name: 'TestExtractor',
          type: 'extractor',
          class_name: 'TestExtractorClass'
        )

        expect(registry.components).to include(component)
        component.destroy!
        expect(registry.components).not_to include(component)
        expect(registry.component_exists?('TestExtractor', 'extractor')).to be false
      end
    end

    describe 'Registry query methods' do
      before do
        RichTextExtraction::RegistryComponent.create!(
          name: 'LinkExtractor',
          type: 'extractor',
          class_name: 'LinkExtractorClass'
        )
        RichTextExtraction::RegistryComponent.create!(
          name: 'UrlValidator',
          type: 'validator',
          class_name: 'UrlValidatorClass'
        )
        RichTextExtraction::RegistryComponent.create!(
          name: 'MarkdownHelper',
          type: 'helper',
          class_name: 'MarkdownHelperClass'
        )
      end

      it 'finds components by name' do
        component = RichTextExtraction::Registry.find_by_name('LinkExtractor')
        expect(component.name).to eq('LinkExtractor')
        expect(component.type).to eq('extractor')
      end

      it 'finds components by type' do
        extractors = RichTextExtraction::Registry.find_by_type('extractor')
        expect(extractors.length).to eq(1)
        expect(extractors.first.name).to eq('LinkExtractor')
      end

      it 'queries with conditions' do
        active_components = RichTextExtraction::Registry.where(active: true)
        expect(active_components.length).to eq(3)

        extractors = RichTextExtraction::Registry.where(type: 'extractor')
        expect(extractors.length).to eq(1)
        expect(extractors.first.name).to eq('LinkExtractor')
      end

      it 'returns component collections as hashes' do
        extractors = RichTextExtraction::Registry.extractors
        expect(extractors).to be_a(Hash)
        expect(extractors['LinkExtractor']).to eq('LinkExtractorClass'.constantize)

        validators = RichTextExtraction::Registry.validators
        expect(validators).to be_a(Hash)
        expect(validators['UrlValidator']).to eq('UrlValidatorClass'.constantize)
      end
    end

    describe 'component lifecycle' do
      it 'manages component lifecycle through RegistryComponent' do
        # Create
        component = RichTextExtraction::RegistryComponent.create!(
          name: 'LifecycleTest',
          type: 'extractor',
          class_name: 'LifecycleTestClass'
        )
        expect(component).to be_persisted
        expect(component).not_to be_new_record

        # Update
        component.update!(description: 'Updated description')
        expect(component.description).to eq('Updated description')

        # Deactivate
        component.deactivate!
        expect(component).to be_inactive

        # Reactivate
        component.activate!
        expect(component).to be_active

        # Destroy
        component.destroy!
        expect(component).not_to be_persisted
      end
    end

    describe 'OpenGraph integration' do
      it 'provides OpenGraph data for registry components' do
        component = RichTextExtraction::RegistryComponent.create!(
          name: 'OpenGraphTest',
          type: 'extractor',
          class_name: 'OpenGraphTestClass',
          description: 'Test for OpenGraph',
          metadata: { version: '1.0', category: 'test' }
        )

        og_data = component.as_opengraph
        expect(og_data['og:title']).to eq('OpenGraphTest')
        expect(og_data['og:type']).to eq('extractor')
        expect(og_data['og:description']).to eq('Test for OpenGraph')
        expect(og_data['og:version']).to eq('1.0')
        expect(og_data['og:category']).to eq('test')
      end
    end

    describe 'hierarchy management' do
      it 'manages component hierarchies through registry' do
        parent = RichTextExtraction::RegistryComponent.create!(
          name: 'ParentComponent',
          type: 'extractor',
          class_name: 'ParentClass'
        )

        child = RichTextExtraction::RegistryComponent.create!(
          name: 'ChildComponent',
          type: 'validator',
          class_name: 'ChildClass'
        )

        parent.add_child(child)
        expect(parent.children).to include(child)
        expect(child.parent).to eq(parent)

        # Save hierarchy to registry
        parent.save!
        child.save!

        # Verify hierarchy persists
        saved_parent = RichTextExtraction::Registry.find_by_name('ParentComponent')
        saved_child = RichTextExtraction::Registry.find_by_name('ChildComponent')
        expect(saved_parent.children).to include(saved_child)
        expect(saved_child.parent).to eq(saved_parent)
      end
    end

    describe 'batch operations' do
      it 'handles batch component creation' do
        components_data = [
          { name: 'Batch1', type: 'extractor', class_name: 'Batch1Class' },
          { name: 'Batch2', type: 'validator', class_name: 'Batch2Class' },
          { name: 'Batch3', type: 'helper', class_name: 'Batch3Class' }
        ]

        components = components_data.map do |data|
          RichTextExtraction::RegistryComponent.create!(data)
        end

        expect(registry.components.length).to eq(3)
        expect(registry.extractors['Batch1']).to eq('Batch1Class'.constantize)
        expect(registry.validators['Batch2']).to eq('Batch2Class'.constantize)
        expect(registry.helpers['Batch3']).to eq('Batch3Class'.constantize)
      end

      it 'handles batch updates' do
        # Create components
        components = [
          RichTextExtraction::RegistryComponent.create!(name: 'Update1', type: 'extractor', class_name: 'Class1'),
          RichTextExtraction::RegistryComponent.create!(name: 'Update2', type: 'validator', class_name: 'Class2')
        ]

        # Batch update
        components.each { |c| c.update!(active: false) }

        # Verify updates
        inactive_components = RichTextExtraction::RegistryComponent.inactive
        expect(inactive_components.length).to eq(2)
        expect(inactive_components.map(&:name)).to match_array(['Update1', 'Update2'])
      end
    end

    describe 'error handling' do
      it 'handles validation errors gracefully' do
        expect {
          RichTextExtraction::RegistryComponent.create!(
            name: '', # Invalid
            type: 'invalid_type', # Invalid
            class_name: '' # Invalid
          )
        }.to raise_error(ActiveModel::ValidationError)
      end

      it 'handles duplicate registration' do
        RichTextExtraction::RegistryComponent.create!(
          name: 'Duplicate',
          type: 'extractor',
          class_name: 'Class1'
        )

        # Second component with same name and type should update the first
        component2 = RichTextExtraction::RegistryComponent.create!(
          name: 'Duplicate',
          type: 'extractor',
          class_name: 'Class2'
        )

        expect(registry.components.length).to eq(1)
        expect(registry.find_component('Duplicate', 'extractor').class_name).to eq('Class2')
      end
    end

    describe 'performance considerations' do
      it 'handles large numbers of components efficiently' do
        # Create many components
        100.times do |i|
          RichTextExtraction::RegistryComponent.create!(
            name: "Component#{i}",
            type: 'extractor',
            class_name: "Class#{i}"
          )
        end

        expect(registry.components.length).to eq(100)
        expect(registry.count).to eq(100)

        # Test query performance
        extractors = RichTextExtraction::Registry.extractors
        expect(extractors.length).to eq(100)
      end

      it 'handles deep hierarchies efficiently' do
        # Create deep hierarchy
        current = nil
        10.times do |i|
          component = RichTextExtraction::RegistryComponent.create!(
            name: "Level#{i}",
            type: 'extractor',
            class_name: "Class#{i}"
          )
          current.add_child(component) if current
          current = component
        end

        # Test hierarchy navigation
        root = RichTextExtraction::Registry.find_by_name('Level0')
        leaf = RichTextExtraction::Registry.find_by_name('Level9')
        
        expect(root.children.length).to eq(1)
        expect(leaf.parent.name).to eq('Level8')
      end
    end

    describe 'real-world scenarios' do
      it 'simulates a complete extraction pipeline' do
        # Create extraction pipeline components
        text_extractor = RichTextExtraction::RegistryComponent.create!(
          name: 'TextExtractor',
          type: 'extractor',
          class_name: 'TextExtractorClass',
          description: 'Extracts text from documents',
          metadata: { version: '1.0', category: 'text_processing' }
        )

        link_extractor = RichTextExtraction::RegistryComponent.create!(
          name: 'LinkExtractor',
          type: 'extractor',
          class_name: 'LinkExtractorClass',
          description: 'Extracts links from text',
          metadata: { version: '1.0', category: 'link_processing', depends_on: 'TextExtractor' }
        )

        url_validator = RichTextExtraction::RegistryComponent.create!(
          name: 'UrlValidator',
          type: 'validator',
          class_name: 'UrlValidatorClass',
          description: 'Validates extracted URLs',
          metadata: { version: '1.0', category: 'validation', depends_on: 'LinkExtractor' }
        )

        # Build pipeline hierarchy
        text_extractor.add_child(link_extractor)
        link_extractor.add_child(url_validator)

        # Test pipeline
        expect(text_extractor.children).to include(link_extractor)
        expect(link_extractor.children).to include(url_validator)
        expect(url_validator.parent.parent).to eq(text_extractor)

        # Test OpenGraph representation
        pipeline_og = text_extractor.as_opengraph
        expect(pipeline_og['og:title']).to eq('TextExtractor')
        expect(pipeline_og['og:version']).to eq('1.0')
        expect(pipeline_og['og:category']).to eq('text_processing')

        # Test registry queries
        extractors = RichTextExtraction::Registry.extractors
        expect(extractors['TextExtractor']).to eq('TextExtractorClass'.constantize)
        expect(extractors['LinkExtractor']).to eq('LinkExtractorClass'.constantize)

        validators = RichTextExtraction::Registry.validators
        expect(validators['UrlValidator']).to eq('UrlValidatorClass'.constantize)
      end

      it 'simulates component versioning' do
        # Create versioned components
        v1_component = RichTextExtraction::RegistryComponent.create!(
          name: 'VersionedComponent',
          type: 'extractor',
          class_name: 'VersionedComponentV1',
          description: 'Version 1.0',
          metadata: { version: '1.0', deprecated: false }
        )

        # Update to version 2.0
        v1_component.update!(
          class_name: 'VersionedComponentV2',
          description: 'Version 2.0',
          metadata: { version: '2.0', deprecated: false, migration_guide: 'v1_to_v2.md' }
        )

        # Mark v1 as deprecated
        v1_component.update!(metadata: { version: '2.0', deprecated: true })

        # Test versioning
        component = RichTextExtraction::Registry.find_by_name('VersionedComponent')
        expect(component.class_name).to eq('VersionedComponentV2')
        expect(component.metadata['version']).to eq('2.0')
        expect(component.metadata['deprecated']).to be true

        # Test OpenGraph with versioning
        og_data = component.as_opengraph
        expect(og_data['og:version']).to eq('2.0')
        expect(og_data['og:deprecated']).to be true
        expect(og_data['og:migration_guide']).to eq('v1_to_v2.md')
      end
    end
  end
end 