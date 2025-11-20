# Tasks: OpenCode Graphiti Memory Plugin

## Phase 1: Specification and Setup
- [ ] Confirm plugin location `containers/opencode-server/plugin/graphiti-memory.ts` and availability of `bun`, `redis` client, and Python memory script.
- [ ] Validate default configuration (memory script path, Valkey URI `redis://localhost:6380`, cache TTL 300s) and override strategy via environment.

## Phase 2: Implementation
- [ ] Scaffold `@opencode-ai/plugin` export with initialization logs and Valkey connection.
- [ ] Implement helper utilities: query hashing, cache get/set, cache invalidation by pattern, subprocess wrappers for store/query, Datadog metric/event emitters.
- [ ] Add event handlers:
  - `chat:start` to fetch cache or query memory, emit cache hit/miss metrics, cache results, and inject `[Memory Context]{context}`.
  - `file:write` to store episode with file metadata and invalidate `memory:*{path}*` cache keys.
  - `error` to store high-severity episodes and emit Datadog events.
  - `completion` to store success metadata and emit token counter metric.
- [ ] Wrap all handlers in try/catch with `console.error('Memory plugin error:', err)` logging and safe `{ event }` returns.

## Phase 3: Validation
- [ ] Smoke test plugin load within OpenCode container; verify initialization logs and Valkey connectivity.
- [ ] Trigger each event type to confirm subprocess calls, cache behavior, and Datadog metric/event emission.
- [ ] Verify cache TTL enforcement and that repeated queries return within <10ms from cache.

## Phase 4: Integration
- [ ] Ensure plugin is bundled into the OpenCode container build and enabled by default.
- [ ] Document configuration overrides and operational runbook for memory context behavior.
