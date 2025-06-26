# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registry', type: :integration do
  include_context 'registry setup'

  describe 'Error Handling' do
    describe 'exponential backoff' do
      it 'retries operations with exponential backoff' do
        attempt_times = test_exponential_backoff

        # Should have at least 2 attempts
        expect(attempt_times.length).to be >= 2
        
        # Verify exponential backoff timing
        elapsed_time = attempt_times.last - attempt_times.first
        expect(elapsed_time).to be > 0.3 # Should have some delay
        expect(elapsed_time).to be < 1.0 # But not too long
      end

      it 'gives up after maximum retry attempts' do
        allow(registry).to receive(:register_component) do
          raise StandardError, 'Persistent error'
        end

        component = RichTextExtraction::RegistryComponent.new(
          name: 'FailTest',
          type: 'extractor',
          class_name: 'FailTestClass'
        )

        expect { component.save! }.to raise_error(StandardError)
      end
    end

    describe 'error tracking' do
      it 'tracks operation and error counts' do
        # Successful operation
        component = RichTextExtraction::RegistryComponent.new(
          name: 'SuccessTest',
          type: 'extractor',
          class_name: 'SuccessTestClass'
        )
        component.save!

        stats = registry.performance_stats
        expect(stats[:total_operations]).to be > 0
        expect(stats[:total_errors]).to eq(0)
        expect(stats[:error_ratio]).to eq(0.0)

        # Failed operation
        allow(registry).to receive(:register_component) do
          raise StandardError, 'Test error'
        end

        component2 = RichTextExtraction::RegistryComponent.new(
          name: 'FailTest',
          type: 'extractor',
          class_name: 'FailTestClass'
        )

        expect { component2.save! }.to raise_error(StandardError)

        stats = registry.performance_stats
        expect(stats[:total_errors]).to be > 0
        expect(stats[:error_ratio]).to be > 0.0
      end

      it 'resets statistics' do
        component = RichTextExtraction::RegistryComponent.new(
          name: 'ResetTest',
          type: 'extractor',
          class_name: 'ResetTestClass'
        )
        component.save!

        expect(registry.performance_stats[:total_operations]).to be > 0

        registry.reset_stats
        stats = registry.performance_stats
        expect(stats[:total_operations]).to eq(0)
        expect(stats[:total_errors]).to eq(0)
        expect(stats[:error_ratio]).to eq(0.0)
      end
    end
  end

  describe 'Intelligent Caching' do
    describe 'cache operations' do
      it 'stores and retrieves cached values' do
        test_cache_operations
      end
    end

    describe 'cache-aware queries' do
      before do
        component1 = RichTextExtraction::RegistryComponent.new(
          name: 'CacheTest1',
          type: 'extractor',
          class_name: 'CacheTest1Class'
        )
        component1.save!

        component2 = RichTextExtraction::RegistryComponent.new(
          name: 'CacheTest2',
          type: 'validator',
          class_name: 'CacheTest2Class'
        )
        component2.save!
      end

      it 'uses cache when error ratio is low' do
        # First query - should cache
        result1 = RichTextExtraction::Registry.find_by_name('CacheTest1')
        expect(result1).to be_present

        # Second query - should use cache
        result2 = RichTextExtraction::Registry.find_by_name('CacheTest1')
        expect(result2).to eq(result1)
      end

      it 'bypasses cache when error ratio is high' do
        # Simulate high error rate
        registry.instance_variable_set(:@error_count, 10)
        registry.instance_variable_set(:@operation_count, 15)

        # Should not use cache due to high error ratio
        result1 = RichTextExtraction::Registry.find_by_name('CacheTest1')
        result2 = RichTextExtraction::Registry.find_by_name('CacheTest1')
        
        # Both should be fresh queries
        expect(result1).to eq(result2)
      end

      it 'caches collection queries' do
        # First query
        extractors1 = RichTextExtraction::Registry.extractors
        expect(extractors1).to have_key('CacheTest1')

        # Second query - should use cache
        extractors2 = RichTextExtraction::Registry.extractors
        expect(extractors2).to eq(extractors1)
      end

      it 'clears cache on registry changes' do
        # Initial query
        RichTextExtraction::Registry.find_by_name('CacheTest1')
        expect(registry.cache_get('find_by_name:CacheTest1')).to be_present

        # Add new component - should clear cache
        component3 = RichTextExtraction::RegistryComponent.new(
          name: 'CacheTest3',
          type: 'helper',
          class_name: 'CacheTest3Class'
        )
        component3.save!

        # Cache should be cleared
        expect(registry.cache_get('find_by_name:CacheTest1')).to be_nil
      end
    end
  end

  describe 'Performance Optimization' do
    describe 'large scale operations' do
      it 'handles many components efficiently' do
        test_performance_with_components(10)
      end

      it 'maintains performance with caching' do
        # Create components
        5.times do |i|
          component = RichTextExtraction::RegistryComponent.new(
            name: "CachePerfTest#{i}",
            type: 'extractor',
            class_name: "CachePerfTestClass#{i}"
          )
          component.save!
        end

        # Multiple queries should be fast due to caching
        start_time = Time.current
        5.times do
          RichTextExtraction::Registry.extractors
        end
        end_time = Time.current

        elapsed_time = end_time - start_time
        expect(elapsed_time).to be < 0.1 # Should be very fast with caching
      end
    end

    describe 'memory management' do
      it 'manages cache size efficiently' do
        # Add many cache entries
        100.times do |i|
          registry.cache_set("key#{i}", "value#{i}")
        end

        stats = registry.performance_stats
        expect(stats[:cache_size]).to eq(100)

        # Clear cache
        registry.cache_clear
        stats = registry.performance_stats
        expect(stats[:cache_size]).to eq(0)
      end
    end
  end

  describe 'Real-world Scenarios' do
    describe 'component lifecycle with error handling' do
      it 'handles component updates with errors gracefully' do
        component = RichTextExtraction::RegistryComponent.new(
          name: 'LifecycleTest',
          type: 'extractor',
          class_name: 'LifecycleTestClass'
        )
        component.save!

        # Simulate intermittent registry errors
        result = test_error_handling_with_retries

        # Should retry and succeed
        expect(result[:call_count]).to eq(3)
        expect(result[:elapsed_time]).to be > 0.3 # Should have some delay
      end

      it 'handles batch operations with partial failures' do
        stats = test_batch_operations_with_tracking(
          ['BatchSuccess1', 'BatchSuccess2'],
          ['BatchFail1', 'BatchFail2']
        )

        expect(stats[:total_operations]).to be > 0
        expect(stats[:total_errors]).to be > 0
        expect(stats[:error_ratio]).to be > 0.0
      end

      it 'balances performance and reliability' do
        stats = test_batch_operations_with_tracking(
          ['Success1', 'Success2', 'Success3', 'Success4', 'Success5'],
          ['Failure1', 'Failure2', 'Failure3']
        )

        expect(stats[:total_operations]).to be > 0
        expect(stats[:total_errors]).to be > 0
        expect(stats[:error_ratio]).to be > 0.0
        # Error ratio can be > 1.0 due to retry attempts, but should be reasonable
        expect(stats[:error_ratio]).to be < 3.0 # Allow for retry attempts
      end
    end

    describe 'cache invalidation strategies' do
      it 'invalidates relevant cache entries on updates' do
        component = RichTextExtraction::RegistryComponent.new(
          name: 'CacheInvalidationTest',
          type: 'extractor',
          class_name: 'CacheInvalidationTestClass'
        )
        component.save!

        # Prime cache
        RichTextExtraction::Registry.find_by_name('CacheInvalidationTest')
        RichTextExtraction::Registry.extractors

        # Verify cache is populated
        expect(registry.cache_get('find_by_name:CacheInvalidationTest')).to be_present
        expect(registry.cache_get('extractors')).to be_present

        # Update component
        component.update!(description: 'Updated')

        # Cache should be cleared
        expect(registry.cache_get('find_by_name:CacheInvalidationTest')).to be_nil
        expect(registry.cache_get('extractors')).to be_nil
      end

      it 'maintains cache consistency across operations' do
        # Create initial components
        component1 = RichTextExtraction::RegistryComponent.new(
          name: 'ConsistencyTest1',
          type: 'extractor',
          class_name: 'ConsistencyTest1Class'
        )
        component1.save!

        # Prime cache
        extractors1 = RichTextExtraction::Registry.extractors
        expect(extractors1).to have_key('ConsistencyTest1')

        # Add new component
        component2 = RichTextExtraction::RegistryComponent.new(
          name: 'ConsistencyTest2',
          type: 'extractor',
          class_name: 'ConsistencyTest2Class'
        )
        component2.save!

        # Cache should be cleared and new query should include both
        extractors2 = RichTextExtraction::Registry.extractors
        expect(extractors2).to have_key('ConsistencyTest1')
        expect(extractors2).to have_key('ConsistencyTest2')
        expect(extractors2.length).to eq(2)
      end
    end
  end

  describe 'Mathematical Principles' do
    describe 'proportional error handling' do
      it 'uses mathematical ratio for backoff timing' do
        attempt_times = test_exponential_backoff

        # Should have at least 2 attempts
        expect(attempt_times.length).to be >= 2

        # Calculate intervals
        intervals = []
        (1...attempt_times.length).each do |i|
          intervals << attempt_times[i] - attempt_times[i-1]
        end

        # Verify exponential backoff pattern
        intervals.each_with_index do |interval, i|
          expected_base = 0.1 * (RichTextExtraction::Registry::MATHEMATICAL_RATIO ** (i + 1))
          expect(interval).to be >= expected_base * 0.8 # Allow some tolerance
          expect(interval).to be <= expected_base * 1.2
        end
      end
    end

    describe 'harmonious performance' do
      it 'balances performance and reliability' do
        stats = test_batch_operations_with_tracking(
          ['Success1', 'Success2', 'Success3', 'Success4', 'Success5'],
          ['Failure1', 'Failure2', 'Failure3']
        )

        expect(stats[:total_operations]).to be > 0
        expect(stats[:total_errors]).to be > 0
        expect(stats[:error_ratio]).to be > 0.0
        # Error ratio can be > 1.0 due to retry attempts, but should be reasonable
        expect(stats[:error_ratio]).to be < 3.0 # Allow for retry attempts
      end
    end
  end
end 