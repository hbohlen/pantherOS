# Change Proposal: OpenCode Graphiti Memory Plugin with Valkey Caching and Datadog Observability

## Summary
Create an OpenCode TypeScript plugin at `containers/opencode-server/plugin/graphiti-memory.ts` that captures workspace context into the Graphiti memory system via event hooks, accelerates queries with Valkey caching, and emits Datadog metrics/events. The plugin should wrap calls to the Python memory manager script, automatically inject memory context into chats, and harden error handling so failures never crash OpenCode.

## Problem
OpenCode currently lacks a defined plugin that feeds editor and chat activity into the Graphiti memory pipeline while providing fast cache-backed lookups and operational visibility. Without a proposal, event coverage, cache strategy, subprocess contracts, Datadog reporting, and resilience expectations remain unclear, risking brittle integrations and missing observability.

## Goals
- Define event handlers for `chat:start`, `file:write`, `error`, and `completion` that call the memory manager script and apply caching/metrics per requirements.
- Specify helper functions for Valkey cache access, Datadog metrics/events, and subprocess invocation via `python3` and `bun`.
- Ensure initialization logging and configuration (memory script path, Valkey URI, cache TTL) are explicit and validated.
- Require defensive error handling that logs failures without disrupting OpenCode execution.

## Non-Goals
- Implementing the Python memory manager itself (covered by separate spec).
- Managing secret retrieval for Datadog or backend services (assumed provided at runtime).
- Altering OpenCode core event schemas beyond the described hooks.

## Proposed Solution
- Create `graphiti-memory.ts` under the OpenCode plugin directory, exporting an `@opencode-ai/plugin` that connects to Valkey and wires event handlers.
- Use environment-configurable paths/URIs with defaults aligned to the full OpenAgents developer package (https://github.com/darrenhinde/OpenAgents), with the memory script pointing to its Graphiti `memory_manager.py`, Valkey `redis://localhost:6380`, cache TTL 300 seconds.
- Implement helper utilities for hashing queries, cache get/set/invalidate, subprocess execution for store/query, and Datadog metric/event emission via DogStatsD/auxiliary script.
- On `chat:start`, retrieve cached context when available; otherwise run `queryMemory`, cache the response, inject it as a system message, and emit hit/miss metrics.
- On `file:write`, call `storeEpisode` with file metadata and invalidate relevant cache keys.
- On `error`, record the episode and forward a Datadog event.
- On `completion`, record success metadata and emit token usage metrics.
- Wrap handlers in try/catch blocks that log errors but do not throw.

## Alternatives Considered
- **Inline JavaScript Graphiti client**: Rejected to keep a single Python memory manager implementation and avoid duplicating logic.
- **Cache-only or no caching**: Rejected because cache-less queries increase latency; cache-only without backing memory would lose persistence.
- **HTTP service shim instead of subprocess**: Rejected for simplicity; subprocess keeps deployment lightweight and uses the existing script contract.

## Risks
- Subprocess invocation may block if the Python script hangs; mitigated by lightweight calls and potential future timeouts.
- DogStatsD UDP send may fail silently; metrics may be lossy but non-critical.
- Cache invalidation patterns might over/under-invalidate; tests should validate patterns against expected queries.

## Rollout Plan
1. Implement plugin with all handlers and helper utilities behind feature flag or guarded load.
2. Integrate in OpenCode container build alongside memory manager script and Datadog helper script.
3. Smoke test in a dev environment with FalkorDB/Valkey to confirm event flows and cache behavior.
4. Monitor Datadog for emitted metrics/events; adjust tagging or cache patterns as needed.

## Acceptance Criteria
- Plugin loads on OpenCode startup and logs initialization messages for plugin and Valkey connection.
- Chat start events inject memory context from cache or live query without crashing on failures.
- File write events store episodes and invalidate cache entries tied to the edited path.
- Error events create Datadog events and store episodes; completion events record success metadata and token metrics.
- Valkey cache reduces repeated query latency and respects 5-minute TTL.
