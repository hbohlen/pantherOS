# Change Proposal: Graphiti Memory Manager Module with FalkorDB, Valkey Cache, and Backblaze Export

## Summary
Create an async Python module at `containers/opencode-server/graphiti/memory_manager.py` that provides Graphiti-backed knowledge graph memory operations with FalkorDB storage, Valkey caching, Backblaze B2 export, and Datadog observability. The module must expose CLI-accessible commands for storing episodes, querying memory with cache acceleration, exporting graph data to B2, and listing entities, all parameterized by environment-provided endpoints and credentials.

## Problem
The OpenCode stack lacks a documented plan for a reusable memory manager that combines Graphiti with FalkorDB persistence, Valkey caching, Datadog tracing/metrics, and Backblaze B2 export. Without a proposal, interface expectations, async behavior, configuration, and CLI usability for `memory_manager.py` remain undefined, risking inconsistent implementations and missing observability.

## Goals
- Define an async Python module that initializes Graphiti with FalkorDB and Valkey clients using environment-driven configuration defaults.
- Provide async functions to store episodes, query memory with caching and metrics, export graph data to Backblaze B2, and list entities.
- Include Datadog APM spans and cache hit/miss metrics around operations.
- Deliver a CLI wrapper using `sys.argv` to invoke store/query/export/entities commands with proper error handling and exit codes.

## Non-Goals
- Implementing orchestration or service management (handled by Containerfile/pod specs).
- Managing secret retrieval; environment variables are assumed to be provided securely at runtime.
- Building or distributing container images (only the module and spec are in scope).

## Proposed Solution
- Initialize FalkorDB connectivity via `FalkorDriver` using `FALKORDB_HOST`/`FALKORDB_PORT` (defaulting to `localhost`/`6379`).
- Connect to Valkey with `redis.Redis` using `VALKEY_HOST`/`VALKEY_PORT` (defaults `localhost`/`6380`) for caching query results.
- Set up Graphiti with the Falkor driver and rely on `OPENAI_API_KEY` for embeddings.
- Provide async functions:
  - `store_episode(content, metadata=None)` to create a timestamped episode with source `opencode`, emit a Datadog trace span, and invalidate related cache keys.
  - `query_memory(search_query, limit=5)` to prefer cached results (5-minute TTL) using a deterministic key, query Graphiti on miss, emit cache hit/miss metrics, and return formatted context.
  - `export_to_b2()` to dump the Graphiti graph to JSON, upload via `b2sdk` with timestamped filename, and report success.
  - `get_entities(entity_type=None)` to fetch nodes (optionally filtered) and return name/type dicts.
- Build a CLI entrypoint that parses `sys.argv` for `store`, `query`, `export`, and `entities` commands, running async functions via `asyncio.run`, printing errors to stderr, and exiting non-zero on failure.

## Risks and Mitigations
- **Missing credentials or endpoints**: Validate required environment variables (e.g., `OPENAI_API_KEY`, B2 keys) early and produce clear errors.
- **Cache inconsistency**: Centralize cache key creation and invalidation after writes; use short TTL to limit stale data.
- **Performance drift**: Emit cache hit/miss metrics and trace spans to surface latency; ensure async execution to avoid blocking.

## Rollout Plan
1. Approve this proposal under the OpenSpec process.
2. Draft the module per the specification in `containers/opencode-server/graphiti/memory_manager.py`.
3. Validate CLI commands locally against FalkorDB/Valkey test instances and a Backblaze test bucket.
4. Integrate with the OpenCode Containerfile and pod orchestration once validated.

## Acceptance Criteria
- `python3 memory_manager.py <command>` executes successfully for store/query/export/entities flows.
- Episodes persist to FalkorDB via Graphiti; queries return cached responses when available with latency under 10ms.
- Backblaze export produces a valid JSON graph file and returns a success message with filename.
- Datadog traces and cache hit/miss metrics are emitted for operations.
