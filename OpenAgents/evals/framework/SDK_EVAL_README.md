# OpenCode SDK Evaluation Framework

End-to-end testing framework for OpenCode agents using real SDK execution.

## Quick Start

```bash
# Install dependencies
cd evals/framework
npm install

# Run all tests with free model (no API costs)
npm run eval:sdk

# Run with debug output
npm run eval:sdk -- --debug

# Run without evaluators (faster)
npm run eval:sdk -- --no-evaluators
```

## Model Configuration

### Using Free Models (Recommended for Development)

The framework defaults to **OpenCode Zen's free tier** to avoid API costs during development:

```bash
# Default: Uses opencode/grok-code-fast (free)
npm run eval:sdk
```

### Using Paid Models

Override the model for production evaluation:

```bash
# Use Claude 3.5 Sonnet
npm run eval:sdk -- --model=anthropic/claude-3-5-sonnet-20241022

# Use GPT-4 Turbo
npm run eval:sdk -- --model=openai/gpt-4-turbo
```

### Per-Test Model Override

Test cases can specify their own model in the YAML file:

```yaml
id: my-test-001
name: My Test
# ... other fields ...
model: anthropic/claude-3-5-sonnet-20241022  # Override default
```

## Available Models

### Free Tier (OpenCode Zen)
- `opencode/grok-code-fast` - **FREE** - Grok Code Fast model
  - Cost: $0.00 input, $0.00 output
  - Good for: Development, testing, rapid iteration
  - **Default model**

### Paid Tiers
- `anthropic/claude-3-5-sonnet-20241022` - Claude 3.5 Sonnet
  - Best for: Complex reasoning, code generation
  
- `openai/gpt-4-turbo` - GPT-4 Turbo
  - Best for: General purpose tasks

See [OpenCode Zen docs](https://opencode.ai/zen) for full model list.

## CLI Options

```bash
npm run eval:sdk -- [options]

Options:
  --debug                    Enable verbose logging
  --no-evaluators           Skip running evaluators (faster testing)
  --model=<provider/model>  Override default model
  --pattern=<glob>          Run specific test files
  --timeout=<ms>            Test timeout (default: 60000)

Examples:
  npm run eval:sdk -- --debug
  npm run eval:sdk -- --model=anthropic/claude-3-5-sonnet-20241022
  npm run eval:sdk -- --pattern="developer/*.yaml"
  npm run eval:sdk -- --pattern="edge-case/*.yaml" --no-evaluators
```

## Test Case Structure

Create test cases in `evals/opencode/openagent/sdk-tests/`:

```yaml
id: my-test-001
name: My Test Case
description: What this test does
category: developer  # or business, creative, edge-case

prompt: |
  Your test prompt here

# Optional: Override default model for this test
model: anthropic/claude-3-5-sonnet-20241022

approvalStrategy:
  type: auto-approve  # or auto-deny, smart

expected:
  pass: true
  minMessages: 2
  toolCalls:
    - bash
    - write
  
timeout: 60000
tags:
  - approval-gate
  - file-creation
```

## Approval Strategies

### Auto-Approve
Automatically approves all permission requests:

```yaml
approvalStrategy:
  type: auto-approve
```

### Auto-Deny
Automatically denies all permission requests (for testing approval gates):

```yaml
approvalStrategy:
  type: auto-deny
```

### Smart Strategy
Rule-based approval with fine-grained control:

```yaml
approvalStrategy:
  type: smart
  config:
    allowedTools:
      - bash
      - read
    deniedTools:
      - write
      - edit
    maxApprovals: 5
    defaultDecision: true
```

## Evaluators

The framework runs 4 evaluators on recorded sessions:

1. **ApprovalGateEvaluator** - Ensures approval before tool execution
2. **ContextLoadingEvaluator** - Verifies context files loaded first
3. **DelegationEvaluator** - Validates delegation for 4+ files
4. **ToolUsageEvaluator** - Checks for bash anti-patterns

Disable evaluators for faster iteration:

```bash
npm run eval:sdk -- --no-evaluators
```

## Test Results

After running tests, you'll see a summary:

```
======================================================================
TEST RESULTS
======================================================================

1. ✅ dev-install-deps-001 - Install Dependencies
   Duration: 17148ms
   Events: 36
   Approvals: 0

2. ❌ biz-data-analysis-001 - Business Data Analysis
   Duration: 17512ms
   Events: 18
   Approvals: 0
   Errors:
     - Expected at least 2 messages, got 1

======================================================================
SUMMARY: 1/2 tests passed (1 failed)
======================================================================
```

## Directory Structure

```
evals/framework/
├── src/sdk/
│   ├── server-manager.ts       # Start/stop opencode server
│   ├── client-manager.ts       # SDK wrapper
│   ├── event-stream-handler.ts # Event streaming
│   ├── test-runner.ts          # Test orchestration
│   ├── test-case-schema.ts     # Zod schema
│   ├── test-case-loader.ts     # YAML loader
│   ├── run-sdk-tests.ts        # CLI entry point
│   └── approval/
│       ├── auto-approve-strategy.ts
│       ├── auto-deny-strategy.ts
│       └── smart-approval-strategy.ts
│
evals/opencode/openagent/sdk-tests/
├── developer/
│   ├── install-dependencies.yaml
│   └── create-component.yaml
├── business/
│   └── data-analysis.yaml
├── creative/
└── edge-case/
    └── just-do-it.yaml
```

## Cost Management

### Development (Free)
Use the default free model for all development and testing:

```bash
# No costs - uses opencode/grok-code-fast
npm run eval:sdk
```

### Production (Paid)
Switch to paid models only when running production evaluations:

```bash
# Use Claude for final evaluation
npm run eval:sdk -- --model=anthropic/claude-3-5-sonnet-20241022
```

### Per-Test Basis
Some tests might need specific models. Set them in the YAML:

```yaml
# expensive-test.yaml
model: anthropic/claude-3-5-sonnet-20241022  # Only this test uses Claude

# cheap-test.yaml
# Uses default free model
```

## Troubleshooting

### "Session not found" error with evaluators
Sessions need time to be written to disk. Try running without evaluators first:

```bash
npm run eval:sdk -- --no-evaluators
```

### Tests timing out
Increase the timeout:

```bash
npm run eval:sdk -- --timeout=120000  # 2 minutes
```

### Model authentication errors
Ensure you're authenticated with the provider:

```bash
opencode auth login
# Select provider and enter API key
```

For free OpenCode Zen models, sign up at [opencode.ai/auth](https://opencode.ai/auth).

## Next Steps

1. **Add More Tests** - Create test cases in `sdk-tests/`
2. **CI Integration** - Add to GitHub Actions workflow
3. **Custom Evaluators** - Extend the evaluation framework
4. **HTML Reports** - Generate visual test reports

## Contributing

When adding new test cases:

1. Place in appropriate category directory
2. Use descriptive IDs (`category-name-001`)
3. Add clear descriptions and expected results
4. Test with free model first
5. Document any model-specific requirements
