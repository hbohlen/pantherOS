# Graphiti Memory Plugin Specification

## ADDED Requirements

### Plugin Scope and Location
**Requirement**: Provide an `@opencode-ai/plugin` TypeScript module at `containers/opencode-server/plugin/graphiti-memory.ts`.

**Details**:
- Module must load on OpenCode startup and log `🧠 Graphiti Memory Plugin loaded`.
- Use configuration defaults: `MEMORY_SCRIPT=/root/.opencode/graphiti/memory_manager.py`, `VALKEY_URL=redis://localhost:6380`, `CACHE_TTL_SECONDS=300`.
- Log Valkey connection: `📦 Valkey cache connected at {host}:{port}` after successful client setup.

### Helper Utilities
**Requirement**: Implement helper functions to interact with memory manager, cache, and observability endpoints.

**Details**:
- `hashQuery(query: string): string` — base64 encode query and truncate to 32 chars, prefix cache keys with `memory:`.
- `storeEpisode(content: string, metadata?: any): Promise<string>` — execute `python3 ${MEMORY_SCRIPT} store "{content}" '{JSON.stringify(metadata)}'` via `bun` `$`; return stdout.
- `queryMemory(query: string): Promise<string>` — execute `python3 ${MEMORY_SCRIPT} query "{query}"`; measure duration and emit metric `opencode.memory.query_duration`.
- `invalidateCache(pattern: string): Promise<void>` — scan Valkey for keys matching pattern and delete all matches.
- `emitDatadogMetric(name: string, value: number, tags?: Record<string,string>): Promise<void>` — format `{name}:{value}|c|#{tags}` and send via `nc -u -w0 localhost 8125`.
- `emitDatadogEvent(event: { title, text, alert_type }): Promise<void>` — call `python3 /app/scripts/send_datadog_event.py '{JSON.stringify(event)}'`.

### Event Handlers
**Requirement**: Register OpenCode event hooks that capture context, manage cache, and forward observability signals.

**Details**:
- **chat:start**:
  - Compute cache key `memory:{hashQuery(event.query)}`.
  - Attempt Valkey get; emit `opencode.memory.cache_hit` or `opencode.memory.cache_miss` metric.
  - On miss, call `queryMemory(event.query)`, cache for 300 seconds, and inject context via `client.chat.sendSystemMessage({ content: '[Memory Context]{context}' })`.
- **file:write**:
  - Run `storeEpisode('Modified: {event.path}', { type: 'file_edit', path: event.path })`.
  - Invalidate caches matching `memory:*{event.path}*`.
- **error**:
  - Run `storeEpisode('Error: {event.message}', { type: 'error', severity: 'high' })`.
  - Emit Datadog event `{ title: 'OpenCode Error', text: event.message, alert_type: 'error' }`.
- **completion**:
  - Run `storeEpisode('Completed: {event.task}', { type: 'success', duration: event.duration, tokens: event.tokens })`.
  - Emit counter metric `opencode.tokens.used = event.tokens`.

### Error Handling and Resilience
**Requirement**: Prevent plugin failures from disrupting OpenCode runtime.

**Details**:
- Wrap all event handlers in try/catch; log `Memory plugin error:` plus error details.
- Always return `{ event }` even when underlying operations fail.
- Ensure subprocess, cache, or metric send failures do not throw upward.

### Cache Behavior
**Requirement**: Provide consistent caching for chat queries.

**Details**:
- Cache TTL fixed at 300 seconds.
- Cache lookups must precede Python query execution.
- Cache invalidation must clear entries related to modified paths using pattern-based deletion.

### Acceptance Validation
**Requirement**: Validate functionality per acceptance criteria.

**Details**:
- Plugin loads and logs initialization messages.
- Chat start events inject context from cache or live query without crashes.
- File writes update Graphiti and invalidate relevant cache keys.
- Errors generate Datadog events and stored episodes; completions emit token metrics.
- Valkey cache reduces repeated query latency relative to uncached calls.
