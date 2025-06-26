# frozen_string_literal: true

# Sacred Geometry Validator Factory
# Uses Golden Ratio and Vortex Mathematics for perfect validator generation
module RichTextExtraction
  module Core
    class SacredValidatorFactory
      # Sacred geometry constants
      GOLDEN_RATIO = 1.618033988749895
      SILVER_RATIO = 2.414213562373095
      PLATINUM_RATIO = 3.303577269034296

      class << self
        # Create validator using sacred geometry principles
        def create_validator(_symbol, config)
          # Calculate sacred proportions
          proportions = calculate_sacred_proportions(config)

          # Generate validator class with golden ratio structure
          Class.new(ActiveModel::EachValidator) do
            define_method(:validate_each) do |record, attribute, value|
              # Apply vortex mathematics for validation
              result = apply_vortex_validation(value, config, proportions)
              return if result[:valid]

              record.errors.add(attribute, options[:message] || result[:message])
            end

            # Store sacred geometry data
            define_singleton_method(:sacred_proportions) { proportions }
            define_singleton_method(:vortex_config) { config }
          end
        end

        # Register validator with universal registry
        def register_validator(symbol, config)
          validator_class = create_validator(symbol, config)

          # Register with universal registry using golden ratio
          UniversalRegistry.register(:validator, symbol, {
                                       class: validator_class,
                                       validator: config[:validator],
                                       complexity: config[:complexity] || 1,
                                       efficiency: config[:efficiency] || 1,
                                       base_energy: config[:base_energy] || 1
                                     })

          validator_class
        end

        # Generate all validators from configuration
        def generate_all_validators
          RichTextExtraction::Core::Constants::VALIDATOR_EXAMPLES.each do |symbol, config|
            register_validator(symbol, build_validator_config(symbol, config))
          end
        end

        private

        # Calculate sacred proportions using golden ratio
        def calculate_sacred_proportions(config)
          complexity = config[:complexity] || 1
          efficiency = config[:efficiency] || 1

          {
            golden_ratio: complexity / efficiency.to_f,
            silver_ratio: (complexity + efficiency) / complexity.to_f,
            platinum_ratio: (complexity * efficiency) / (complexity + efficiency).to_f,
            fibonacci_index: fibonacci_index(complexity),
            vortex_energy: calculate_vortex_energy(complexity, efficiency)
          }
        end

        # Apply vortex validation with sacred geometry
        def apply_vortex_validation(value, config, proportions)
          # Calculate validation confidence using golden ratio
          confidence = proportions[:golden_ratio] / GOLDEN_RATIO

          # Apply the actual validation
          result = config[:validator].call(value)

          {
            valid: result,
            confidence: confidence,
            message: config[:error_message] || 'is not valid',
            proportions: proportions
          }
        end

        # Build validator configuration with sacred geometry
        def build_validator_config(symbol, config)
          {
            validator: ->(value) { RichTextExtraction::Extractors::Validators.send("valid_#{symbol}?", value) },
            error_message: config[:error_message] || "is not a valid #{symbol}",
            complexity: calculate_complexity(config),
            efficiency: calculate_efficiency(config),
            base_energy: calculate_base_energy(config)
          }
        end

        # Calculate complexity using sacred geometry
        def calculate_complexity(config)
          # Complexity based on regex length, validation steps, etc.
          regex_length = config[:regex]&.length || 0
          validation_steps = config[:validation_steps] || 1
          (regex_length + validation_steps) / 10.0
        end

        # Calculate efficiency using golden ratio
        def calculate_efficiency(config)
          # Efficiency based on validation speed and accuracy
          speed_factor = config[:speed_factor] || 1
          accuracy_factor = config[:accuracy_factor] || 1
          speed_factor * accuracy_factor
        end

        # Calculate base energy using vortex mathematics
        def calculate_base_energy(config)
          # Base energy for information processing
          complexity = calculate_complexity(config)
          efficiency = calculate_efficiency(config)
          complexity * efficiency / GOLDEN_RATIO
        end

        # Find Fibonacci index
        def fibonacci_index(value)
          fibonacci = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
          fibonacci.index(value.to_i) || 0
        end

        # Calculate vortex energy
        def calculate_vortex_energy(complexity, efficiency)
          base_energy = complexity * efficiency
          golden_ratio = complexity / efficiency.to_f
          base_energy * golden_ratio / GOLDEN_RATIO
        end
      end
    end
  end
end
