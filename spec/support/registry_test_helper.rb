# frozen_string_literal: true

module RegistryTestHelper
  extend RSpec::SharedContext

  # Shared setup for registry tests
  shared_context 'registry setup' do
    let(:registry) { RichTextExtraction::Registry.instance }

    before do
      # Clear registry and cache before each test
      registry.instance_variable_set(:@components, [])
      registry.instance_variable_set(:@component_index, {})
      registry.cache_clear
      registry.reset_stats
    end
  end

  # Helper method for testing batch operations with proper operation tracking
  def test_batch_operations_with_tracking(success_names, failure_names)
    # Store original method
    original_register = registry.method(:register_component)
    
    # Mock with proper operation tracking
    allow(registry).to receive(:register_component) do |component|
      if success_names.any? { |name| component.name.include?(name) }
        # Call original method for success cases
        original_register.call(component)
      else
        # Raise error for failure cases
        raise StandardError, 'Batch error'
      end
    end

    # Execute operations
    success_names.each do |name|
      component = RichTextExtraction::RegistryComponent.new(
        name: name,
        type: 'extractor',
        class_name: "#{name}Class"
      )
      component.save!
    end

    failure_names.each do |name|
      component = RichTextExtraction::RegistryComponent.new(
        name: name,
        type: 'extractor',
        class_name: "#{name}Class"
      )
      expect { component.save! }.to raise_error(StandardError)
    end

    # Return stats for verification
    registry.performance_stats
  end

  # Helper method for testing exponential backoff
  def test_exponential_backoff
    attempt_times = []
    
    allow(registry).to receive(:register_component) do
      attempt_times << Time.current
      raise StandardError, 'Test error'
    end

    component = RichTextExtraction::RegistryComponent.new(
      name: 'ExponentialTest',
      type: 'extractor',
      class_name: 'ExponentialTestClass'
    )

    expect { component.save! }.to raise_error(StandardError)

    # Return attempt times for verification
    attempt_times
  end

  # Helper method for testing cache operations
  def test_cache_operations
    # Test basic cache operations
    registry.cache_set('test_key', 'test_value')
    expect(registry.cache_get('test_key')).to eq('test_value')
    
    # Test cache expiration
    registry.cache_set('expire_test', 'value', 0.001)
    expect(registry.cache_get('expire_test')).to eq('value')
    sleep(0.002)
    expect(registry.cache_get('expire_test')).to be_nil
    
    # Test cache clearing
    registry.cache_set('key1', 'value1')
    registry.cache_set('key2', 'value2')
    registry.cache_clear
    expect(registry.cache_get('key1')).to be_nil
    expect(registry.cache_get('key2')).to be_nil
  end

  # Helper method for testing performance
  def test_performance_with_components(count)
    components = []
    
    count.times do |i|
      component = RichTextExtraction::RegistryComponent.create!(
        name: "PerfTest#{i}",
        type: 'extractor',
        class_name: "PerfTestClass#{i}"
      )
      components << component
    end

    stats = registry.performance_stats
    expect(stats[:component_count]).to eq(count)
    expect(stats[:total_operations]).to eq(count)
    expect(stats[:error_ratio]).to eq(0.0)

    # Clean up
    components.each(&:destroy!)
  end

  # Helper method for testing error handling
  def test_error_handling_with_retries
    call_count = 0
    
    allow(registry).to receive(:register_component) do
      call_count += 1
      if call_count < 3
        raise StandardError, "Temporary error #{call_count}"
      else
        true
      end
    end

    component = RichTextExtraction::RegistryComponent.new(
      name: 'RetryTest',
      type: 'extractor',
      class_name: 'RetryTestClass'
    )

    start_time = Time.current
    component.save!
    end_time = Time.current

    {
      call_count: call_count,
      elapsed_time: end_time - start_time
    }
  end
end

RSpec.configure do |config|
  config.include RegistryTestHelper
end 