# Design: OpenCode Graphiti Memory Plugin

## Overview
The plugin adds automated memory capture and retrieval to OpenCode by bridging event hooks to the Python-based Graphiti memory manager, accelerating queries with Valkey, and exposing Datadog metrics/events. It is delivered as an `@opencode-ai/plugin` TypeScript module loaded inside the OpenCode container.

## Components
- **Plugin Runtime**: TypeScript plugin at `containers/opencode-server/plugin/graphiti-memory.ts` that registers OpenCode event handlers.
- **Graphiti Memory Script**: Python script at `/root/.opencode/graphiti/memory_manager.py` providing store/query/export logic.
- **Valkey Cache**: Redis-compatible cache at `redis://localhost:6380` for query results and cache invalidation patterns.
- **Datadog Observability**: DogStatsD metrics over UDP `localhost:8125` and event publishing via `/app/scripts/send_datadog_event.py`.

## Event Flow
1. **Initialization**
   - Connect to Valkey using `redis` client; log plugin and cache connection messages.
   - Resolve configuration defaults: memory script path, cache TTL (300s), Valkey URI.
2. **chat:start**
   - Hash the user query to `memory:{base64(query).slice(0,32)}`.
   - Check Valkey for cached context; emit `opencode.memory.cache_hit` or `opencode.memory.cache_miss`.
   - On miss, run `queryMemory` via Python script, cache for 5 minutes, and inject `[Memory Context]{context}` as a system message.
3. **file:write**
   - Call `storeEpisode('Modified: {path}', { type: 'file_edit', path })` via Python script.
   - Invalidate cache keys matching `memory:*{path}*` to drop stale context.
4. **error**
   - Call `storeEpisode('Error: {message}', { type: 'error', severity: 'high' })`.
   - Emit Datadog event `{ title: 'OpenCode Error', text: message, alert_type: 'error' }` via helper script.
5. **completion**
   - Call `storeEpisode('Completed: {task}', { type: 'success', duration, tokens })`.
   - Emit counter metric `opencode.tokens.used` with token count.

## Helper Functions
- **storeEpisode/queryMemory**: Use `bun`'s `$` API to execute `python3 <memory_script> store/query ...`; return stdout.
- **hashQuery**: Base64 encode query and truncate to 32 chars.
- **invalidateCache**: Scan/delete Valkey keys by pattern (e.g., `memory:*{path}*`).
- **emitDatadogMetric**: Format `<name>:<value>|c|#<tags>` and send via `nc -u -w0 localhost 8125`.
- **emitDatadogEvent**: Invoke `/app/scripts/send_datadog_event.py` with JSON payload.

## Error Handling
- Wrap all handler bodies in try/catch; log `Memory plugin error` with details.
- Subprocess or cache failures should not throw; handlers return `{ event }` even on failure.

## Security and Configuration
- Do not hardcode secrets; rely on environment for Datadog and backend credentials.
- Keep subprocess commands constrained to the expected script path.
- Validate/parse metadata JSON before passing to subprocess to avoid injection issues.

## Performance Considerations
- Cache TTL fixed at 300 seconds; cache hits should avoid Python invocation and maintain <10ms retrieval.
- Use lightweight DogStatsD UDP sends to avoid blocking handlers.

## Deployment Notes
- Plugin file included in container build alongside `/app/scripts/send_datadog_event.py` and Python memory manager.
- Ensure `bun` and `redis` client dependencies are available in the OpenCode runtime environment.
