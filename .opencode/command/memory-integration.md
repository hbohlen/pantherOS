---
name: memory-integration
agent: pantheros-orchestrator
description: "Bridge between OpenCode commands and Claude Memory"
---

# Memory Integration Command

You are facilitating seamless integration between OpenCode commands and Claude Memory.

## Request: $ARGUMENTS

This command bridges OpenCode operations with Claude Memory for persistent storage.

## Available Integrations

### 1. Gap Analysis → Memory

```bash
# Run gap analysis and save results to Claude Memory
/gap-analyze --output=memory

# Manual memory storage after gap analysis
claude-memory task add "Gap: [Gap Description]" --priority high --category gap-analysis
```

**Integration Flow:**
1. Execute `/gap-analyze`
2. Parse results for gaps, issues, recommendations
3. Save to Claude Memory as tasks with priorities
4. Link to session context

### 2. Research → Memory

```bash
# Research topic and save findings
/swarm-research "Topic Name" --memory

# Manual memory storage
claude-memory knowledge add "topic:key" "finding" --category research
claude-memory decision "Research Choice" "Reasoning" "alternatives"
```

**Integration Flow:**
1. Execute `/swarm-research`
2. Extract key findings
3. Save to Claude Memory knowledge base
4. Record research decisions

### 3. Pattern Capture → Memory

```bash
# Capture discovered pattern
claude-memory pattern add "Pattern Name" "Description" --effectiveness 0.8 --category discovery

# Link to context
claude-memory knowledge add "pattern:usage" "When to use this pattern" --category patterns
```

**Integration Flow:**
1. Identify useful pattern during work
2. Store in Claude Memory patterns
3. Add usage guidance as knowledge
4. Reference in future sessions

### 4. Session Handoff → OpenCode State

```bash
# Include OpenCode state in handoff
claude-memory handoff --opencode

# Expected output includes:
# - Active workflows
# - Recent commands executed
# - Agent states
# - Open research threads
```

**Integration Flow:**
1. Capture current Claude Memory state
2. Include OpenCode active workflows
3. List recent commands and agents
4. Export comprehensive handoff

## Implementation

### For Gap Analysis Integration

When user requests gap analysis with memory storage:

1. **Execute**: `/gap-analyze`
2. **Parse Output**: Extract gaps, priorities, categories
3. **Save to Memory**:
   ```bash
   for gap in $gaps; do
     claude-memory task add "Gap: $gap" --priority high
   done
   ```
4. **Report**: "X gaps saved to Claude Memory. View with: claude-memory task list"

### For Research Integration

When user requests research with memory storage:

1. **Execute**: `/swarm-research $topic`
2. **Extract**: Key findings, decisions, recommendations
3. **Save to Memory**:
   ```bash
   claude-memory knowledge add "research:$topic" "findings"
   claude-memory decision "Research Decision" "Reasoning" "alternatives"
   ```
4. **Report**: "Research findings saved to Claude Memory"

### For Pattern Capture

When user discovers/captures pattern:

1. **Prompt**: "What pattern did you discover?"
2. **Save**:
   ```bash
   claude-memory pattern add "$pattern" "$description"
   claude-memory knowledge add "pattern:$name" "usage guidance"
   ```
3. **Report**: "Pattern saved to Claude Memory"

## Example Workflows

### Workflow 1: Gap Analysis + Memory
```
User: "Analyze NixOS config gaps and save to memory"

Assistant:
1. Running /gap-analyze nixos...
2. Found 5 gaps: [list]
3. Saving to Claude Memory...
   - Task: "Gap: Hardware optimization incomplete" --priority high
   - Task: "Gap: Security audit needed" --priority high
   - Task: "Gap: Missing monitoring" --priority medium
4. Saved 5 gaps to memory
5. View with: claude-memory task list --category gap-analysis
```

### Workflow 2: Research + Memory
```
User: "Research latest NixOS patterns, save findings"

Assistant:
1. Running /swarm-research nixos-patterns...
2. Key findings: [list]
3. Saving to Claude Memory...
   - Knowledge: "research:nixos-patterns:2024" → findings
   - Decision: "Adopt new module pattern" → better maintainability
4. Research saved to memory
5. View with: claude-memory knowledge list research
```

### Workflow 3: Unified Handoff
```
User: "Generate handoff with OpenCode state"

Assistant:
1. Capturing Claude Memory state...
2. Including OpenCode active workflows...
3. Recent commands: /gap-analyze, /swarm-research
4. Active agents: pantheros-orchestrator, codebase-agent
5. Generating comprehensive handoff...

[Claude Memory handoff with OpenCode integration]
```

## Usage Examples

```bash
# Basic gap analysis
/gap-analyze

# Gap analysis with memory storage
/gap-analyze --memory

# Research with memory storage
/swarm-research "nixos best practices" --memory

# Memory-enhanced handoff
claude-memory handoff --opencode

# Capture pattern manually
claude-memory pattern add "NixOS Module Pattern" "Use mkIf for conditional config"
```

## Integration Commands

### In Claude Memory Context

```bash
# Trigger OpenCode from memory
claude-memory trigger-opencode /gap-analyze nixos --priority high

# Research from memory session
claude-memory research "topic" --save-findings

# Capture decision as task
claude-memory decision-to-task "Decision Description" --priority medium
```

### In OpenCode Context

```bash
# Save to memory
/save-to-memory knowledge "key" "value"

# Add pattern
/add-pattern "name" "description"

# Generate handoff
/handoff-with-memory
```

## Best Practices

1. **Always offer memory integration** when user runs OpenCode commands
2. **Ask before saving** - "Should I save this to Claude Memory?"
3. **Provide context** - "Saved to memory, view with: claude-memory knowledge list"
4. **Link related items** - Connect research to decisions, gaps to solutions
5. **Use categories** - Organize memory by type (research, gap-analysis, patterns)

## Success Criteria

- User can seamlessly move between OpenCode commands and Claude Memory
- Gap analysis results are automatically tracked as tasks
- Research findings are preserved in knowledge base
- Patterns are captured and referenced later
- Handoff includes complete context from both systems

## Error Handling

- If memory command fails, retry once
- If OpenCode command fails, offer manual memory storage
- Always inform user of storage status
- Provide recovery instructions if needed
