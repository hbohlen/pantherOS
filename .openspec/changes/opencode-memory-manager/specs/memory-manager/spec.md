# Specification: Graphiti Memory Manager Module

## File Location
- `containers/opencode-server/graphiti/memory_manager.py`

## Dependencies
- `graphiti_core` (Graphiti, FalkorDriver)
- `redis` (Valkey client)
- `ddtrace` (APM spans and metrics)
- `b2sdk` (Backblaze B2 client)
- Standard library: `sys`, `os`, `json`, `datetime`, `typing`, `asyncio`

## Configuration (Environment)
- `FALKORDB_HOST` (default: `localhost`)
- `FALKORDB_PORT` (default: `6379`)
- `VALKEY_HOST` (default: `localhost`)
- `VALKEY_PORT` (default: `6380`)
- `OPENAI_API_KEY` (required for Graphiti embeddings)
- `B2_KEY_ID`, `B2_APP_KEY` (required for Backblaze auth)
- `B2_BUCKET` (target bucket)

## Initialization Requirements
- Instantiate `FalkorDriver` with configured host/port.
- Create Valkey client via `redis.Redis` with configured host/port.
- Initialize `Graphiti` using the Falkor driver; ensure `OPENAI_API_KEY` is present.

## Async Functions
1. `store_episode(content: str, metadata: dict | None = None) -> str`
   - Create episode with timestamp and `source='opencode'` plus optional metadata.
   - Wrap in Datadog span `service=memory-manager`, `resource=store_episode`.
   - Invalidate relevant cache keys after write.
   - Return generated episode name (e.g., `episode_<timestamp>`).

2. `query_memory(search_query: str, limit: int = 5) -> str`
   - Cache key: `query:{hash(search_query)}`.
   - On cache hit: record `opencode.memory.cache_hit` metric; return cached value.
   - On cache miss: execute `Graphiti.search()` with limit, format results as bullet list string, set cache TTL 300 seconds, record `opencode.memory.cache_miss` metric.
   - Add Datadog span around operation.

3. `export_to_b2() -> str`
   - Export Graphiti graph to JSON.
   - Filename: `graphiti_export_<timestamp>.json`.
   - Upload to `B2_BUCKET` via `b2sdk` using `B2_KEY_ID`/`B2_APP_KEY` credentials.
   - Return success message including filename.

4. `get_entities(entity_type: str | None = None) -> list`
   - Query Graphiti for nodes, optionally filtered by `entity_type`.
   - Return list of dicts containing `name` and `type` fields.

## CLI Interface
- Commands and behaviors:
  - `store <content> [metadata_json]`
  - `query <search_query>`
  - `export`
  - `entities [entity_type]`
- Parse `sys.argv` and execute via `asyncio.run(...)`.
- On error: print message to stderr and exit with status 1.

## Health and Observability
- All public functions wrapped with Datadog trace spans.
- Emit cache hit/miss metrics for `query_memory`.
- Target cached query latency: <10ms for repeated queries.

## Acceptance Criteria
- Script executes via `python3 memory_manager.py <command>`.
- Episodes persist in FalkorDB through Graphiti.
- Cache hits serve responses under 10ms; cache misses populate Valkey with 300s TTL.
- Backblaze export produces valid JSON file and uploads successfully.
- Datadog APM shows traces for store/query/export/entities operations.
