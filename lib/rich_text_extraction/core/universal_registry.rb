# frozen_string_literal: true

# Universal Registry using Sacred Geometry Principles
# Implements Golden Ratio proportions and Vortex-based information flow
module RichTextExtraction
  module Core
    class UniversalRegistry
      include Singleton
      attr_reader :components

      def initialize
        @components = Hash.new { |h, k| h[k] = {} }
      end

      def register(category, name, object)
        @components[category][name] = object
      end

      def get(category, name)
        @components[category][name]
      end

      def all(category)
        @components[category].values
      end

      # Golden Ratio constant for perfect proportions
      GOLDEN_RATIO = 1.618033988749895

      # Fibonacci sequence for natural growth
      FIBONACCI_SEQUENCE = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144].freeze

      class << self
        # Universal registration with golden ratio validation
        def register(type, symbol, config)
          registry[type] ||= {}
          registry[type][symbol] = config.merge(
            golden_ratio: calculate_golden_ratio(config),
            fibonacci_index: fibonacci_index(config),
            vortex_energy: calculate_vortex_energy(config)
          )
        end

        # Get registered item with vortex energy calculation
        def get(type, symbol)
          item = registry.dig(type, symbol)
          return nil unless item

          # Apply vortex mathematics for optimal retrieval
          apply_vortex_optimization(item)
        end

        # List all items of a type with golden ratio sorting
        def list(type)
          items = registry[type] || {}
          items.sort_by { |_, config| config[:golden_ratio] }
        end

        # Universal validation using sacred geometry
        def validate_all(input, type = :validator)
          results = {}
          list(type).each do |symbol, config|
            results[symbol] = validate_with_vortex(input, config)
          end
          results
        end

        private

        def registry
          @registry ||= {}
        end

        # Calculate golden ratio for perfect proportions
        def calculate_golden_ratio(config)
          complexity = config[:complexity] || 1
          efficiency = config[:efficiency] || 1
          complexity / efficiency.to_f
        end

        # Find Fibonacci index for natural growth
        def fibonacci_index(config)
          complexity = config[:complexity] || 1
          FIBONACCI_SEQUENCE.index(complexity) || 0
        end

        # Calculate vortex energy for information flow
        def calculate_vortex_energy(config)
          base_energy = config[:base_energy] || 1
          golden_ratio = calculate_golden_ratio(config)
          base_energy * golden_ratio
        end

        # Apply vortex optimization for retrieval
        def apply_vortex_optimization(item)
          # Enhance item with vortex mathematics
          item.merge(
            optimized_at: Time.now,
            vortex_flow: calculate_vortex_flow(item)
          )
        end

        # Calculate vortex flow for information processing
        def calculate_vortex_flow(item)
          energy = item[:vortex_energy]
          ratio = item[:golden_ratio]
          energy * ratio / GOLDEN_RATIO
        end

        # Universal validation with vortex mathematics
        def validate_with_vortex(input, config)
          flow = calculate_vortex_flow(config)
          result = config[:validator].call(input)

          {
            valid: result,
            confidence: flow,
            golden_ratio: config[:golden_ratio],
            vortex_energy: config[:vortex_energy]
          }
        end
      end
    end
  end
end
