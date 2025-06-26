# RichTextExtraction API Reference

## Core Components

### Universal Registry

The central registry using sacred geometry principles for optimal component management.

#### `UniversalRegistry.register(type, symbol, config)`
Registers a component with golden ratio validation and vortex energy calculation.

**Parameters:**
- `type` (Symbol): Component type (`:validator`, `:extractor`, `:transformer`)
- `symbol` (Symbol): Component identifier
- `config` (Hash): Configuration with sacred geometry metadata

**Returns:** Hash with sacred geometry calculations

**Example:**
```ruby
config = {
  validator: ->(value) { valid_email?(value) },
  complexity: 2.618,
  efficiency: 1.618,
  base_energy: 1.0
}

result = RichTextExtraction::Core::UniversalRegistry.register(:validator, :email, config)
# => {
#   golden_ratio: 1.618,
#   fibonacci_index: 3,
#   vortex_energy: 2.618,
#   optimized_at: 2024-01-01 12:00:00,
#   vortex_flow: 4.236
# }
```

#### `UniversalRegistry.get(type, symbol)`
Retrieves a component with vortex optimization applied.

**Parameters:**
- `type` (Symbol): Component type
- `symbol` (Symbol): Component identifier

**Returns:** Optimized component configuration

**Example:**
```ruby
validator = RichTextExtraction::Core::UniversalRegistry.get(:validator, :email)
# => {
#   class: EmailValidator,
#   validator: #<Proc>,
#   optimized_at: 2024-01-01 12:00:00,
#   vortex_flow: 4.236
# }
```

#### `UniversalRegistry.list(type)`
Lists all components of a type, sorted by golden ratio.

**Parameters:**
- `type` (Symbol): Component type

**Returns:** Array of component configurations

**Example:**
```ruby
validators = RichTextExtraction::Core::UniversalRegistry.list(:validator)
# => [
#   { symbol: :url, golden_ratio: 1.618, ... },
#   { symbol: :email, golden_ratio: 2.618, ... },
#   { symbol: :phone, golden_ratio: 4.236, ... }
# ]
```

#### `UniversalRegistry.validate_all(input, type = :validator)`
Validates input against all components of a type using vortex mathematics.

**Parameters:**
- `input` (String): Input to validate
- `type` (Symbol): Component type (default: `:validator`)

**Returns:** Hash of validation results with sacred geometry metadata

**Example:**
```ruby
results = RichTextExtraction::Core::UniversalRegistry.validate_all("test@example.com")
# => {
#   email: {
#     valid: true,
#     confidence: 1.618,
#     golden_ratio: 1.618,
#     vortex_energy: 2.618
#   },
#   url: {
#     valid: false,
#     confidence: 0.618,
#     golden_ratio: 1.618,
#     vortex_energy: 1.0
#   }
# }
```

### Sacred Validator Factory

Generates validators using sacred geometry principles and golden ratio proportions.

#### `SacredValidatorFactory.create_validator(symbol, config)`
Creates a validator class with sacred geometry metadata.

**Parameters:**
- `symbol` (Symbol): Validator identifier
- `config` (Hash): Validator configuration

**Returns:** Validator class with sacred geometry methods

**Example:**
```ruby
config = {
  validator: ->(value) { valid_email?(value) },
  error_message: "is not a valid email",
  complexity: 2.618,
  efficiency: 1.618
}

EmailValidator = RichTextExtraction::Core::SacredValidatorFactory.create_validator(:email, config)

# Access sacred geometry data
puts EmailValidator.sacred_proportions[:golden_ratio] # => 1.618
puts EmailValidator.vortex_config[:complexity] # => 2.618
```

#### `SacredValidatorFactory.register_validator(symbol, config)`
Registers a validator with the universal registry using golden ratio principles.

**Parameters:**
- `symbol` (Symbol): Validator identifier
- `config` (Hash): Validator configuration

**Returns:** Registered validator class

**Example:**
```ruby
config = {
  validator: ->(value) { valid_url?(value) },
  complexity: 1.618,
  efficiency: 1.0,
  base_energy: 1.0
}

UrlValidator = RichTextExtraction::Core::SacredValidatorFactory.register_validator(:url, config)
```

#### `SacredValidatorFactory.generate_all_validators`
Generates all validators from the constants configuration.

**Returns:** Hash of generated validators

**Example:**
```ruby
validators = RichTextExtraction::Core::SacredValidatorFactory.generate_all_validators
# => {
#   email: EmailValidator,
#   url: UrlValidator,
#   phone: PhoneValidator,
#   ...
# }
```

### Vortex Engine

Processes information through sacred geometry patterns and vortex mathematics.

#### `VortexEngine.process_text(text, flow_type = :extraction)`
Processes text through vortex information flow with golden ratio proportions.

**Parameters:**
- `text` (String): Text to process
- `flow_type` (Symbol): Flow type (`:extraction`, `:validation`, `:transformation`)

**Returns:** Processing result with sacred geometry metadata

**Example:**
```ruby
result = RichTextExtraction::Core::VortexEngine.process_text("Check out https://example.com")
# => {
#   validation: { stage: :validation, confidence: 1.618, ... },
#   extraction: { stage: :extraction, confidence: 2.618, ... },
#   transformation: { stage: :transformation, confidence: 4.236, ... },
#   sacred_geometry: { golden_ratio: 1.618, ... },
#   vortex_flow: { total_energy: 8.472, ... }
# }
```

#### `VortexEngine.extract_all(text)`
Extracts all patterns using vortex mathematics and golden ratio stages.

**Parameters:**
- `text` (String): Text to extract patterns from

**Returns:** Comprehensive extraction results with vortex metrics

**Example:**
```ruby
results = RichTextExtraction::Core::VortexEngine.extract_all("Email: test@example.com, URL: https://example.com")
# => {
#   validation: { stage: :validation, confidence: 1.618, ... },
#   extraction: { stage: :extraction, confidence: 2.618, ... },
#   transformation: { stage: :transformation, confidence: 4.236, ... },
#   vortex_metrics: { total_energy: 8.472, flow_efficiency: 0.95, ... },
#   sacred_proportions: { golden_proportion: 1.618, ... }
# }
```

#### `VortexEngine.validate_with_confidence(input, validator_type)`
Validates input using vortex confidence scoring and golden ratio principles.

**Parameters:**
- `input` (String): Input to validate
- `validator_type` (Symbol): Type of validator to use

**Returns:** Validation result with confidence metrics

**Example:**
```ruby
result = RichTextExtraction::Core::VortexEngine.validate_with_confidence("test@example.com", :email)
# => {
#   valid: true,
#   confidence: 1.618,
#   vortex_energy: 2.618,
#   sacred_ratio: 1.618
# }
```

## Testing Framework

### Sacred Testing Framework

Comprehensive testing framework using golden ratio principles and vortex mathematics.

#### `SacredTestingFramework.generate_test_suite(component_type, config = {})`
Generates comprehensive test suite using golden ratio distribution.

**Parameters:**
- `component_type` (Symbol): Type of component to test
- `config` (Hash): Test configuration

**Returns:** Test suite with sacred geometry metadata

**Example:**
```ruby
test_suite = RichTextExtraction::Testing::SacredTestingFramework.generate_test_suite(:validator, {
  total_tests: 100
})
# => {
#   unit_tests: [...],
#   integration_tests: [...],
#   performance_tests: [...],
#   edge_case_tests: [...],
#   sacred_geometry: { total_tests: 100, golden_ratio: 1.618, ... },
#   vortex_metrics: { total_energy: 161.8, average_confidence: 1.618, ... }
# }
```

#### `SacredTestingFramework.test_validators_with_vortex`
Tests all validators with vortex confidence scoring.

**Returns:** Comprehensive test results with sacred geometry metrics

**Example:**
```ruby
results = RichTextExtraction::Testing::SacredTestingFramework.test_validators_with_vortex
# => {
#   email: { overall_confidence: 1.618, vortex_energy: 2.618, ... },
#   url: { overall_confidence: 1.414, vortex_energy: 2.236, ... },
#   overall_metrics: { total_validators: 15, average_confidence: 1.5, ... },
#   sacred_balance: { golden_ratio_balance: 1.618, ... }
# }
```

#### `SacredTestingFramework.test_extraction_with_golden_ratio`
Tests extraction functionality using golden ratio efficiency metrics.

**Returns:** Extraction test results with golden ratio metrics

**Example:**
```ruby
results = RichTextExtraction::Testing::SacredTestingFramework.test_extraction_with_golden_ratio
# => {
#   simple_text: { efficiency: 1.618, golden_ratio_compliance: 1.0, ... },
#   complex_text: { efficiency: 2.618, golden_ratio_compliance: 0.95, ... },
#   golden_ratio_efficiency: 2.118,
#   vortex_flow_metrics: { total_flow: 42.36, average_flow: 0.95, ... }
# }
```

#### `SacredTestingFramework.validate_sacred_geometry`
Validates that all components follow sacred geometry principles.

**Returns:** Sacred geometry compliance report

**Example:**
```ruby
compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
# => {
#   golden_ratio: { average_compliance: 0.95, min_compliance: 0.85, ... },
#   fibonacci_sequence: { fibonacci_compliance: 0.9, fibonacci_sequence: [1,1,2,3,5,8,13,21,34,55,89,144], ... },
#   vortex_flow: { vortex_flow_efficiency: 0.92, flow_patterns: {...}, ... },
#   sacred_balance: { sacred_balance_score: 0.88, balance_metrics: {...}, ... },
#   overall_sacred_score: 0.91
# }
```

## Configuration

### Sacred Geometry Configuration

```ruby
RichTextExtraction.configure do |config|
  # Enable sacred geometry features
  config.sacred_geometry.enabled = true
  
  # Sacred geometry constants
  config.sacred_geometry.golden_ratio = 1.618033988749895
  config.sacred_geometry.silver_ratio = 2.414213562373095
  config.sacred_geometry.platinum_ratio = 3.303577269034296
  
  # Vortex mathematics settings
  config.sacred_geometry.vortex_constant = 2.665144142690225
  config.sacred_geometry.golden_angle = 137.5
  
  # Fibonacci growth settings
  config.sacred_geometry.fibonacci_growth = true
  config.sacred_geometry.fibonacci_sequence = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
end
```

### Vortex Engine Configuration

```ruby
RichTextExtraction::Core::VortexEngine.configure do |config|
  # Vortex flow settings
  config.golden_angle = 137.5
  config.vortex_constant = 2.665144142690225
  
  # Processing stages
  config.vortex_stages = [:validation, :extraction, :transformation]
  
  # Energy conservation
  config.energy_conservation = true
  
  # Flow optimization
  config.flow_optimization = true
end
```

## Error Handling

### Sacred Geometry Errors

```ruby
begin
  RichTextExtraction::Core::SacredValidatorFactory.create_validator(:invalid, config)
rescue RichTextExtraction::Core::SacredGeometryError => e
  puts "Sacred geometry error: #{e.message}"
  puts "Golden ratio deviation: #{e.golden_ratio_deviation}"
  puts "Vortex energy loss: #{e.vortex_energy_loss}"
end
```

### Vortex Flow Errors

```ruby
begin
  RichTextExtraction::Core::VortexEngine.process_text(text)
rescue RichTextExtraction::Core::VortexFlowError => e
  puts "Vortex flow error: #{e.message}"
  puts "Flow efficiency: #{e.flow_efficiency}"
  puts "Energy loss: #{e.energy_loss}"
end
```

## Performance Metrics

### Golden Ratio Performance

```ruby
# Check golden ratio performance
performance = RichTextExtraction::Core::VortexEngine.calculate_golden_ratio_performance
puts "Golden ratio efficiency: #{performance[:efficiency]}"
puts "Optimal ratio deviation: #{performance[:deviation]}"
```

### Vortex Flow Metrics

```ruby
# Check vortex flow metrics
metrics = RichTextExtraction::Core::VortexEngine.calculate_vortex_flow_metrics
puts "Total vortex energy: #{metrics[:total_energy]}"
puts "Flow efficiency: #{metrics[:flow_efficiency]}"
puts "Sacred balance: #{metrics[:sacred_balance]}"
```

## Migration Examples

### From Traditional Validators

```ruby
# Old approach
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless valid_email?(value)
      record.errors.add(attribute, "is not a valid email")
    end
  end
end

# New sacred geometry approach
config = {
  validator: ->(value) { valid_email?(value) },
  error_message: "is not a valid email",
  complexity: 2.618,
  efficiency: 1.618,
  base_energy: 1.0
}

EmailValidator = RichTextExtraction::Core::SacredValidatorFactory.register_validator(:email, config)
```

### From Traditional Testing

```ruby
# Old testing approach
RSpec.describe EmailValidator do
  it "validates email format" do
    validator = EmailValidator.new
    expect(validator.validate("test@example.com")).to be true
  end
end

# New sacred geometry testing
results = RichTextExtraction::Testing::SacredTestingFramework.test_validators_with_vortex
expect(results[:email][:overall_confidence]).to be > 1.5
```

This API reference provides comprehensive documentation for the sacred geometry-based RichTextExtraction system, enabling developers to leverage the power of natural mathematical principles for optimal software design and performance. 