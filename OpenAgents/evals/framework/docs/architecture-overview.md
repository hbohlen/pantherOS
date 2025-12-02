# Eval System Architecture Overview

## Introduction

The OpenCode Evaluation Framework is a comprehensive system for testing and validating agent behavior. It captures real-time execution data, builds temporal timelines, and applies multiple evaluators to assess agent compliance with defined standards.

## System Architecture

The evaluation system consists of four main layers:

1. **Test Execution Layer** - Manages test case execution and event capture
2. **Data Collection Layer** - Captures and processes session events
3. **Timeline Building Layer** - Constructs temporal event sequences
4. **Evaluation Layer** - Applies behavioral checks and scoring

## Message Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           TEST EXECUTION FLOW                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. TestRunner.runTest(testCase)                                            │
│     │                                                                        │
│     ├─► EventStreamHandler.startListening()  ──► Captures all ServerEvents  │
│     │                                                                        │
│     ├─► ClientManager.createSession()                                       │
│     │                                                                        │
│     ├─► ClientManager.sendPrompt()  ──► Agent executes                      │
│     │                                                                        │
│     ├─► Events collected: session.*, message.*, part.*, permission.*        │
│     │                                                                        │
│     └─► EvaluatorRunner.runAll(sessionId)                                   │
│         │                                                                    │
│         ├─► SessionReader.getMessages()  ──► Gets messages via SDK          │
│         │                                                                    │
│         ├─► TimelineBuilder.buildTimeline()  ──► Creates TimelineEvent[]    │
│         │                                                                    │
│         └─► Each Evaluator.evaluate(timeline, sessionInfo)                  │
│             ├─► BehaviorEvaluator                                           │
│             ├─► ApprovalGateEvaluator                                       │
│             ├─► ContextLoadingEvaluator                                     │
│             ├─► DelegationEvaluator                                         │
│             └─► ToolUsageEvaluator                                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Test Execution Layer

#### TestRunner
- **Purpose**: Orchestrates test case execution
- **Key Methods**:
  - `runTest(testCase)` - Executes a single test case
  - `runAll(testCases)` - Runs multiple test cases in sequence
  - `loadTestCases(path)` - Loads YAML test definitions
- **Responsibilities**:
  - Initialize client session
  - Send user prompts
  - Coordinate event capture
  - Invoke evaluators
  - Generate results

#### EventStreamHandler
- **Purpose**: Captures real-time server events during execution
- **Event Types Captured**:
  - `session.*` - Session lifecycle events
  - `message.*` - Message creation and completion
  - `part.*` - Message parts (text, tool use, etc.)
  - `permission.*` - Approval requests and responses
- **Output**: Raw event stream for timeline construction

#### ClientManager
- **Purpose**: Manages OpenCode client lifecycle
- **Key Methods**:
  - `createSession()` - Initialize new test session
  - `sendPrompt(message)` - Send user message to agent
  - `waitForCompletion()` - Wait for agent response
- **Integration**: Uses OpenCode SDK for client operations

### 2. Data Collection Layer

#### SessionReader
- **Purpose**: Reads session data from OpenCode storage
- **Storage Location**: `~/.local/share/opencode/`
- **Key Methods**:
  - `getSessionInfo(sessionId)` - Retrieve session metadata
  - `getMessages(sessionId)` - Get all messages in session
  - `getParts(sessionId, messageId)` - Get message parts
- **Data Sources**:
  - `session.json` - Session metadata
  - `messages.jsonl` - Message stream
  - `parts/` - Message part files

#### MessageParser
- **Purpose**: Extract structured data from messages
- **Parsing Operations**:
  - Agent identification (openagent, subagent, etc.)
  - Model selection tracking
  - Token usage and cost metrics
  - Timing information
- **Output**: Normalized message objects

### 3. Timeline Building Layer

#### TimelineBuilder
- **Purpose**: Construct temporal event sequences from session data
- **Algorithm**:
  1. Read all messages via SessionReader
  2. Parse each message for events (tool calls, approvals, etc.)
  3. Sort events chronologically by timestamp
  4. Enrich events with context (agent, model, metrics)
- **Event Types**:
  - `user_message` - User prompts
  - `assistant_message` - Agent responses
  - `tool_call` - Tool invocations
  - `patch` - Code edits
  - `approval_request` - Permission requests
  - `approval_response` - User approval/denial
- **Output**: `TimelineEvent[]` - Ordered sequence of events

### 4. Evaluation Layer

#### EvaluatorRunner
- **Purpose**: Coordinate execution of all evaluators
- **Process**:
  1. Receive sessionId and timeline
  2. Instantiate all registered evaluators
  3. Execute each evaluator's `evaluate()` method
  4. Aggregate results and calculate overall score
- **Output**: `TestResult` with all evaluation results

#### Individual Evaluators

##### BehaviorEvaluator
- **Checks**: General behavioral compliance
- **Rules**:
  - Context file loading before execution
  - Proper scratchpad usage
  - Adherence to agent-specific rules

##### ApprovalGateEvaluator
- **Checks**: Approval gate compliance
- **Rules**:
  - Request approval before bash, write, edit, task
  - No execution without approval
  - Proper approval handling

##### ContextLoadingEvaluator
- **Checks**: Context file loading
- **Rules**:
  - Load docs.md before documentation tasks
  - Load tests.md before testing tasks
  - Load relevant context before specialized tasks

##### DelegationEvaluator
- **Checks**: Task delegation decisions
- **Rules**:
  - Delegate when 4+ files involved
  - Delegate complex multi-step tasks
  - Use appropriate subagent types

##### ToolUsageEvaluator
- **Checks**: Tool selection appropriateness
- **Rules**:
  - Use Read instead of bash cat
  - Use Task for exploration
  - Prefer specialized tools over bash

## Data Flow

### Phase 1: Test Execution
```
Test YAML → TestRunner → ClientManager → Agent Execution
                ↓
         EventStreamHandler
                ↓
         Event Collection
```

### Phase 2: Data Collection
```
SessionReader → ~/.local/share/opencode/
     ↓
Message Parsing → MessageParser
     ↓
Structured Data
```

### Phase 3: Timeline Construction
```
Messages + Events → TimelineBuilder
     ↓
Chronological Sorting
     ↓
Event Enrichment
     ↓
TimelineEvent[]
```

### Phase 4: Evaluation
```
Timeline → EvaluatorRunner
     ↓
BehaviorEvaluator ──┐
ApprovalGateEvaluator ──┤
ContextLoadingEvaluator ──┤→ Results Aggregation
DelegationEvaluator ──┤
ToolUsageEvaluator ──┘
     ↓
TestResult
```

## Key Design Principles

### 1. Event-Driven Architecture
- All agent actions captured as events
- Events stored in chronological order
- Evaluators work with event timeline, not raw data

### 2. Separation of Concerns
- **Collection** - Gather data without interpretation
- **Transformation** - Build timeline from raw events
- **Evaluation** - Apply business rules to timeline

### 3. Extensibility
- New evaluators implement `BaseEvaluator` interface
- Evaluators registered in config
- No changes to collection/timeline layers needed

### 4. Reproducibility
- All session data persisted
- Tests can be re-evaluated without re-execution
- Historical analysis of past sessions

### 5. Composability
- Evaluators run independently
- Results aggregated into overall score
- Individual evaluator results available

## Event Schema

### TimelineEvent
```typescript
interface TimelineEvent {
  timestamp: number;        // Unix timestamp in ms
  type: EventType;          // Event category
  agent?: string;           // Agent that generated event
  model?: string;           // Model used
  data: EventData;          // Event-specific payload
}

type EventType = 
  | 'user_message'
  | 'assistant_message'
  | 'tool_call'
  | 'patch'
  | 'approval_request'
  | 'approval_response';
```

### Tool Call Event
```typescript
interface ToolCallEvent {
  timestamp: number;
  type: 'tool_call';
  data: {
    tool: string;           // Tool name (e.g., 'read', 'bash')
    parameters: any;        // Tool parameters
    result?: any;           // Tool result (if available)
  };
}
```

### Approval Event
```typescript
interface ApprovalRequestEvent {
  timestamp: number;
  type: 'approval_request';
  data: {
    tool: string;           // Tool requiring approval
    parameters: any;        // Parameters for review
  };
}

interface ApprovalResponseEvent {
  timestamp: number;
  type: 'approval_response';
  data: {
    approved: boolean;      // User decision
    requestTimestamp: number; // Link to request
  };
}
```

## Evaluation Scoring

### Weighted Checks
Each evaluator defines weighted checks:
```typescript
const checks = [
  { name: 'approval_before_bash', passed: true, weight: 30 },
  { name: 'approval_before_write', passed: true, weight: 30 },
  { name: 'no_unapproved_execution', passed: false, weight: 40 }
];
```

### Score Calculation
```typescript
const totalWeight = sum(checks.map(c => c.weight));
const achievedWeight = sum(checks.filter(c => c.passed).map(c => c.weight));
const score = (achievedWeight / totalWeight) * 100;
```

### Overall Test Score
```typescript
const evaluatorScores = evaluationResults.map(r => r.score);
const overallScore = average(evaluatorScores);
const passed = overallScore >= passThreshold; // Default: 75
```

## Storage Structure

```
~/.local/share/opencode/
└── sessions/
    └── {sessionId}/
        ├── session.json      # Session metadata
        ├── messages.jsonl    # Message stream
        └── parts/            # Message parts
            ├── {partId}.txt
            └── {partId}.json
```

## Configuration

### Evaluator Registration
```typescript
// config.ts
export const config = {
  evaluators: {
    'behavior': BehaviorEvaluator,
    'approval-gate': ApprovalGateEvaluator,
    'context-loading': ContextLoadingEvaluator,
    'delegation': DelegationEvaluator,
    'tool-usage': ToolUsageEvaluator,
  },
  passThreshold: 75,
};
```

### Test Configuration
```yaml
# test-case.yaml
id: test-001
description: Test approval gates
prompt: "Create a new file called test.js"
expected:
  behavior:
    - approval_requested
    - no_unapproved_execution
evaluators:
  - approval-gate
  - tool-usage
```

## Error Handling

### Collection Errors
- **Session not found**: Return empty timeline, mark test as skipped
- **Malformed messages**: Log warning, skip message, continue
- **Missing parts**: Use partial data, note in metadata

### Evaluation Errors
- **Evaluator exception**: Mark evaluator as failed, continue with others
- **Missing required data**: Return 0 score with violation
- **Timeout**: Kill evaluator, mark as error

## Performance Considerations

### Timeline Building
- **Lazy loading**: Only load messages when needed
- **Caching**: Cache parsed messages within session
- **Streaming**: Process messages as stream, not all at once

### Evaluation
- **Parallel execution**: Run independent evaluators concurrently
- **Early termination**: Stop if critical failures detected
- **Incremental scoring**: Calculate scores progressively

## Future Enhancements

1. **Real-time Evaluation**
   - Evaluate as events occur, not post-execution
   - Provide live feedback during test execution

2. **Comparative Analysis**
   - Compare results across test runs
   - Track improvement over time
   - Identify regression patterns

3. **Smart Approval**
   - Auto-approve safe operations based on learned patterns
   - Reduce test execution time

4. **Visual Timeline**
   - Interactive timeline visualization
   - Filter events by type/agent/tool
   - Drill down into specific interactions

5. **Custom Evaluators**
   - User-defined evaluation rules
   - Domain-specific checks
   - Plugin architecture

## Related Documentation

- [Test Design Guide](./test-design-guide.md) - How to write effective tests
- [SDK Evaluation README](../SDK_EVAL_README.md) - SDK-based evaluation approach
- [Agent Testing Guide](../../agents/AGENT_TESTING_GUIDE.md) - Testing specific agents

## Summary

The evaluation framework provides a robust, extensible system for validating agent behavior. By capturing real-time events, building temporal timelines, and applying multiple independent evaluators, it ensures comprehensive testing while maintaining clarity and debuggability.

Key strengths:
- **Separation of concerns** between collection, transformation, and evaluation
- **Event-driven** architecture for accurate temporal analysis
- **Extensible** evaluator system for custom checks
- **Reproducible** results through persisted session data
- **Composable** scoring from independent evaluators
