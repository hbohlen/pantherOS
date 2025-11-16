import { enhanceSkillWithMemory, AgentDBPlugin } from '/root/pantherOS/.opencode/plugin/agentdb/index.js';

export const SystematicDebuggingSkill = {
  name: 'systematic-debugging',
  version: '1.0.0',
  description: 'Enhanced debugging with AgentDB pattern learning and sub-millisecond retrieval',
  category: 'debugging',
  tags: ['debug', 'patterns', 'learning', 'memory'],
  
  // Skill configuration
  config: {
    memory: {
      agentdb: true,
      focus: ['debugging_patterns', 'solution_strategies'],
      sharing: ['writing-plans', 'root-cause-tracing']
    },
    analysisDepth: 'deep',
    patternMatching: true,
    learningEnabled: true
  },

  // Main execution method
  async execute(context) {
    const startTime = Date.now();
    console.log(`Starting systematic debugging for: ${context.currentTask}`);
    
    try {
      // 1. Enhanced debugging analysis with AgentDB integration
      const debugResult = await this.performDebuggingAnalysis(context);
      
      // 2. Pattern learning integration
      const patterns = await AgentDBPlugin.queryVector('patterns', context.currentTask, 0.8, 10);
      
      // 3. Cross-session learning integration
      if (context.sessionId) {
        await AgentDBPlugin.storeSession({
          id: context.sessionId,
          agentType: 'systematic-debugging',
          context: context.currentTask,
          outcomes: debugResult,
          learningData: {
            patternsFound: patterns.length,
            analysisTime: Date.now() - startTime,
            success: debugResult.success
          }
        });
      }

      // 4. Causal relationship tracking
      if (debugResult.causes && debugResult.causes.length > 0) {
        await AgentDBPlugin.storeCausalEdge({
          causePattern: debugResult.problemPattern,
          effectPattern: debugResult.solution,
          confidence: debugResult.confidence || 0.8,
          evidenceCount: debugResult.evidenceCount || 1
        });
      }

      const totalTime = Date.now() - startTime;
      console.log(`Systematic debugging completed in ${totalTime}ms`);

      return {
        ...debugResult,
        metadata: {
          executionTime: totalTime,
          patterns: {
            found: patterns.length,
            similarities: patterns.map(p => p.similarity)
          },
          memory: {
            sessionStored: !!context.sessionId,
            causalEdgesStored: debugResult.causes ? debugResult.causes.length : 0
          }
        }
      };
    } catch (error) {
      console.error('Systematic debugging failed:', error);
      return {
        success: false,
        error: error.message,
        executionTime: Date.now() - startTime
      };
    }
  },

  // Core debugging analysis method
  async performDebuggingAnalysis(context) {
    const { currentTask, code, error, environment } = context;

    // 1. Problem pattern identification
    const problemPattern = this.identifyProblemPattern(error, code);
    
    // 2. Query historical debugging patterns
    const similarPatterns = await AgentDBPlugin.queryVector('patterns', problemPattern, 0.7, 5);
    
    // 3. Generate debugging steps
    const debugSteps = await this.generateDebugSteps(problemPattern, similarPatterns);
    
    // 4. Solution validation
    const solution = await this.validateSolution(debugSteps, environment);
    
    // 5. Root cause analysis
    const rootCauses = await this.performRootCauseAnalysis(problemPattern, debugSteps);

    return {
      success: solution.valid,
      problemPattern,
      debugSteps,
      solution,
      rootCauses,
      confidence: this.calculateConfidence(similarPatterns, rootCauses),
      evidenceCount: similarPatterns.length
    };
  },

  // Problem pattern identification using AI/ML patterns
  identifyProblemPattern(error, code) {
    // Enhanced pattern recognition
    const patterns = {
      nullReference: /null.*reference|cannot read property/i,
      typeError: /typeerror|undefined is not a function/i,
      syntaxError: /syntaxerror|unexpected token/i,
      networkError: /network|fetch|request failed/i,
      memoryError: /memory|out of stack|heap/i
    };

    for (const [patternName, regex] of Object.entries(patterns)) {
      if (regex.test(error?.message || '')) {
        return `error_pattern_${patternName}`;
      }
    }

    return 'error_pattern_unknown';
  },

  // Generate debugging steps using pattern matching
  async generateDebugSteps(problemPattern, similarPatterns) {
    const steps = [];
    
    // Base debugging steps
    steps.push({
      step: 1,
      action: 'isolate_problem',
      description: 'Isolate the problematic code section',
      techniques: ['divide_and_conquer', 'binary_search', 'rollback_testing']
    });

    steps.push({
      step: 2,
      action: 'gather_evidence',
      description: 'Collect debugging information',
      techniques: ['logging', 'stack_traces', 'variable_inspection']
    });

    // Enhanced steps based on historical patterns
    for (const pattern of similarPatterns) {
      if (pattern.similarity > 0.8) {
        steps.push({
          step: steps.length + 1,
          action: 'pattern_based_solution',
          description: `Apply solution from similar pattern: ${pattern.id}`,
          technique: pattern.pattern_data.solution,
          confidence: pattern.success_rate
        });
      }
    }

    steps.push({
      step: steps.length + 1,
      action: 'validate_solution',
      description: 'Test and validate the solution',
      techniques: ['unit_tests', 'integration_tests', 'manual_verification']
    });

    return steps;
  },

  // Validate solution against environment
  async validateSolution(debugSteps, environment) {
    const validation = {
      valid: false,
      tests: [],
      confidence: 0
    };

    for (const step of debugSteps) {
      const test = await this.runValidationTest(step, environment);
      validation.tests.push(test);
      
      if (test.passed) {
        validation.confidence += test.confidence;
      }
    }

    validation.valid = validation.confidence > 0.7;
    validation.confidence = Math.min(validation.confidence / debugSteps.length, 1.0);

    return validation;
  },

  // Run individual validation tests
  async runValidationTest(step, environment) {
    // Mock validation - in real implementation, this would run actual tests
    const passed = Math.random() > 0.2; // 80% pass rate for demo
    const confidence = passed ? 0.9 : 0.3;
    
    return {
      step: step.step,
      action: step.action,
      passed,
      confidence,
      message: passed ? 'Test passed successfully' : 'Test failed - needs investigation'
    };
  },

  // Perform root cause analysis
  async performRootCauseAnalysis(problemPattern, debugSteps) {
    const rootCauses = [];
    
    // Analyze problem pattern for root causes
    const causes = await this.analyzeRootCauses(problemPattern, debugSteps);
    rootCauses.push(...causes);

    // Query causal relationships from AgentDB
    const causalEdges = await AgentDBPlugin.queryVector('causal_edges', problemPattern, 0.6, 5);
    for (const edge of causalEdges) {
      rootCauses.push({
        cause: edge.cause_pattern,
        effect: edge.effect_pattern,
        confidence: edge.confidence,
        evidence: edge.evidence_count
      });
    }

    return rootCauses;
  },

  // Analyze specific root causes
  async analyzeRootCauses(problemPattern, debugSteps) {
    const causes = [];
    
    // Pattern-based root cause analysis
    const rootCauseAnalysis = {
      'error_pattern_nullReference': [
        'Uninitialized variables',
        'Missing null checks',
        'API response format changes'
      ],
      'error_pattern_typeError': [
        'Type mismatches',
        'Missing method implementations',
        'Version incompatibilities'
      ],
      'error_pattern_syntaxError': [
        'Missing semicolons',
        'Incorrect syntax',
        'File encoding issues'
      ]
    };

    const potentialCauses = rootCauseAnalysis[problemPattern] || ['Unknown cause'];
    
    for (const cause of potentialCauses) {
      causes.push({
        cause,
        confidence: 0.7,
        evidence: 'Pattern-based analysis'
      });
    }

    return causes;
  },

  // Calculate confidence score based on patterns and evidence
  calculateConfidence(similarPatterns, rootCauses) {
    let confidence = 0.5; // Base confidence
    
    // Boost confidence if similar patterns found
    if (similarPatterns.length > 0) {
      const avgSimilarity = similarPatterns.reduce((sum, p) => sum + p.similarity, 0) / similarPatterns.length;
      confidence += avgSimilarity * 0.3;
    }
    
    // Boost confidence if multiple root causes identified
    confidence += Math.min(rootCauses.length * 0.1, 0.3);
    
    return Math.min(confidence, 1.0);
  },

  // Helper method to merge patterns with context
  mergePatterns(patterns, context) {
    return {
      ...context,
      patterns,
      enhanced: true,
      patternCount: patterns.length
    };
  }
};

// Export enhanced version with AgentDB integration
export const EnhancedSystematicDebuggingSkill = enhanceSkillWithMemory(SystematicDebuggingSkill);

export default EnhancedSystematicDebuggingSkill;