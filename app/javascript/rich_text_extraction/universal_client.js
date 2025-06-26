class RichTextExtractionClient {
  constructor(baseUrl = '/api') {
    this.baseUrl = baseUrl;
  }
  
  async extractText(text, options = {}) {
    const response = await fetch(`${this.baseUrl}/extract`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ text, ...options })
    });
    
    if (!response.ok) {
      throw new Error(`Extraction failed: ${response.statusText}`);
    }
    
    return await response.json();
  }
  
  async batchExtract(texts, options = {}) {
    const response = await fetch(`${this.baseUrl}/batch_extract`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ texts, ...options })
    });
    
    if (!response.ok) {
      throw new Error(`Batch extraction failed: ${response.statusText}`);
    }
    
    return await response.json();
  }
  
  async sacredGeometryAnalysis(text, options = {}) {
    const response = await fetch(`${this.baseUrl}/sacred_geometry_analysis`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ text, ...options })
    });
    
    if (!response.ok) {
      throw new Error(`Sacred geometry analysis failed: ${response.statusText}`);
    }
    
    return await response.json();
  }
  
  async universalConsistencyCheck(text, options = {}) {
    const response = await fetch(`${this.baseUrl}/universal_consistency_check`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ text, ...options })
    });
    
    if (!response.ok) {
      throw new Error(`Consistency check failed: ${response.statusText}`);
    }
    
    return await response.json();
  }
  
  // Sacred geometry utilities (same calculations as Ruby core)
  calculateGoldenRatio(complexity = 2.618, efficiency = 1.618) {
    return complexity / efficiency;
  }
  
  calculateVortexEnergy(text) {
    // Same calculation as Ruby core
    const baseEnergy = text.length * 0.1;
    let patternMultiplier = 1.0;
    
    // Increase energy for each pattern found
    const links = this.extractLinks(text);
    const emails = this.extractEmails(text);
    const hashtags = this.extractHashtags(text);
    const mentions = this.extractMentions(text);
    
    patternMultiplier += links.length * 0.5;
    patternMultiplier += emails.length * 0.3;
    patternMultiplier += hashtags.length * 0.2;
    patternMultiplier += mentions.length * 0.2;
    
    const VORTEX_CONSTANT = 2.665144142690225;
    return baseEnergy * patternMultiplier * VORTEX_CONSTANT;
  }
  
  calculateFlowEfficiency(text) {
    const patterns = this.extractAllPatterns(text);
    const totalPatterns = Object.values(patterns).flat().length;
    
    // Efficiency decreases with complexity but increases with golden ratio compliance
    const complexityFactor = 1.0 / (1.0 + totalPatterns * 0.1);
    const goldenRatioFactor = this.calculateGoldenRatioCompliance(text);
    
    return (complexityFactor + goldenRatioFactor) / 2.0;
  }
  
  calculateSacredBalance(text) {
    // Balance between complexity and efficiency
    const complexity = text.length * 0.01;
    const efficiency = this.calculateFlowEfficiency(text);
    
    // Optimal balance is when complexity/efficiency approaches golden ratio
    const balanceRatio = complexity / efficiency;
    const optimalRatio = 1.618033988749895;
    
    // Score based on how close we are to optimal ratio
    return 1.0 - Math.abs(balanceRatio - optimalRatio) / optimalRatio;
  }
  
  calculateGoldenRatioCompliance(text) {
    // Calculate how well the text follows golden ratio principles
    const patterns = this.extractAllPatterns(text);
    const totalPatterns = Object.values(patterns).flat().length;
    
    // Optimal pattern density follows golden ratio
    const optimalDensity = text.length / 1.618033988749895;
    const actualDensity = totalPatterns;
    
    const compliance = 1.0 - Math.abs(actualDensity - optimalDensity) / optimalDensity;
    return Math.min(compliance, 1.0); // Cap at 1.0
  }
  
  validateSacredGeometry(result) {
    const goldenRatio = result.goldenRatio;
    const vortexEnergy = result.vortexFlow.energy;
    
    return {
      isValid: goldenRatio >= 1.5 && goldenRatio <= 2.0,
      goldenRatioCompliance: goldenRatio / 1.618033988749895,
      vortexEnergyEfficiency: vortexEnergy / 8.472
    };
  }
  
  // Local pattern extraction (same as Ruby core)
  extractLinks(text) {
    return text.match(/https?:\/\/[^\s]+/g) || [];
  }
  
  extractEmails(text) {
    return text.match(/[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+/gi) || [];
  }
  
  extractPhones(text) {
    return text.match(/\+?1?\d{10,15}/g) || [];
  }
  
  extractHashtags(text) {
    return text.match(/#\w+/g) || [];
  }
  
  extractMentions(text) {
    return text.match(/@\w+/g) || [];
  }
  
  extractAllPatterns(text) {
    return {
      links: this.extractLinks(text),
      emails: this.extractEmails(text),
      phones: this.extractPhones(text),
      hashtags: this.extractHashtags(text),
      mentions: this.extractMentions(text)
    };
  }
  
  // Local processing (for offline use)
  processTextLocally(text, options = {}) {
    const patterns = this.extractAllPatterns(text);
    const goldenRatio = this.calculateGoldenRatio(options.complexity || 2.618, options.efficiency || 1.618);
    const vortexEnergy = this.calculateVortexEnergy(text);
    const flowEfficiency = this.calculateFlowEfficiency(text);
    const sacredBalance = this.calculateSacredBalance(text);
    const goldenRatioCompliance = this.calculateGoldenRatioCompliance(text);
    
    return {
      success: true,
      data: patterns,
      sacredGeometry: {
        goldenRatioCompliance: goldenRatioCompliance,
        fibonacciIndex: this.findFibonacciIndex(text.length),
        vortexConstantRatio: vortexEnergy / (text.length * 2.665144142690225),
        sacredBalanceScore: sacredBalance
      },
      vortexFlow: {
        energy: vortexEnergy,
        flowEfficiency: flowEfficiency,
        sacredBalance: sacredBalance
      },
      goldenRatio: goldenRatio,
      timestamp: Date.now(),
      input: text
    };
  }
  
  findFibonacciIndex(value) {
    const FIBONACCI_SEQUENCE = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144];
    return FIBONACCI_SEQUENCE.indexOf(value) || 
           FIBONACCI_SEQUENCE.findIndex(fib => fib >= value) || 
           0;
  }
  
  // Utility methods
  displayResults(result) {
    console.log("=== Sacred Geometry Extraction Results ===");
    console.log("Input:", result.input);
    console.log();
    console.log("Extracted Data:");
    Object.entries(result.data).forEach(([type, items]) => {
      if (items.length > 0) {
        console.log(`  ${type.charAt(0).toUpperCase() + type.slice(1)}:`, items.join(', '));
      }
    });
    console.log();
    console.log("Sacred Geometry Metrics:");
    console.log("  Golden Ratio:", result.goldenRatio);
    console.log("  Vortex Energy:", result.vortexFlow.energy);
    console.log("  Flow Efficiency:", result.vortexFlow.flowEfficiency);
    console.log("  Sacred Balance:", result.vortexFlow.sacredBalance);
  }
  
  generateReport(results) {
    if (Array.isArray(results)) {
      return this.generateBatchReport(results);
    } else {
      return this.generateSingleReport(results);
    }
  }
  
  generateSingleReport(result) {
    return {
      text: result.input,
      patterns: result.data,
      sacredGeometry: result.sacredGeometry,
      vortexFlow: result.vortexFlow,
      goldenRatio: result.goldenRatio,
      recommendations: this.generateRecommendations(result)
    };
  }
  
  generateBatchReport(results) {
    const avgGoldenRatio = results.reduce((sum, r) => sum + r.goldenRatio, 0) / results.length;
    const avgVortexEnergy = results.reduce((sum, r) => sum + r.vortexFlow.energy, 0) / results.length;
    const avgSacredBalance = results.reduce((sum, r) => sum + r.sacredGeometry.sacredBalanceScore, 0) / results.length;
    
    return {
      totalProcessed: results.length,
      averageGoldenRatio: avgGoldenRatio,
      averageVortexEnergy: avgVortexEnergy,
      averageSacredBalance: avgSacredBalance,
      bestSacredBalance: Math.max(...results.map(r => r.sacredGeometry.sacredBalanceScore)),
      worstSacredBalance: Math.min(...results.map(r => r.sacredGeometry.sacredBalanceScore))
    };
  }
  
  generateRecommendations(result) {
    const recommendations = [];
    
    const sacredBalance = result.sacredGeometry.sacredBalanceScore;
    const goldenRatioCompliance = result.sacredGeometry.goldenRatioCompliance;
    const vortexRatio = result.sacredGeometry.vortexConstantRatio;
    
    if (sacredBalance < 0.7) {
      recommendations.push("Consider optimizing text complexity for better sacred balance");
    }
    
    if (goldenRatioCompliance < 0.8) {
      recommendations.push("Text could benefit from golden ratio optimization");
    }
    
    if (vortexRatio < 0.6) {
      recommendations.push("Vortex energy flow could be improved");
    }
    
    if (recommendations.length === 0) {
      recommendations.push("Text demonstrates excellent sacred geometry compliance");
    }
    
    return recommendations;
  }
}

// Global instance
window.RichTextExtraction = new RichTextExtractionClient(); 