# MiniMax M2 Optimization Implementation Plan

**Created:** 2025-11-13  
**Updated:** 2025-11-15  
**Author:** MiniMax Agent  
**Objective:** Optimize OpenCode to use MiniMax M2 model with best speed and performance

## Current Analysis

### Configuration Gaps Identified
- **Basic Config Only**: Current `/home/hbohlen/dev/hbohlenOS/opencode.jsonc:89-98` has minimal setup
- **Missing Context Window Limits**: 204,800 tokens available but not configured
- **No Interleaved Thinking**: M2's advanced reasoning not enabled
- **No Streaming**: Missing real-time response capabilities
- **Basic Tool Configuration**: Tools enabled but not optimized for performance
- **No Performance Monitoring**: Missing benchmarking and testing setup

### Key Optimization Opportunities
1. **Context Window Optimization** (204,800 tokens available)
2. **Interleaved Thinking Configuration** for better reasoning
3. **Tool Use Performance Optimization** for agentic capabilities
4. **Streaming Configuration** for real-time responses
5. **Temperature/Sampling Optimization** for better quality/speed balance
6. **Provider Options Optimization** (timeout, retry, etc.)
7. **Model-Specific Performance Options** for MiniMax M2

## Implementation Plan

### Phase 1: Context Window and Basic Optimization (Tasks 1-3)

#### Task 1: Configure Context Window Limits (3 minutes)
**Objective:** Set optimal context window limits for OpenCode's context tracking

**Implementation:**
```jsonc
"models": {
  "MiniMax-M2": {
    "name": "MiniMax-M2",
    "limit": {
      "context": 204800,
      "output": 131072
    }
  }
}
```

#### Task 2: Enable Interleaved Thinking (4 minutes)
**Objective:** Configure M2's native Interleaved Thinking for better reasoning

**Implementation:**
```jsonc
"agent": {
  "build": {
    "mode": "primary",
    "model": "minimax/MiniMax-M2",
    "reasoning": {
      "enabled": true,
      "format": "interleaved",
      "persist": true
    }
  }
}
```

#### Task 3: Optimize Temperature and Sampling Parameters (2 minutes)
**Objective:** Set optimal temperature and sampling for coding tasks

**Implementation:**
```jsonc
"options": {
  "max_tokens": 16384,
  "temperature": 0.7,        // Optimal for coding tasks
  "top_p": 0.9,              // Good quality/speed balance
  "reasoning_split": true    // Enable thinking separation
}
```

### Phase 2: Streaming and Performance Optimization (Tasks 4-6)

#### Task 4: Configure Streaming Responses (3 minutes)
**Objective:** Enable streaming for real-time response capabilities

**Implementation:**
```jsonc
"agent": {
  "build": {
    "streaming": {
      "enabled": true,
      "thinking_stream": true,
      "text_stream": true,
      "chunk_size": 100
    }
  }
}
```

#### Task 5: Optimize Provider Configuration (4 minutes)
**Objective:** Add performance optimizations to provider settings

#### Task 6: Configure Agent-Specific Tool Optimization (3 minutes)
**Objective:** Optimize tool use performance for coding tasks

### Phase 3: Performance Testing and Validation (Tasks 7-8)

#### Task 7: Create Performance Testing Suite (5 minutes)
**Objective:** Set up benchmarking and performance monitoring

#### Task 8: Run Performance Validation (4 minutes)
**Objective:** Execute tests and validate optimization performance

### Phase 4: Anthropic SDK Configuration (Task 9)

#### Task 9: Configure Anthropic SDK Optimization (3 minutes)
**Objective:** Add Anthropic-specific optimizations for M2

## Expected Performance Improvements

### Before Optimization
- Context tracking: None
- Reasoning: Basic completion only
- Streaming: Not available
- Tool use: Standard performance
- Provider options: Basic timeout only

### After Optimization
- **Context Window**: Full 204,800 token utilization with tracking
- **Reasoning**: Interleaved thinking for better multi-turn reasoning
- **Streaming**: Real-time thinking and text streaming
- **Performance**: Optimized timeouts, retries, and HTTP/2
- **Tool Use**: Enhanced caching, async operations, and specific timeouts
- **Monitoring**: Performance benchmarking and validation

## Success Criteria

✅ **Context Window**: 204,800 tokens properly configured and tracked  
✅ **Interleaved Thinking**: Enabled with reasoning persistence  
✅ **Streaming**: Both thinking and text streaming working  
✅ **Performance**: All benchmarks pass with target metrics  
✅ **Tool Optimization**: Enhanced configuration for coding tasks  
✅ **Provider Options**: Full performance optimization configured  
✅ **Testing**: Comprehensive validation suite operational  

---

**Related Documents:**
- [Master Project Plans](../00_MASTER_PROJECT_PLANS.md)