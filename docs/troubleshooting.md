# Troubleshooting Guide

## Common Issues and Solutions

### 1. Sacred Geometry Compliance Issues

#### Problem: Low Sacred Geometry Score

**Symptoms:**
- `overall_sacred_score` below 0.8
- Golden ratio compliance warnings
- Vortex flow efficiency below 0.9

**Diagnosis:**
```ruby
# Check sacred geometry compliance
compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry

puts "Overall sacred score: #{compliance[:overall_sacred_score]}"
puts "Golden ratio compliance: #{compliance[:golden_ratio][:average_compliance]}"
puts "Vortex flow efficiency: #{compliance[:vortex_flow][:vortex_flow_efficiency]}"
```

**Solutions:**

1. **Adjust Golden Ratio Configuration:**
```ruby
RichTextExtraction.configure do |config|
  config.sacred_geometry.golden_ratio = 1.618033988749895
  config.sacred_geometry.vortex_constant = 2.665144142690225
end
```

2. **Revalidate Validators:**
```ruby
# Regenerate all validators with proper sacred proportions
RichTextExtraction::Core::SacredValidatorFactory.generate_all_validators

# Validate compliance again
compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
```

3. **Check Validator Configurations:**
```ruby
# Ensure all validators have proper complexity and efficiency ratios
validators = RichTextExtraction::Core::UniversalRegistry.list(:validator)

validators.each do |validator|
  config = RichTextExtraction::Core::UniversalRegistry.get(:validator, validator[:symbol])
  
  if config[:complexity] / config[:efficiency].to_f < 1.5
    puts "Warning: #{validator[:symbol]} has suboptimal golden ratio"
  end
end
```

#### Problem: Vortex Flow Disruptions

**Symptoms:**
- Vortex energy loss warnings
- Flow efficiency below 0.9
- Processing errors in vortex engine

**Diagnosis:**
```ruby
# Check vortex flow metrics
metrics = RichTextExtraction::Core::VortexEngine.calculate_vortex_flow_metrics

puts "Flow efficiency: #{metrics[:flow_efficiency]}"
puts "Total energy: #{metrics[:total_energy]}"
puts "Energy loss: #{metrics[:energy_loss]}"
```

**Solutions:**

1. **Reconfigure Vortex Engine:**
```ruby
RichTextExtraction::Core::VortexEngine.configure do |config|
  config.golden_angle = 137.5
  config.vortex_constant = 2.665144142690225
  config.energy_conservation = true
  config.flow_optimization = true
end
```

2. **Check Vortex Stages:**
```ruby
# Ensure proper vortex stage configuration
stages = [:validation, :extraction, :transformation]
RichTextExtraction::Core::VortexEngine.configure do |config|
  config.vortex_stages = stages
end
```

3. **Monitor Energy Conservation:**
```ruby
# Set up energy monitoring
ActiveSupport::Notifications.subscribe "rich_text_extraction.vortex_processing" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  
  if event.payload[:energy_loss] > 0.1
    Rails.logger.warn "High energy loss detected: #{event.payload[:energy_loss]}"
  end
end
```

### 2. Validator Issues

#### Problem: Validator Registration Failures

**Symptoms:**
- `SacredGeometryError` exceptions
- Validators not found in registry
- Registration timeout errors

**Diagnosis:**
```ruby
# Check validator registry
registry_status = RichTextExtraction::Core::UniversalRegistry.status

puts "Total validators: #{registry_status[:total_validators]}"
puts "Registry health: #{registry_status[:health]}"
puts "Last optimization: #{registry_status[:last_optimization]}"
```

**Solutions:**

1. **Clear and Rebuild Registry:**
```ruby
# Clear registry cache
RichTextExtraction::Core::UniversalRegistry.clear_cache

# Regenerate all validators
RichTextExtraction::Core::SacredValidatorFactory.generate_all_validators

# Validate registry
registry_status = RichTextExtraction::Core::UniversalRegistry.status
```

2. **Check Validator Configuration:**
```ruby
# Validate validator configuration
config = {
  validator: ->(value) { valid_email?(value) },
  complexity: 2.618,  # Must be > 1.0
  efficiency: 1.618,  # Must be > 1.0
  base_energy: 1.0    # Must be > 0.0
}

# Validate configuration
if config[:complexity] <= 1.0 || config[:efficiency] <= 1.0
  raise "Invalid validator configuration: complexity and efficiency must be > 1.0"
end
```

3. **Handle Registration Errors:**
```ruby
begin
  EmailValidator = RichTextExtraction::Core::SacredValidatorFactory.register_validator(:email, config)
rescue RichTextExtraction::Core::SacredGeometryError => e
  Rails.logger.error "Sacred geometry error: #{e.message}"
  Rails.logger.error "Golden ratio deviation: #{e.golden_ratio_deviation}"
  
  # Fallback to traditional validator
  EmailValidator = TraditionalEmailValidator
end
```

#### Problem: Low Validator Confidence

**Symptoms:**
- Confidence scores below 1.5
- Validation failures with valid input
- Inconsistent validation results

**Diagnosis:**
```ruby
# Test validator confidence
results = RichTextExtraction::Testing::SacredTestingFramework.test_validators_with_vortex

results.each do |validator_name, result|
  puts "#{validator_name}: confidence = #{result[:overall_confidence]}"
  
  if result[:overall_confidence] < 1.5
    puts "Warning: Low confidence for #{validator_name}"
  end
end
```

**Solutions:**

1. **Optimize Validator Logic:**
```ruby
# Improve validator efficiency
email_config = {
  validator: ->(value) { 
    # More efficient email validation
    value.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i) && 
    value.length <= 254 && 
    value.split('@').first.length <= 64
  },
  complexity: 2.618,
  efficiency: 1.618,
  base_energy: 1.0,
  validation_steps: 1  # Reduce complexity
}
```

2. **Adjust Sacred Proportions:**
```ruby
# Recalculate sacred proportions
config = {
  validator: ->(value) { valid_email?(value) },
  complexity: 1.618,  # Reduce complexity
  efficiency: 1.0,    # Increase efficiency
  base_energy: 1.0
}

# Validate golden ratio
golden_ratio = config[:complexity] / config[:efficiency].to_f
if golden_ratio < 1.5 || golden_ratio > 2.0
  puts "Warning: Golden ratio out of optimal range: #{golden_ratio}"
end
```

3. **Use Vortex Confidence Validation:**
```ruby
# Validate with vortex confidence
result = RichTextExtraction::Core::VortexEngine.validate_with_confidence(
  "test@example.com", 
  :email
)

if result[:confidence] < 1.5
  # Retry with different approach
  result = RichTextExtraction::Core::VortexEngine.validate_with_confidence(
    "test@example.com", 
    :email,
    confidence_threshold: 1.0
  )
end
```

### 3. Performance Issues

#### Problem: Slow Vortex Processing

**Symptoms:**
- Processing times above expected thresholds
- High memory usage during vortex operations
- Timeout errors in vortex engine

**Diagnosis:**
```ruby
# Profile vortex processing
require 'benchmark'

text = "Sample text for processing"
time = Benchmark.realtime do
  result = RichTextExtraction::Core::VortexEngine.extract_all(text)
end

puts "Processing time: #{time} seconds"
puts "Expected time: < 0.1 seconds"

if time > 0.1
  puts "Warning: Processing time exceeds threshold"
end
```

**Solutions:**

1. **Optimize Vortex Configuration:**
```ruby
# Optimize vortex engine settings
RichTextExtraction::Core::VortexEngine.configure do |config|
  config.flow_optimization = true
  config.energy_conservation = true
  config.max_processing_time = 0.1  # 100ms limit
  config.memory_limit = 50.megabytes
end
```

2. **Use Caching:**
```ruby
# Implement vortex result caching
def cached_vortex_processing(text)
  cache_key = "vortex_processing:#{Digest::MD5.hexdigest(text)}"
  
  Rails.cache.fetch(cache_key, expires_in: 1.hour) do
    RichTextExtraction::Core::VortexEngine.extract_all(text)
  end
end
```

3. **Batch Processing:**
```ruby
# Process multiple texts in batch
def batch_vortex_processing(texts)
  results = {}
  
  texts.each_slice(10) do |batch|
    batch_results = batch.map do |text|
      [text, RichTextExtraction::Core::VortexEngine.extract_all(text)]
    end
    
    results.merge!(batch_results.to_h)
  end
  
  results
end
```

#### Problem: High Memory Usage

**Symptoms:**
- Memory usage spikes during vortex operations
- Out of memory errors
- Slow garbage collection

**Diagnosis:**
```ruby
# Monitor memory usage
require 'memory_profiler'

report = MemoryProfiler.report do
  RichTextExtraction::Core::VortexEngine.extract_all(large_text)
end

puts "Memory allocated: #{report.total_allocated} bytes"
puts "Memory retained: #{report.total_retained} bytes"
```

**Solutions:**

1. **Optimize Memory Usage:**
```ruby
# Use streaming processing for large texts
def stream_vortex_processing(text, chunk_size = 1000)
  results = []
  
  text.chars.each_slice(chunk_size) do |chunk|
    chunk_text = chunk.join
    chunk_result = RichTextExtraction::Core::VortexEngine.extract_all(chunk_text)
    results << chunk_result
    
    # Force garbage collection
    GC.start if results.length % 10 == 0
  end
  
  merge_vortex_results(results)
end
```

2. **Limit Processing Scope:**
```ruby
# Process only necessary patterns
def selective_vortex_processing(text, patterns = [:links, :emails])
  config = {
    patterns: patterns,
    max_text_length: 10000,
    memory_limit: 10.megabytes
  }
  
  RichTextExtraction::Core::VortexEngine.extract_all(text, config)
end
```

3. **Use Weak References:**
```ruby
# Use weak references for large objects
require 'weakref'

def memory_efficient_processing(text)
  text_ref = WeakRef.new(text)
  
  result = RichTextExtraction::Core::VortexEngine.extract_all(text_ref.__getobj__)
  
  # Clear reference
  text_ref = nil
  GC.start
  
  result
end
```

### 4. Testing Issues

#### Problem: Test Failures with Sacred Geometry

**Symptoms:**
- Sacred geometry compliance test failures
- Vortex confidence test failures
- Golden ratio test failures

**Diagnosis:**
```ruby
# Run comprehensive diagnostics
def run_sacred_geometry_diagnostics
  results = {}
  
  # Test sacred geometry compliance
  results[:compliance] = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
  
  # Test validator confidence
  results[:validators] = RichTextExtraction::Testing::SacredTestingFramework.test_validators_with_vortex
  
  # Test extraction efficiency
  results[:extraction] = RichTextExtraction::Testing::SacredTestingFramework.test_extraction_with_golden_ratio
  
  results
end
```

**Solutions:**

1. **Fix Sacred Geometry Compliance:**
```ruby
# Ensure proper golden ratio configuration
RichTextExtraction.configure do |config|
  config.sacred_geometry.golden_ratio = 1.618033988749895
  config.sacred_geometry.vortex_constant = 2.665144142690225
  config.sacred_geometry.fibonacci_growth = true
end

# Regenerate validators with proper proportions
RichTextExtraction::Core::SacredValidatorFactory.generate_all_validators
```

2. **Adjust Test Thresholds:**
```ruby
# Configure test thresholds
RichTextExtraction::Testing::SacredTestingFramework.configure do |config|
  config.golden_ratio_threshold = 1.5
  config.vortex_confidence_threshold = 0.8
  config.sacred_balance_threshold = 0.9
end
```

3. **Handle Test Environment Issues:**
```ruby
# Ensure proper test environment setup
RSpec.configure do |config|
  config.before(:suite) do
    # Clear any cached configurations
    RichTextExtraction::Core::UniversalRegistry.clear_cache
    
    # Regenerate validators for test environment
    RichTextExtraction::Core::SacredValidatorFactory.generate_all_validators
    
    # Validate sacred geometry
    compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
    unless compliance[:overall_sacred_score] > 0.8
      raise "Sacred geometry compliance below threshold for testing"
    end
  end
end
```

### 5. Integration Issues

#### Problem: Rails Integration Failures

**Symptoms:**
- Validator not found errors in Rails models
- Vortex engine not available in controllers
- Sacred geometry configuration not loaded

**Diagnosis:**
```ruby
# Check Rails integration
def check_rails_integration
  issues = []
  
  # Check if sacred geometry is enabled
  unless RichTextExtraction.configuration.sacred_geometry.enabled
    issues << "Sacred geometry not enabled"
  end
  
  # Check if validators are registered
  validators = RichTextExtraction::Core::UniversalRegistry.list(:validator)
  if validators.empty?
    issues << "No validators registered"
  end
  
  # Check if vortex engine is available
  begin
    RichTextExtraction::Core::VortexEngine.extract_all("test")
  rescue => e
    issues << "Vortex engine not available: #{e.message}"
  end
  
  issues
end
```

**Solutions:**

1. **Fix Initialization Order:**
```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Load sacred geometry before other initializers
    config.before_initialize do
      require 'rich_text_extraction/core/universal_registry'
      require 'rich_text_extraction/core/sacred_validator_factory'
      require 'rich_text_extraction/core/vortex_engine'
    end
  end
end
```

2. **Ensure Proper Configuration:**
```ruby
# config/initializers/rich_text_extraction.rb
RichTextExtraction.configure do |config|
  config.sacred_geometry.enabled = true
  config.sacred_geometry.golden_ratio = 1.618033988749895
  config.sacred_geometry.vortex_constant = 2.665144142690225
  config.sacred_geometry.fibonacci_growth = true
end

# Generate validators after configuration
RichTextExtraction::Core::SacredValidatorFactory.generate_all_validators
```

3. **Add Error Handling:**
```ruby
# app/models/user.rb
class User < ApplicationRecord
  validates :email, email: true
  
  private
  
  def validate_email_with_fallback
    begin
      result = RichTextExtraction::Core::VortexEngine.validate_with_confidence(email, :email)
      result[:valid]
    rescue => e
      Rails.logger.error "Vortex validation failed: #{e.message}"
      # Fallback to traditional validation
      email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
    end
  end
end
```

## 🚨 Critical Error Scenarios

### 1. Infinite Loop Detection

#### Problem: Infinite Processing Loops

**Symptoms:**
- CPU usage spikes to 100%
- Processing never completes
- System becomes unresponsive
- Memory usage continuously increases

**Detection:**
```ruby
# Infinite loop detection system
class InfiniteLoopDetector
  def self.detect_infinite_loop(operation_name, max_iterations = 1000, max_time = 30.seconds)
    start_time = Time.current
    iteration_count = 0
    
    begin
      Timeout::timeout(max_time) do
        loop do
          iteration_count += 1
          
          if iteration_count > max_iterations
            raise InfiniteLoopError, "Operation #{operation_name} exceeded #{max_iterations} iterations"
          end
          
          # Check for infinite loop patterns
          if iteration_count % 100 == 0
            current_time = Time.current
            elapsed_time = current_time - start_time
            
            if elapsed_time > max_time
              raise InfiniteLoopError, "Operation #{operation_name} exceeded #{max_time} seconds"
            end
            
            # Force garbage collection to prevent memory leaks
            GC.start
          end
          
          # Your operation here
          yield if block_given?
        end
      end
    rescue Timeout::Error
      raise InfiniteLoopError, "Operation #{operation_name} timed out after #{max_time} seconds"
    end
  end
end

# Usage example
begin
  InfiniteLoopDetector.detect_infinite_loop("vortex_processing") do
    # Your potentially infinite operation
    RichTextExtraction::Core::VortexEngine.extract_all(text)
  end
rescue InfiniteLoopError => e
  Rails.logger.error "Infinite loop detected: #{e.message}"
  # Implement recovery procedures
  emergency_recovery
end
```

**Recovery Procedures:**
```ruby
# Emergency recovery for infinite loops
def emergency_recovery
  puts "🚨 EMERGENCY RECOVERY INITIATED 🚨"
  
  # Kill runaway processes
  kill_runaway_processes
  
  # Clear all caches
  clear_all_caches
  
  # Reset sacred geometry configuration
  reset_sacred_geometry_config
  
  # Restart vortex engine
  restart_vortex_engine
  
  # Validate system health
  validate_system_health
end

def kill_runaway_processes
  # Find and kill processes consuming excessive CPU
  system("pkill -f 'rich_text_extraction'") if system("pgrep -f 'rich_text_extraction'")
  
  # Force garbage collection
  GC.start
  GC.compact
end

def clear_all_caches
  RichTextExtraction::Core::UniversalRegistry.clear_cache
  Rails.cache.clear if defined?(Rails)
  GC.start
end

def reset_sacred_geometry_config
  RichTextExtraction.configure do |config|
    config.sacred_geometry.enabled = true
    config.sacred_geometry.golden_ratio = 1.618033988749895
    config.sacred_geometry.vortex_constant = 2.665144142690225
    config.sacred_geometry.fibonacci_growth = true
  end
end

def restart_vortex_engine
  RichTextExtraction::Core::VortexEngine.configure do |config|
    config.flow_optimization = true
    config.energy_conservation = true
    config.max_processing_time = 0.1
    config.memory_limit = 50.megabytes
  end
end
```

### 2. Memory Leak Detection

#### Problem: Memory Leaks in Vortex Processing

**Symptoms:**
- Memory usage continuously increases
- Garbage collection becomes ineffective
- System performance degrades over time
- Out of memory errors

**Detection:**
```ruby
# Memory leak detection system
class MemoryLeakDetector
  def self.detect_memory_leak(operation_name, max_memory_increase = 100.megabytes)
    initial_memory = GetProcessMem.new.mb
    memory_readings = [initial_memory]
    
    begin
      # Monitor memory usage over time
      10.times do |iteration|
        # Perform operation
        yield if block_given?
        
        # Force garbage collection
        GC.start
        
        # Record memory usage
        current_memory = GetProcessMem.new.mb
        memory_readings << current_memory
        
        # Check for memory leak
        memory_increase = current_memory - initial_memory
        
        if memory_increase > max_memory_increase
          raise MemoryLeakError, "Memory leak detected in #{operation_name}: #{memory_increase}MB increase"
        end
        
        # Wait before next iteration
        sleep(1)
      end
      
      # Analyze memory trend
      analyze_memory_trend(memory_readings, operation_name)
      
    rescue MemoryLeakError => e
      Rails.logger.error "Memory leak detected: #{e.message}"
      handle_memory_leak(operation_name)
      raise e
    end
  end
  
  def self.analyze_memory_trend(memory_readings, operation_name)
    if memory_readings.length < 3
      return
    end
    
    # Calculate memory growth rate
    growth_rate = (memory_readings.last - memory_readings.first) / memory_readings.length.to_f
    
    if growth_rate > 10  # More than 10MB per iteration
      Rails.logger.warn "Potential memory leak in #{operation_name}: #{growth_rate}MB per iteration"
    end
  end
  
  def self.handle_memory_leak(operation_name)
    puts "🧠 MEMORY LEAK DETECTED IN #{operation_name} 🧠"
    
    # Force aggressive garbage collection
    GC.start
    GC.compact
    
    # Clear caches
    clear_memory_caches
    
    # Restart memory-intensive components
    restart_memory_intensive_components
  end
  
  def self.clear_memory_caches
    RichTextExtraction::Core::UniversalRegistry.clear_cache
    Rails.cache.clear if defined?(Rails)
    
    # Clear object caches
    ObjectSpace.each_object do |obj|
      if obj.respond_to?(:clear_cache)
        obj.clear_cache rescue nil
      end
    end
  end
  
  def self.restart_memory_intensive_components
    # Restart vortex engine with memory limits
    RichTextExtraction::Core::VortexEngine.configure do |config|
      config.memory_limit = 10.megabytes  # Reduced limit
      config.force_garbage_collection = true
    end
  end
end

# Usage example
begin
  MemoryLeakDetector.detect_memory_leak("vortex_processing") do
    RichTextExtraction::Core::VortexEngine.extract_all(large_text)
  end
rescue MemoryLeakError => e
  Rails.logger.error "Memory leak recovery completed: #{e.message}"
end
```

### 3. Deadlock Detection

#### Problem: Deadlocks in Sacred Geometry Processing

**Symptoms:**
- Processing hangs indefinitely
- Multiple threads waiting for resources
- System becomes unresponsive
- No CPU or memory activity

**Detection:**
```ruby
# Deadlock detection system
class DeadlockDetector
  def self.detect_deadlock(operation_name, timeout = 30.seconds)
    thread_status = {}
    deadlock_detected = false
    
    begin
      Timeout::timeout(timeout) do
        # Monitor thread status
        Thread.new do
          loop do
            Thread.list.each do |thread|
              thread_status[thread.object_id] = {
                status: thread.status,
                backtrace: thread.backtrace&.first(5)
              }
            end
            
            # Check for deadlock patterns
            if deadlock_pattern_detected?(thread_status)
              deadlock_detected = true
              break
            end
            
            sleep(1)
          end
        end
        
        # Perform operation
        yield if block_given?
      end
      
    rescue Timeout::Error
      if deadlock_detected
        raise DeadlockError, "Deadlock detected in #{operation_name}"
      else
        raise TimeoutError, "Operation #{operation_name} timed out"
      end
    end
  end
  
  def self.deadlock_pattern_detected?(thread_status)
    # Check for threads stuck in waiting state
    waiting_threads = thread_status.values.select { |status| status[:status] == "sleep" }
    
    if waiting_threads.length > 2
      # Check if threads are waiting for the same resources
      backtraces = waiting_threads.map { |status| status[:backtrace] }
      
      # Simple deadlock detection based on backtrace similarity
      if backtraces.uniq.length < backtraces.length * 0.5
        return true
      end
    end
    
    false
  end
end

# Usage example
begin
  DeadlockDetector.detect_deadlock("vortex_processing") do
    RichTextExtraction::Core::VortexEngine.extract_all(text)
  end
rescue DeadlockError => e
  Rails.logger.error "Deadlock detected: #{e.message}"
  handle_deadlock
end

def handle_deadlock
  puts "🔒 DEADLOCK DETECTED 🔒"
  
  # Kill all threads except main thread
  Thread.list.each do |thread|
    next if thread == Thread.main
    thread.kill rescue nil
  end
  
  # Clear locks and semaphores
  clear_locks_and_semaphores
  
  # Restart processing with single-threaded mode
  restart_single_threaded_processing
end

def clear_locks_and_semaphores
  # Clear any global locks
  RichTextExtraction::Core::UniversalRegistry.clear_locks rescue nil
  RichTextExtraction::Core::VortexEngine.clear_locks rescue nil
end

def restart_single_threaded_processing
  RichTextExtraction::Core::VortexEngine.configure do |config|
    config.single_threaded_mode = true
    config.max_concurrent_operations = 1
  end
end
```

### 4. Resource Exhaustion

#### Problem: System Resource Exhaustion

**Symptoms:**
- File descriptor limits exceeded
- Database connection pool exhausted
- Network socket limits reached
- Disk space full

**Detection:**
```ruby
# Resource exhaustion detection
class ResourceExhaustionDetector
  def self.detect_resource_exhaustion
    issues = []
    
    # Check file descriptors
    if file_descriptors_exhausted?
      issues << "File descriptors exhausted"
    end
    
    # Check database connections
    if database_connections_exhausted?
      issues << "Database connections exhausted"
    end
    
    # Check memory usage
    if memory_exhausted?
      issues << "Memory exhausted"
    end
    
    # Check disk space
    if disk_space_exhausted?
      issues << "Disk space exhausted"
    end
    
    issues
  end
  
  def self.file_descriptors_exhausted?
    # Check file descriptor limit
    limit = Process.getrlimit(:NOFILE)[0]
    used = Dir.glob("/proc/#{Process.pid}/fd/*").length
    
    used > limit * 0.9  # 90% of limit
  end
  
  def self.database_connections_exhausted?
    return false unless defined?(ActiveRecord)
    
    pool_size = ActiveRecord::Base.connection_pool.size
    active_connections = ActiveRecord::Base.connection_pool.active_connection_count
    
    active_connections > pool_size * 0.9  # 90% of pool
  end
  
  def self.memory_exhausted?
    memory = GetProcessMem.new
    memory.mb > 1000  # 1GB limit
  end
  
  def self.disk_space_exhausted?
    stat = Sys::Filesystem.stat("/")
    used_percentage = (stat.blocks - stat.blocks_free) * 100.0 / stat.blocks
    
    used_percentage > 90  # 90% used
  end
end

# Usage example
issues = ResourceExhaustionDetector.detect_resource_exhaustion

if issues.any?
  puts "🚨 RESOURCE EXHAUSTION DETECTED 🚨"
  issues.each { |issue| puts "  - #{issue}" }
  handle_resource_exhaustion(issues)
end

def handle_resource_exhaustion(issues)
  issues.each do |issue|
    case issue
    when /file descriptors/
      handle_file_descriptor_exhaustion
    when /database connections/
      handle_database_connection_exhaustion
    when /memory/
      handle_memory_exhaustion
    when /disk space/
      handle_disk_space_exhaustion
    end
  end
end

def handle_file_descriptor_exhaustion
  # Close unnecessary file handles
  ObjectSpace.each_object(File) do |file|
    file.close rescue nil
  end
  
  # Increase file descriptor limit
  Process.setrlimit(:NOFILE, 4096) rescue nil
end

def handle_database_connection_exhaustion
  # Release database connections
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
  
  # Wait for connections to be released
  sleep(5)
end

def handle_memory_exhaustion
  # Force garbage collection
  GC.start
  GC.compact
  
  # Clear caches
  clear_all_caches
  
  # Restart memory-intensive processes
  restart_memory_intensive_processes
end

def handle_disk_space_exhaustion
  # Clear temporary files
  clear_temporary_files
  
  # Clear log files
  clear_old_log_files
  
  # Alert administrators
  alert_disk_space_issue
end
```

### 5. Catastrophic Failure Recovery

#### Problem: Complete System Failure

**Symptoms:**
- All sacred geometry components fail
- Vortex engine crashes
- Registry corruption
- Complete system unavailability

**Recovery Procedures:**
```ruby
# Catastrophic failure recovery system
class CatastrophicFailureRecovery
  def self.full_system_recovery
    puts "🚨 CATASTROPHIC FAILURE DETECTED 🚨"
    puts "Initiating full system recovery..."
    
    # Step 1: Emergency shutdown
    emergency_shutdown
    
    # Step 2: Clear all corrupted state
    clear_corrupted_state
    
    # Step 3: Restore from backup
    restore_from_backup
    
    # Step 4: Reinitialize sacred geometry
    reinitialize_sacred_geometry
    
    # Step 5: Validate system health
    validate_system_health
    
    puts "✅ Full system recovery completed"
  end
  
  def self.emergency_shutdown
    puts "  - Emergency shutdown initiated"
    
    # Kill all background processes
    kill_background_processes
    
    # Close all connections
    close_all_connections
    
    # Save current state for recovery
    save_recovery_state
  end
  
  def self.clear_corrupted_state
    puts "  - Clearing corrupted state"
    
    # Clear all caches
    clear_all_caches
    
    # Reset all configurations
    reset_all_configurations
    
    # Clear corrupted files
    clear_corrupted_files
  end
  
  def self.restore_from_backup
    puts "  - Restoring from backup"
    
    # Restore configuration from backup
    restore_configuration_backup
    
    # Restore validators from backup
    restore_validators_backup
    
    # Restore vortex engine state
    restore_vortex_engine_backup
  end
  
  def self.reinitialize_sacred_geometry
    puts "  - Reinitializing sacred geometry"
    
    # Reinitialize configuration
    RichTextExtraction.configure do |config|
      config.sacred_geometry.enabled = true
      config.sacred_geometry.golden_ratio = 1.618033988749895
      config.sacred_geometry.vortex_constant = 2.665144142690225
      config.sacred_geometry.fibonacci_growth = true
    end
    
    # Regenerate all components
    RichTextExtraction::Core::SacredValidatorFactory.generate_all_validators
    
    # Reconfigure vortex engine
    RichTextExtraction::Core::VortexEngine.configure do |config|
      config.golden_angle = 137.5
      config.vortex_constant = 2.665144142690225
      config.energy_conservation = true
      config.flow_optimization = true
    end
  end
  
  def self.validate_system_health
    puts "  - Validating system health"
    
    # Test sacred geometry compliance
    compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
    
    if compliance[:overall_sacred_score] < 0.8
      raise "System health validation failed: sacred geometry compliance too low"
    end
    
    # Test vortex engine
    result = RichTextExtraction::Core::VortexEngine.extract_all("test")
    
    if result[:sacred_geometry][:golden_ratio] < 1.5
      raise "System health validation failed: vortex engine not functioning properly"
    end
    
    puts "  ✅ System health validation passed"
  end
  
  private
  
  def self.kill_background_processes
    # Kill any background processes
    system("pkill -f 'rich_text_extraction'") if system("pgrep -f 'rich_text_extraction'")
  end
  
  def self.close_all_connections
    # Close database connections
    ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
    
    # Close file handles
    ObjectSpace.each_object(File) do |file|
      file.close rescue nil
    end
  end
  
  def self.save_recovery_state
    # Save current state for potential recovery
    recovery_state = {
      timestamp: Time.current,
      sacred_geometry_config: RichTextExtraction.configuration.sacred_geometry.to_h,
      validators_count: RichTextExtraction::Core::UniversalRegistry.list(:validator).length
    }
    
    File.write("/tmp/sacred_geometry_recovery_state.json", recovery_state.to_json)
  end
  
  def self.clear_all_caches
    RichTextExtraction::Core::UniversalRegistry.clear_cache
    Rails.cache.clear if defined?(Rails)
    GC.start
    GC.compact
  end
  
  def self.reset_all_configurations
    # Reset to default configurations
    RichTextExtraction.configure do |config|
      config.sacred_geometry.enabled = false
    end
  end
  
  def self.clear_corrupted_files
    # Remove corrupted temporary files
    Dir.glob("/tmp/sacred_geometry_*").each do |file|
      File.delete(file) rescue nil
    end
  end
  
  def self.restore_configuration_backup
    backup_file = "/tmp/sacred_geometry_config_backup.json"
    
    if File.exist?(backup_file)
      config_data = JSON.parse(File.read(backup_file))
      
      RichTextExtraction.configure do |config|
        config.sacred_geometry.enabled = config_data["enabled"]
        config.sacred_geometry.golden_ratio = config_data["golden_ratio"]
        config.sacred_geometry.vortex_constant = config_data["vortex_constant"]
      end
    end
  end
  
  def self.restore_validators_backup
    backup_file = "/tmp/sacred_geometry_validators_backup.json"
    
    if File.exist?(backup_file)
      validators_data = JSON.parse(File.read(backup_file))
      
      validators_data.each do |validator_data|
        RichTextExtraction::Core::SacredValidatorFactory.register_validator(
          validator_data["symbol"].to_sym,
          validator_data["config"]
        )
      end
    end
  end
  
  def self.restore_vortex_engine_backup
    backup_file = "/tmp/sacred_geometry_vortex_backup.json"
    
    if File.exist?(backup_file)
      vortex_data = JSON.parse(File.read(backup_file))
      
      RichTextExtraction::Core::VortexEngine.configure do |config|
        config.golden_angle = vortex_data["golden_angle"]
        config.vortex_constant = vortex_data["vortex_constant"]
        config.energy_conservation = vortex_data["energy_conservation"]
      end
    end
  end
end

# Usage example
begin
  # Attempt normal operation
  result = RichTextExtraction::Core::VortexEngine.extract_all(text)
rescue => e
  if e.message.include?("catastrophic") || e.message.include?("fatal")
    CatastrophicFailureRecovery.full_system_recovery
    # Retry operation
    result = RichTextExtraction::Core::VortexEngine.extract_all(text)
  else
    raise e
  end
end
```

## 🔧 Debugging Tools

### 1. Sacred Geometry Debugger

```ruby
# Debug sacred geometry issues
class SacredGeometryDebugger
  def self.debug_system
    puts "=== Sacred Geometry Debug Report ==="
    
    # Check configuration
    puts "Configuration:"
    puts "  Sacred geometry enabled: #{RichTextExtraction.configuration.sacred_geometry.enabled}"
    puts "  Golden ratio: #{RichTextExtraction.configuration.sacred_geometry.golden_ratio}"
    puts "  Vortex constant: #{RichTextExtraction.configuration.sacred_geometry.vortex_constant}"
    
    # Check registry
    puts "\nRegistry:"
    registry_status = RichTextExtraction::Core::UniversalRegistry.status
    puts "  Total validators: #{registry_status[:total_validators]}"
    puts "  Registry health: #{registry_status[:health]}"
    
    # Check compliance
    puts "\nCompliance:"
    compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
    puts "  Overall sacred score: #{compliance[:overall_sacred_score]}"
    puts "  Golden ratio compliance: #{compliance[:golden_ratio][:average_compliance]}"
    
    # Check performance
    puts "\nPerformance:"
    performance = RichTextExtraction::Core::VortexEngine.calculate_golden_ratio_performance
    puts "  Golden ratio efficiency: #{performance[:efficiency]}"
    puts "  Optimal ratio deviation: #{performance[:deviation]}"
  end
end
```

### 2. Vortex Flow Monitor

```ruby
# Monitor vortex flow in real-time
class VortexFlowMonitor
  def self.monitor_processing(text)
    start_time = Time.current
    start_memory = GetProcessMem.new.mb
    
    result = RichTextExtraction::Core::VortexEngine.extract_all(text)
    
    end_time = Time.current
    end_memory = GetProcessMem.new.mb
    
    {
      processing_time: end_time - start_time,
      memory_usage: end_memory - start_memory,
      result: result,
      metrics: {
        golden_ratio: result[:sacred_geometry][:golden_ratio],
        vortex_energy: result[:vortex_metrics][:total_energy],
        flow_efficiency: result[:vortex_metrics][:flow_efficiency]
      }
    }
  end
end
```

### 3. Performance Profiler

```ruby
# Profile sacred geometry performance
class SacredGeometryProfiler
  def self.profile_operation(operation_name, &block)
    require 'benchmark'
    require 'memory_profiler'
    
    puts "=== Profiling #{operation_name} ==="
    
    # Time profiling
    time_result = Benchmark.measure(&block)
    puts "Time: #{time_result.real} seconds"
    
    # Memory profiling
    memory_report = MemoryProfiler.report(&block)
    puts "Memory allocated: #{memory_report.total_allocated} bytes"
    puts "Memory retained: #{memory_report.total_retained} bytes"
    
    # Sacred geometry metrics
    if block_given?
      result = yield
      if result.is_a?(Hash) && result[:sacred_geometry]
        puts "Golden ratio: #{result[:sacred_geometry][:golden_ratio]}"
        puts "Vortex energy: #{result[:vortex_metrics][:total_energy]}"
      end
    end
  end
end
```

## Emergency Procedures

### 1. System Recovery

```ruby
# Emergency system recovery
def emergency_recovery
  puts "Starting emergency recovery..."
  
  # Clear all caches
  RichTextExtraction::Core::UniversalRegistry.clear_cache
  Rails.cache.clear if defined?(Rails)
  
  # Reset configuration
  RichTextExtraction.configure do |config|
    config.sacred_geometry.enabled = true
    config.sacred_geometry.golden_ratio = 1.618033988749895
    config.sacred_geometry.vortex_constant = 2.665144142690225
    config.sacred_geometry.fibonacci_growth = true
  end
  
  # Regenerate validators
  RichTextExtraction::Core::SacredValidatorFactory.generate_all_validators
  
  # Validate system
  compliance = RichTextExtraction::Testing::SacredTestingFramework.validate_sacred_geometry
  
  if compliance[:overall_sacred_score] > 0.8
    puts "Recovery successful"
  else
    puts "Recovery failed - manual intervention required"
  end
end
```

### 2. Fallback Mode

```ruby
# Enable fallback mode
def enable_fallback_mode
  RichTextExtraction.configure do |config|
    config.sacred_geometry.enabled = false
    config.backward_compatibility.enabled = true
  end
  
  puts "Fallback mode enabled - using traditional validators"
end
```

This troubleshooting guide provides comprehensive solutions for common issues with the sacred geometry-based RichTextExtraction system, ensuring optimal performance and reliability. 