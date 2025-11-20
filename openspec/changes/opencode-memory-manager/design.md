# Design: Graphiti Memory Manager Module

## Overview
The memory manager module will provide async, traceable knowledge graph operations for OpenCode by combining Graphiti (with FalkorDB backend), Valkey caching, and Backblaze B2 export. It exposes reusable async functions plus a CLI wrapper to enable scripting and integration inside the OpenCode container image.

## Components
- **Graphiti + FalkorDB**: `Graphiti` initialized with `FalkorDriver` to persist episodes and entities in FalkorDB.
- **Valkey Cache**: `redis.Redis` client targeting Valkey for query result caching; TTL 300s.
- **Datadog Observability**: `ddtrace` spans around each public function; cache hit/miss metrics (e.g., `opencode.memory.cache_hit`, `opencode.memory.cache_miss`).
- **Backblaze Export**: `b2sdk` client authenticating with `B2_KEY_ID`/`B2_APP_KEY` to upload JSON exports to `B2_BUCKET`.
- **CLI Interface**: Argument parsing on `sys.argv` to call async functions via `asyncio.run`, with stderr messaging and non-zero exits on error.

## Data Flow
1. **Initialization**: Read environment configuration for FalkorDB, Valkey, OpenAI API key, and B2 credentials; create clients lazily or on module load with validation.
2. **store_episode**: Add timestamped episode with `source='opencode'`, optional metadata, then invalidate cache keys derived from query hashes; wrap in Datadog span.
3. **query_memory**: Compute cache key `query:{hash(search_query)}`; attempt Valkey get; on miss, run `Graphiti.search()` (limit default 5), format results into a bullet list string, cache response for 300s, emit hit/miss metric, and wrap in span.
4. **export_to_b2**: Serialize Graphiti graph to JSON, write to temp file with timestamped filename `graphiti_export_<ts>.json`, upload to bucket with `b2sdk`, return success message; traced span around export and upload.
5. **get_entities**: Query Graphiti for nodes, optionally filtered by `entity_type`, and return list of `{name, type}` dicts; traced span.

## Error Handling
- Validate mandatory secrets (`OPENAI_API_KEY`, B2 credentials) and endpoints at startup or before operations; surface actionable errors to stderr.
- Wrap CLI invocation in try/except to print errors and exit 1; raise exceptions from functions for upstream handling.
- Handle cache connectivity failures gracefully by logging/metrics while still serving responses from FalkorDB.

## Security and Secrets
- Rely solely on environment variables for sensitive values; do not log secrets.
- Avoid writing credentials to disk; temporary export files should be cleaned up after successful upload.

## Performance Considerations
- Async functions with minimal blocking I/O; prefer async Graphiti/Redis interfaces if available, otherwise run blocking calls in threads as needed (implementation detail captured in future code).
- Cache TTL of 300 seconds to balance staleness and latency; target cache hit latency under 10ms as acceptance.

## Deployment Notes
- File location: `containers/opencode-server/graphiti/memory_manager.py` within the OpenCode container context.
- Dependencies: `graphiti_core`, `redis`, `ddtrace`, `b2sdk`, and stdlib modules (`sys`, `os`, `json`, `datetime`, `typing`, `asyncio`).
- Health expectation: CLI commands should exit 0 on success; errors should include context for operational visibility.
