# Scripts

This directory contains utility scripts for the OpenAgents system.

## Available Scripts

### Component Management

- `register-component.sh` - Register a new component in the registry
- `validate-component.sh` - Validate component structure and metadata

### Session Management

- `cleanup-stale-sessions.sh` - Remove stale agent sessions older than 24 hours

### Testing

See `tests/` subdirectory for test scripts.

## Session Cleanup

Agent instances create temporary context files in `.tmp/sessions/{session-id}/` for subagent delegation. These sessions are automatically cleaned up, but you can manually remove stale sessions:

```bash
# Clean up sessions older than 24 hours
./scripts/cleanup-stale-sessions.sh

# Or manually delete all sessions
rm -rf .tmp/sessions/
```

Sessions are safe to delete anytime - they only contain temporary context files for agent coordination.

## Usage Examples

### Register a Component
```bash
./scripts/register-component.sh path/to/component
```

### Validate a Component
```bash
./scripts/validate-component.sh path/to/component
```

### Clean Stale Sessions
```bash
./scripts/cleanup-stale-sessions.sh
```
