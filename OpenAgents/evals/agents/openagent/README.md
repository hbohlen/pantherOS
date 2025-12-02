# OpenAgent Test Suite

Comprehensive test suite for OpenAgent with focus on context loading, approval workflows, and multi-turn conversations.

---

## 📊 Test Coverage

**Total Tests**: 22  
**Pass Rate**: 100% ✅  
**Last Updated**: 2025-11-26

### Test Categories

| Category | Tests | Status | Description |
|----------|-------|--------|-------------|
| **context-loading** | 5 | ✅ 100% | Context file loading validation |
| **developer** | 12 | ✅ 100% | Developer workflow tests |
| **business** | 2 | ✅ 100% | Business analysis tests |
| **edge-case** | 3 | ✅ 100% | Edge cases and error handling |

---

## 🎯 Context Loading Tests (NEW)

### Overview

5 comprehensive tests validating that OpenAgent loads context files before execution:

| Test | Type | Duration | Status |
|------|------|----------|--------|
| ctx-simple-testing-approach | Simple | ~38s | ✅ PASS |
| ctx-simple-documentation-format | Simple | ~26s | ✅ PASS |
| ctx-simple-coding-standards | Simple | ~21s | ✅ PASS |
| ctx-multi-standards-to-docs | Complex | ~116s | ✅ PASS |
| ctx-multi-error-handling-to-tests | Complex | ~148s | ✅ PASS |

**Total Duration**: ~6 minutes for all 5 tests  
**Pass Rate**: 100% (5/5)

### What They Test

#### Simple Tests (Read-Only)
1. **ctx-simple-coding-standards** - Asks about coding standards
   - Validates: Loads `code.md` before responding
   - Tools: `read`

2. **ctx-simple-documentation-format** - Asks about documentation format
   - Validates: Loads `docs.md` before responding
   - Tools: `read`

3. **ctx-simple-testing-approach** - Asks about testing strategy
   - Validates: Loads testing-related files before responding
   - Tools: `read` (multiple files)

#### Complex Tests (Multi-Turn with File Creation)
4. **ctx-multi-standards-to-docs** - Standards → Documentation creation
   - Turn 1: "What are our coding standards?"
   - Turn 2: "Create documentation about these standards"
   - Validates: Loads `code.md` + `docs.md` before writing
   - Tools: `read`, `write`

5. **ctx-multi-error-handling-to-tests** - Error handling → Test creation
   - Turn 1: "How should we handle errors?"
   - Turn 2: "Write tests for error handling"
   - Validates: Loads `code.md` + `tests.md` before writing
   - Tools: `read`, `write`, `grep`, `list`, `glob`

**See**: [CONTEXT_LOADING_COVERAGE.md](CONTEXT_LOADING_COVERAGE.md) for detailed documentation

---

## 🚀 Running Tests

### All OpenAgent Tests

```bash
cd evals/framework
npm run eval:sdk -- --agent=openagent
```

### Context Loading Tests Only

```bash
npm run eval:sdk -- --agent=openagent --pattern="context-loading/*.yaml"
```

### Specific Test

```bash
npm run eval:sdk -- --agent=openagent --pattern="context-loading/ctx-simple-coding-standards.yaml"
```

### Debug Mode

```bash
npm run eval:sdk -- --agent=openagent --pattern="context-loading/*.yaml" --debug
```

### Batch Execution (Avoid API Limits)

```bash
./scripts/utils/run-tests-batch.sh openagent 3 10
# Args: agent, batch_size, delay_seconds
```

---

## 📁 Test Structure

```
tests/
├── context-loading/              # Context loading tests (NEW)
│   ├── ctx-simple-coding-standards.yaml
│   ├── ctx-simple-documentation-format.yaml
│   ├── ctx-simple-testing-approach.yaml
│   ├── ctx-multi-standards-to-docs.yaml
│   └── ctx-multi-error-handling-to-tests.yaml
│
├── developer/                    # Developer workflow tests
│   ├── ctx-code-001.yaml        # Code task with context
│   ├── ctx-docs-001.yaml        # Docs task with context
│   ├── ctx-tests-001.yaml       # Tests task with context
│   ├── ctx-review-001.yaml      # Review task with context
│   ├── ctx-delegation-001.yaml  # Delegation task
│   ├── ctx-multi-turn-001.yaml  # Multi-turn conversation
│   ├── create-component.yaml    # Component creation
│   ├── install-dependencies.yaml
│   ├── install-dependencies-v2.yaml
│   ├── task-simple-001.yaml
│   └── fail-stop-001.yaml
│
├── business/                     # Business analysis tests
│   ├── conv-simple-001.yaml
│   └── data-analysis.yaml
│
└── edge-case/                    # Edge cases
    ├── just-do-it.yaml
    ├── missing-approval-negative.yaml
    └── no-approval-negative.yaml
```

---

## 🔧 Test Features

### Multi-Turn Support

OpenAgent tests use multi-turn prompts to simulate approval workflow:

```yaml
prompts:
  - text: "What are our coding standards?"
    expectContext: true
    contextFile: "standards.md"
  
  - text: "approve"
    delayMs: 2000
  
  - text: "Create documentation about these standards"
    expectContext: true
    contextFile: "docs.md"
```

### Smart Timeout

Complex tests use smart timeout system:
- **Base timeout**: 300s (5 min) of inactivity
- **Absolute max**: 600s (10 min) hard limit
- **Activity monitoring**: Extends timeout while agent is working

```yaml
timeout: 300000  # 5 minutes
```

### Context Validation

Tests verify context files are loaded before execution:

```yaml
behavior:
  mustUseTools: [read, write]
  requiresContext: true
  minToolCalls: 2

expectedViolations:
  - rule: context-loading
    shouldViolate: false
    severity: error
```

---

## 📊 Test Results

### Latest Run (2025-11-26)

```
======================================================================
SUMMARY: 5/5 context loading tests passed (0 failed)
======================================================================

✅ ctx-simple-testing-approach          (38s)
✅ ctx-simple-documentation-format      (26s)
✅ ctx-simple-coding-standards          (21s)
✅ ctx-multi-standards-to-docs         (116s)
✅ ctx-multi-error-handling-to-tests   (148s)

Total Duration: 349 seconds (~6 minutes)
Pass Rate: 100%
Violations: 0
```

### Context Loading Details

```
Context Loading:
  ✓ Loaded: .opencode/context/core/standards/code.md
  ✓ Timing: Context loaded 44317ms before execution
```

---

## 🎯 Key Achievements

### November 26, 2025

✅ **Context Loading Tests** - 5 comprehensive tests (3 simple, 2 complex)  
✅ **100% Pass Rate** - All tests passing  
✅ **Smart Timeout** - Handles complex multi-turn tests  
✅ **Fixed Evaluator** - Properly detects context files  
✅ **Cleanup System** - Auto-cleans test artifacts  
✅ **Documentation** - Complete coverage documentation

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [CONTEXT_LOADING_COVERAGE.md](CONTEXT_LOADING_COVERAGE.md) | Detailed context loading test documentation |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | Recent implementation details and fixes |
| [docs/OPENAGENT_RULES.md](docs/OPENAGENT_RULES.md) | OpenAgent rules reference |

---

## 🔍 Test Design

### Simple Test Example

```yaml
id: ctx-simple-coding-standards
name: "Context Loading: Coding Standards"
description: |
  Simple test: Ask about coding standards and verify agent loads context file.

category: developer
agent: openagent
model: anthropic/claude-sonnet-4-5

prompt: "What are our coding standards for this project?"

behavior:
  mustUseAnyOf: [[read]]
  requiresContext: true
  minToolCalls: 1

expectedViolations:
  - rule: context-loading
    shouldViolate: false
    severity: error

approvalStrategy:
  type: auto-approve

timeout: 60000

tags:
  - context-loading
  - simple-test
```

### Complex Test Example

```yaml
id: ctx-multi-standards-to-docs
name: "Context Loading: Multi-Turn Standards to Documentation"
description: |
  Complex multi-turn test: Standards question → Documentation request

category: developer
agent: openagent
model: anthropic/claude-sonnet-4-5

prompts:
  - text: "What are our coding standards?"
    expectContext: true
    contextFile: "standards.md"
  
  - text: "approve"
    delayMs: 2000
  
  - text: "Can you create documentation about these standards?"
    expectContext: true
    contextFile: "docs.md"
  
  - text: "approve"
    delayMs: 2000

behavior:
  mustUseTools: [read, write]
  requiresApproval: true
  requiresContext: true
  minToolCalls: 3

expectedViolations:
  - rule: approval-gate
    shouldViolate: false
    severity: error
  
  - rule: context-loading
    shouldViolate: false
    severity: error

approvalStrategy:
  type: auto-approve

timeout: 300000  # 5 minutes

tags:
  - context-loading
  - multi-turn
  - complex-test
```

---

## 🛠️ Troubleshooting

### Test Timeout

**Issue**: Test times out on complex multi-turn scenarios  
**Solution**: Increase timeout to 300000ms (5 minutes)

### Context Not Loaded

**Issue**: Evaluator reports "no context loaded"  
**Solution**: Ensure test uses multi-turn prompts with approval

### Files Not Cleaned Up

**Issue**: Test artifacts remain in test_tmp/  
**Solution**: Check cleanup logic in run-sdk-tests.ts

---

## 📈 Next Steps

1. **Add More Edge Cases**
   - Test with missing context files
   - Test with multiple context directories
   - Test with file attachments

2. **Performance Metrics**
   - Track context load time vs execution time
   - Measure API response times
   - Monitor rate limit usage

3. **Test Coverage Expansion**
   - Add tests for other agent behaviors
   - Test delegation scenarios
   - Test error handling paths

---

## 🤝 Contributing

To add new tests:

1. Create YAML file in appropriate category directory
2. Follow test schema (see examples above)
3. Run test to verify it works
4. Update this README if adding new category

---

**Last Updated**: 2025-11-26  
**Test Framework Version**: 0.1.0  
**OpenAgent Tests**: 22  
**Pass Rate**: 100%
