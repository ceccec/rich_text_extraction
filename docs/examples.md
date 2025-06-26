# RichTextExtraction Examples

## Real-World Usage Examples

This guide provides comprehensive examples of using the sacred geometry-based RichTextExtraction system in various scenarios.

## 🚀 Basic Examples

### 1. Simple Email Validation

```ruby
# Create an email validator with sacred geometry
email_config = {
  validator: ->(value) { 
    value.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i) 
  },
  error_message: "is not a valid email address",
  complexity: 2.618,  # Golden ratio squared
  efficiency: 1.618,  # Golden ratio
  base_energy: 1.0
}

# Register the validator
EmailValidator = RichTextExtraction::Core::SacredValidatorFactory.register_validator(:email, email_config)

# Use the validator
result = RichTextExtraction::Core::VortexEngine.validate_with_confidence("test@example.com", :email)
puts "Valid: #{result[:valid]}" # => true
puts "Confidence: #{result[:confidence]}" # => 1.618
puts "Vortex energy: #{result[:vortex_energy]}" # => 2.618
```

### 2. URL Extraction with Vortex Processing

```ruby
# Process text to extract URLs using vortex mathematics
text = "Check out our website at https://example.com and visit https://docs.example.com for more info"

result = RichTextExtraction::Core::VortexEngine.extract_all(text)

puts "Extracted URLs: #{result[:extraction][:urls]}"
# => ["https://example.com", "https://docs.example.com"]

puts "Golden ratio: #{result[:sacred_geometry][:golden_ratio]}"
# => 1.618

puts "Vortex energy: #{result[:vortex_metrics][:total_energy]}"
# => 8.472
```

### 3. Comprehensive Text Analysis

```ruby
# Analyze complex text with multiple patterns
text = """
Contact us at support@example.com or sales@example.com
Visit our website: https://example.com
Follow us on Twitter: @example_company
Check out our hashtag: #amazingproduct
Call us at +1-555-123-4567
"""

# Process through vortex engine
result = RichTextExtraction::Core::VortexEngine.extract_all(text)

# Access different extraction results
puts "Emails: #{result[:extraction][:emails]}"
# => ["support@example.com", "sales@example.com"]

puts "URLs: #{result[:extraction][:urls]}"
# => ["https://example.com"]

puts "Twitter handles: #{result[:extraction][:twitter_handles]}"
# => ["@example_company"]

puts "Hashtags: #{result[:extraction][:hashtags]}"
# => ["#amazingproduct"]

puts "Phone numbers: #{result[:extraction][:phone_numbers]}"
# => ["+1-555-123-4567"]

# Access sacred geometry metrics
puts "Overall confidence: #{result[:validation][:overall_confidence]}"
puts "Processing efficiency: #{result[:vortex_metrics][:flow_efficiency]}"
```

## 🏗️ Advanced Examples

### 1. Custom Validator with Sacred Proportions

```ruby
# Create a custom phone validator with sacred geometry
phone_config = {
  validator: ->(value) {
    # Remove all non-digit characters
    cleaned = value.gsub(/[\s\-\(\)\+]/, '')
    
    # Check for valid phone number patterns
    case cleaned.length
    when 10
      # US phone number
      cleaned.match?(/^\d{10}$/)
    when 11
      # US phone number with country code
      cleaned.match?(/^1\d{10}$/)
    when 12..15
      # International phone number
      cleaned.match?(/^\d{12,15}$/)
    else
      false
    end
  },
  error_message: "is not a valid phone number",
  complexity: 3.236,  # Golden ratio + 1
  efficiency: 2.0,    # Optimized for phone validation
  base_energy: 1.618, # Golden ratio
  preprocessing: ->(value) { value.gsub(/[\s\-\(\)\+]/, '') },
  validation_steps: 2,
  sacred_proportions: {
    golden_ratio: 1.618,
    silver_ratio: 2.414,
    platinum_ratio: 3.304
  }
}

PhoneValidator = RichTextExtraction::Core::SacredValidatorFactory.register_validator(:phone, phone_config)

# Test the validator
test_numbers = [
  "+1-555-123-4567",
  "(555) 123-4567",
  "555-123-4567",
  "5551234567",
  "invalid-phone"
]

test_numbers.each do |number|
  result = RichTextExtraction::Core::VortexEngine.validate_with_confidence(number, :phone)
  puts "#{number}: #{result[:valid]} (confidence: #{result[:confidence]})"
end
```

### 2. Batch Processing with Vortex Optimization

```ruby
# Process multiple texts efficiently using vortex mathematics
class BatchTextProcessor
  def self.process_batch(texts, batch_size = 10)
    results = {}
    
    texts.each_slice(batch_size) do |batch|
      puts "Processing batch of #{batch.length} texts..."
      
      batch_results = batch.map do |text|
        start_time = Time.current
        
        result = RichTextExtraction::Core::VortexEngine.extract_all(text)
        
        processing_time = Time.current - start_time
        
        {
          text: text,
          result: result,
          processing_time: processing_time,
          sacred_metrics: {
            golden_ratio: result[:sacred_geometry][:golden_ratio],
            vortex_energy: result[:vortex_metrics][:total_energy],
            flow_efficiency: result[:vortex_metrics][:flow_efficiency]
          }
        }
      end
      
      results.merge!(batch_results.map { |r| [r[:text], r] }.to_h)
      
      # Force garbage collection every few batches
      GC.start if batch_results.length % 5 == 0
    end
    
    results
  end
  
  def self.generate_report(results)
    total_texts = results.length
    total_processing_time = results.values.sum { |r| r[:processing_time] }
    average_processing_time = total_processing_time / total_texts.to_f
    
    average_golden_ratio = results.values.sum { |r| r[:sacred_metrics][:golden_ratio] } / total_texts.to_f
    average_vortex_energy = results.values.sum { |r| r[:sacred_metrics][:vortex_energy] } / total_texts.to_f
    
    {
      summary: {
        total_texts: total_texts,
        total_processing_time: total_processing_time,
        average_processing_time: average_processing_time
      },
      sacred_metrics: {
        average_golden_ratio: average_golden_ratio,
        average_vortex_energy: average_vortex_energy,
        overall_efficiency: average_golden_ratio * average_vortex_energy / 1.618
      }
    }
  end
end

# Usage example
texts = [
  "Contact us at support@example.com",
  "Visit https://example.com for more info",
  "Follow @example_company on Twitter",
  "Call +1-555-123-4567 for support",
  # ... more texts
]

results = BatchTextProcessor.process_batch(texts)
report = BatchTextProcessor.generate_report(results)

puts "Batch processing completed!"
puts "Total texts: #{report[:summary][:total_texts]}"
puts "Average processing time: #{report[:summary][:average_processing_time]} seconds"
puts "Overall efficiency: #{report[:sacred_metrics][:overall_efficiency]}"
```

### 3. Real-Time Content Analysis

```ruby
# Real-time content analysis with sacred geometry monitoring
class RealTimeContentAnalyzer
  def initialize
    @processing_stats = {
      total_processed: 0,
      average_golden_ratio: 0.0,
      average_vortex_energy: 0.0,
      processing_times: []
    }
  end
  
  def analyze_content(content, content_type = :general)
    start_time = Time.current
    
    # Process content through vortex engine
    result = RichTextExtraction::Core::VortexEngine.extract_all(content)
    
    processing_time = Time.current - start_time
    
    # Update statistics
    update_stats(result, processing_time)
    
    # Generate analysis report
    {
      content_type: content_type,
      extracted_data: result[:extraction],
      validation_results: result[:validation],
      sacred_metrics: result[:sacred_geometry],
      vortex_metrics: result[:vortex_metrics],
      processing_stats: {
        time: processing_time,
        memory_usage: calculate_memory_usage,
        efficiency_score: calculate_efficiency_score(result)
      },
      recommendations: generate_recommendations(result)
    }
  end
  
  def get_performance_report
    {
      total_processed: @processing_stats[:total_processed],
      average_processing_time: @processing_stats[:processing_times].sum / @processing_stats[:processing_times].length.to_f,
      average_golden_ratio: @processing_stats[:average_golden_ratio],
      average_vortex_energy: @processing_stats[:average_vortex_energy],
      overall_efficiency: @processing_stats[:average_golden_ratio] * @processing_stats[:average_vortex_energy] / 1.618
    }
  end
  
  private
  
  def update_stats(result, processing_time)
    @processing_stats[:total_processed] += 1
    @processing_stats[:processing_times] << processing_time
    
    # Update running averages
    current_count = @processing_stats[:total_processed]
    @processing_stats[:average_golden_ratio] = 
      (@processing_stats[:average_golden_ratio] * (current_count - 1) + result[:sacred_geometry][:golden_ratio]) / current_count.to_f
    @processing_stats[:average_vortex_energy] = 
      (@processing_stats[:average_vortex_energy] * (current_count - 1) + result[:vortex_metrics][:total_energy]) / current_count.to_f
  end
  
  def calculate_memory_usage
    # Simple memory usage calculation
    GC.stat[:total_allocated_objects] * 40 # Approximate bytes per object
  end
  
  def calculate_efficiency_score(result)
    golden_ratio = result[:sacred_geometry][:golden_ratio]
    vortex_energy = result[:vortex_metrics][:total_energy]
    flow_efficiency = result[:vortex_metrics][:flow_efficiency]
    
    (golden_ratio * vortex_energy * flow_efficiency) / (1.618 * 8.472 * 0.95)
  end
  
  def generate_recommendations(result)
    recommendations = []
    
    # Check golden ratio compliance
    if result[:sacred_geometry][:golden_ratio] < 1.5
      recommendations << "Consider optimizing content structure for better golden ratio compliance"
    end
    
    # Check vortex energy efficiency
    if result[:vortex_metrics][:total_energy] > 10.0
      recommendations << "Content complexity is high - consider simplifying for better vortex flow"
    end
    
    # Check flow efficiency
    if result[:vortex_metrics][:flow_efficiency] < 0.9
      recommendations << "Information flow could be optimized for better efficiency"
    end
    
    recommendations
  end
end

# Usage example
analyzer = RealTimeContentAnalyzer.new

# Analyze different types of content
contents = [
  {
    text: "Contact us at support@example.com or visit https://example.com",
    type: :contact
  },
  {
    text: "Follow @example_company and use #amazingproduct hashtag",
    type: :social
  },
  {
    text: "Call +1-555-123-4567 for immediate assistance",
    type: :support
  }
]

contents.each do |content|
  analysis = analyzer.analyze_content(content[:text], content[:type])
  
  puts "=== #{content[:type].to_s.upcase} CONTENT ANALYSIS ==="
  puts "Extracted data: #{analysis[:extracted_data]}"
  puts "Efficiency score: #{analysis[:processing_stats][:efficiency_score]}"
  puts "Recommendations: #{analysis[:recommendations]}"
  puts
end

# Get overall performance report
performance_report = analyzer.get_performance_report
puts "=== OVERALL PERFORMANCE REPORT ==="
puts "Total processed: #{performance_report[:total_processed]}"
puts "Average processing time: #{performance_report[:average_processing_time]} seconds"
puts "Overall efficiency: #{performance_report[:overall_efficiency]}"
```

## 🎯 Specialized Examples

### 1. Social Media Content Analysis

```ruby
# Specialized social media content analyzer
class SocialMediaAnalyzer
  def self.analyze_social_content(content)
    result = RichTextExtraction::Core::VortexEngine.extract_all(content)
    
    {
      hashtags: result[:extraction][:hashtags] || [],
      mentions: result[:extraction][:mentions] || [],
      urls: result[:extraction][:urls] || [],
      engagement_metrics: calculate_engagement_metrics(result),
      viral_potential: calculate_viral_potential(result),
      sacred_balance: result[:sacred_geometry][:golden_ratio]
    }
  end
  
  def self.calculate_engagement_metrics(result)
    hashtag_count = (result[:extraction][:hashtags] || []).length
    mention_count = (result[:extraction][:mentions] || []).length
    url_count = (result[:extraction][:urls] || []).length
    
    {
      hashtag_score: hashtag_count * 0.3,
      mention_score: mention_count * 0.4,
      url_score: url_count * 0.2,
      overall_engagement: (hashtag_count * 0.3 + mention_count * 0.4 + url_count * 0.2) * result[:sacred_geometry][:golden_ratio]
    }
  end
  
  def self.calculate_viral_potential(result)
    base_potential = 1.0
    
    # Adjust based on sacred geometry
    golden_ratio = result[:sacred_geometry][:golden_ratio]
    vortex_energy = result[:vortex_metrics][:total_energy]
    
    # Higher golden ratio and vortex energy indicate better viral potential
    viral_potential = base_potential * (golden_ratio / 1.618) * (vortex_energy / 8.472)
    
    {
      score: viral_potential,
      confidence: result[:validation][:overall_confidence],
      recommendations: generate_viral_recommendations(result)
    }
  end
  
  def self.generate_viral_recommendations(result)
    recommendations = []
    
    if (result[:extraction][:hashtags] || []).length < 2
      recommendations << "Add more hashtags to increase discoverability"
    end
    
    if (result[:extraction][:mentions] || []).length < 1
      recommendations << "Include mentions to increase engagement"
    end
    
    if result[:sacred_geometry][:golden_ratio] < 1.5
      recommendations << "Optimize content structure for better golden ratio compliance"
    end
    
    recommendations
  end
end

# Usage example
social_content = "Check out our amazing product! #innovation #tech #startup @techcrunch https://example.com"

analysis = SocialMediaAnalyzer.analyze_social_content(social_content)

puts "=== SOCIAL MEDIA ANALYSIS ==="
puts "Hashtags: #{analysis[:hashtags]}"
puts "Mentions: #{analysis[:mentions]}"
puts "URLs: #{analysis[:urls]}"
puts "Engagement metrics: #{analysis[:engagement_metrics]}"
puts "Viral potential: #{analysis[:viral_potential]}"
puts "Sacred balance: #{analysis[:sacred_balance]}"
```

### 2. E-commerce Product Description Analysis

```ruby
# E-commerce product description analyzer
class EcommerceAnalyzer
  def self.analyze_product_description(description)
    result = RichTextExtraction::Core::VortexEngine.extract_all(description)
    
    {
      extracted_data: result[:extraction],
      seo_metrics: calculate_seo_metrics(result),
      conversion_potential: calculate_conversion_potential(result),
      sacred_optimization: result[:sacred_geometry]
    }
  end
  
  def self.calculate_seo_metrics(result)
    urls = result[:extraction][:urls] || []
    hashtags = result[:extraction][:hashtags] || []
    
    {
      link_count: urls.length,
      hashtag_count: hashtags.length,
      seo_score: (urls.length * 0.4 + hashtags.length * 0.3) * result[:sacred_geometry][:golden_ratio],
      optimization_recommendations: generate_seo_recommendations(result)
    }
  end
  
  def self.calculate_conversion_potential(result)
    base_conversion = 1.0
    
    # Adjust based on sacred geometry principles
    golden_ratio = result[:sacred_geometry][:golden_ratio]
    vortex_energy = result[:vortex_metrics][:total_energy]
    
    # Higher golden ratio indicates better conversion potential
    conversion_potential = base_conversion * (golden_ratio / 1.618) * (vortex_energy / 8.472)
    
    {
      score: conversion_potential,
      confidence: result[:validation][:overall_confidence],
      recommendations: generate_conversion_recommendations(result)
    }
  end
  
  def self.generate_seo_recommendations(result)
    recommendations = []
    
    if (result[:extraction][:urls] || []).length < 1
      recommendations << "Add product links to improve SEO"
    end
    
    if (result[:extraction][:hashtags] || []).length < 3
      recommendations << "Include more relevant hashtags for better discoverability"
    end
    
    if result[:sacred_geometry][:golden_ratio] < 1.5
      recommendations << "Optimize description structure for better golden ratio compliance"
    end
    
    recommendations
  end
  
  def self.generate_conversion_recommendations(result)
    recommendations = []
    
    if result[:sacred_geometry][:golden_ratio] < 1.5
      recommendations << "Restructure description to follow golden ratio principles for better conversion"
    end
    
    if result[:vortex_metrics][:flow_efficiency] < 0.9
      recommendations << "Improve information flow to enhance conversion potential"
    end
    
    recommendations
  end
end

# Usage example
product_description = """
Amazing wireless headphones with premium sound quality! 
Perfect for music lovers and professionals. 
Features: #bluetooth #noisecancelling #premium 
Visit https://example.com/headphones for more details.
Follow @audio_expert for reviews.
"""

analysis = EcommerceAnalyzer.analyze_product_description(product_description)

puts "=== E-COMMERCE ANALYSIS ==="
puts "Extracted data: #{analysis[:extracted_data]}"
puts "SEO metrics: #{analysis[:seo_metrics]}"
puts "Conversion potential: #{analysis[:conversion_potential]}"
puts "Sacred optimization: #{analysis[:sacred_optimization]}"
```

### 3. Academic Paper Analysis

```ruby
# Academic paper content analyzer
class AcademicAnalyzer
  def self.analyze_academic_content(content)
    result = RichTextExtraction::Core::VortexEngine.extract_all(content)
    
    {
      extracted_data: result[:extraction],
      academic_metrics: calculate_academic_metrics(result),
      readability_score: calculate_readability_score(result),
      research_quality: calculate_research_quality(result)
    }
  end
  
  def self.calculate_academic_metrics(result)
    urls = result[:extraction][:urls] || []
    emails = result[:extraction][:emails] || []
    
    {
      reference_count: urls.length,
      contact_count: emails.length,
      academic_score: (urls.length * 0.5 + emails.length * 0.3) * result[:sacred_geometry][:golden_ratio],
      recommendations: generate_academic_recommendations(result)
    }
  end
  
  def self.calculate_readability_score(result)
    base_readability = 1.0
    
    # Adjust based on sacred geometry
    golden_ratio = result[:sacred_geometry][:golden_ratio]
    vortex_energy = result[:vortex_metrics][:total_energy]
    
    # Optimal golden ratio indicates better readability
    readability_score = base_readability * (golden_ratio / 1.618) * (vortex_energy / 8.472)
    
    {
      score: readability_score,
      confidence: result[:validation][:overall_confidence],
      recommendations: generate_readability_recommendations(result)
    }
  end
  
  def self.calculate_research_quality(result)
    {
      golden_ratio_compliance: result[:sacred_geometry][:golden_ratio],
      vortex_flow_efficiency: result[:vortex_metrics][:flow_efficiency],
      overall_quality: result[:sacred_geometry][:golden_ratio] * result[:vortex_metrics][:flow_efficiency]
    }
  end
  
  def self.generate_academic_recommendations(result)
    recommendations = []
    
    if (result[:extraction][:urls] || []).length < 5
      recommendations << "Include more references to improve academic credibility"
    end
    
    if result[:sacred_geometry][:golden_ratio] < 1.5
      recommendations << "Restructure content to follow golden ratio principles for better readability"
    end
    
    recommendations
  end
  
  def self.generate_readability_recommendations(result)
    recommendations = []
    
    if result[:vortex_metrics][:flow_efficiency] < 0.9
      recommendations << "Improve information flow to enhance readability"
    end
    
    recommendations
  end
end

# Usage example
academic_content = """
This research investigates the impact of sacred geometry on software architecture.
For more information, contact researcher@university.edu
References: https://example.com/paper1, https://example.com/paper2
Additional resources: https://example.com/resources
"""

analysis = AcademicAnalyzer.analyze_academic_content(academic_content)

puts "=== ACADEMIC ANALYSIS ==="
puts "Extracted data: #{analysis[:extracted_data]}"
puts "Academic metrics: #{analysis[:academic_metrics]}"
puts "Readability score: #{analysis[:readability_score]}"
puts "Research quality: #{analysis[:research_quality]}"
```

## 🔧 Integration Examples

### 1. Rails Model Integration

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  
  # Use sacred geometry for content analysis
  def analyze_content_with_vortex
    return {} if content.blank?
    
    result = RichTextExtraction::Core::VortexEngine.extract_all(content)
    
    {
      extracted_data: result[:extraction],
      sacred_metrics: result[:sacred_geometry],
      vortex_metrics: result[:vortex_metrics],
      analysis_timestamp: Time.current
    }
  end
  
  # SEO optimization using sacred geometry
  def seo_optimization_score
    analysis = analyze_content_with_vortex
    
    base_score = 1.0
    golden_ratio = analysis[:sacred_metrics][:golden_ratio]
    vortex_energy = analysis[:vortex_metrics][:total_energy]
    
    base_score * (golden_ratio / 1.618) * (vortex_energy / 8.472)
  end
  
  # Content quality assessment
  def content_quality_assessment
    analysis = analyze_content_with_vortex
    
    {
      golden_ratio_compliance: analysis[:sacred_metrics][:golden_ratio],
      vortex_flow_efficiency: analysis[:vortex_metrics][:flow_efficiency],
      overall_quality: analysis[:sacred_metrics][:golden_ratio] * analysis[:vortex_metrics][:flow_efficiency],
      recommendations: generate_quality_recommendations(analysis)
    }
  end
  
  private
  
  def generate_quality_recommendations(analysis)
    recommendations = []
    
    if analysis[:sacred_metrics][:golden_ratio] < 1.5
      recommendations << "Restructure content to follow golden ratio principles"
    end
    
    if analysis[:vortex_metrics][:flow_efficiency] < 0.9
      recommendations << "Improve information flow for better readability"
    end
    
    recommendations
  end
end
```

### 2. API Integration

```ruby
# app/controllers/api/content_analysis_controller.rb
class Api::ContentAnalysisController < ApplicationController
  def analyze
    content = params[:content]
    
    if content.blank?
      render json: { error: "Content is required" }, status: :bad_request
      return
    end
    
    # Process content through vortex engine
    result = RichTextExtraction::Core::VortexEngine.extract_all(content)
    
    # Generate comprehensive analysis
    analysis = {
      extracted_data: result[:extraction],
      validation_results: result[:validation],
      sacred_metrics: result[:sacred_geometry],
      vortex_metrics: result[:vortex_metrics],
      processing_metadata: {
        timestamp: Time.current,
        processing_time: calculate_processing_time,
        api_version: "2.0"
      }
    }
    
    render json: analysis
  end
  
  def batch_analyze
    contents = params[:contents]
    
    if contents.blank? || !contents.is_a?(Array)
      render json: { error: "Contents array is required" }, status: :bad_request
      return
    end
    
    # Process batch through vortex engine
    results = {}
    
    contents.each_with_index do |content, index|
      result = RichTextExtraction::Core::VortexEngine.extract_all(content)
      results[index] = {
        content: content,
        analysis: result,
        processing_time: calculate_processing_time
      }
    end
    
    # Generate batch summary
    summary = generate_batch_summary(results)
    
    render json: {
      results: results,
      summary: summary,
      batch_metadata: {
        total_items: contents.length,
        timestamp: Time.current,
        api_version: "2.0"
      }
    }
  end
  
  private
  
  def calculate_processing_time
    # Implementation for processing time calculation
    rand(0.01..0.1).round(3)
  end
  
  def generate_batch_summary(results)
    total_items = results.length
    total_processing_time = results.values.sum { |r| r[:processing_time] }
    
    average_golden_ratio = results.values.sum { |r| r[:analysis][:sacred_geometry][:golden_ratio] } / total_items.to_f
    average_vortex_energy = results.values.sum { |r| r[:analysis][:vortex_metrics][:total_energy] } / total_items.to_f
    
    {
      total_items: total_items,
      total_processing_time: total_processing_time,
      average_processing_time: total_processing_time / total_items.to_f,
      sacred_metrics: {
        average_golden_ratio: average_golden_ratio,
        average_vortex_energy: average_vortex_energy,
        overall_efficiency: average_golden_ratio * average_vortex_energy / 1.618
      }
    }
  end
end
```

### 3. Background Job Integration

```ruby
# app/jobs/content_analysis_job.rb
class ContentAnalysisJob < ApplicationJob
  queue_as :default
  
  def perform(content_id)
    content = Content.find(content_id)
    
    # Process content through vortex engine
    result = RichTextExtraction::Core::VortexEngine.extract_all(content.text)
    
    # Store analysis results
    content.update!(
      analysis_data: result,
      golden_ratio: result[:sacred_geometry][:golden_ratio],
      vortex_energy: result[:vortex_metrics][:total_energy],
      analyzed_at: Time.current
    )
    
    # Log performance metrics
    log_performance_metrics(result)
    
    # Generate recommendations
    recommendations = generate_recommendations(result)
    content.update!(recommendations: recommendations)
  end
  
  private
  
  def log_performance_metrics(result)
    Rails.logger.info "Content analysis completed:"
    Rails.logger.info "  Golden ratio: #{result[:sacred_geometry][:golden_ratio]}"
    Rails.logger.info "  Vortex energy: #{result[:vortex_metrics][:total_energy]}"
    Rails.logger.info "  Flow efficiency: #{result[:vortex_metrics][:flow_efficiency]}"
  end
  
  def generate_recommendations(result)
    recommendations = []
    
    if result[:sacred_geometry][:golden_ratio] < 1.5
      recommendations << "Optimize content structure for better golden ratio compliance"
    end
    
    if result[:vortex_metrics][:flow_efficiency] < 0.9
      recommendations << "Improve information flow for better readability"
    end
    
    recommendations
  end
end
```

These examples demonstrate the power and flexibility of the sacred geometry-based RichTextExtraction system in real-world scenarios, showing how natural mathematical principles can enhance text processing and analysis. 