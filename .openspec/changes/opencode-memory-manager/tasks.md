# Tasks: Graphiti Memory Manager Module

## Phase 1: Specification and Setup
- [ ] Confirm required dependencies (`graphiti_core`, `redis`, `ddtrace`, `b2sdk`) are available in the container build context.
- [ ] Validate environment variable defaults and required secrets (FalkorDB, Valkey, OpenAI API key, Backblaze B2 keys/bucket).

## Phase 2: Module Implementation
- [ ] Scaffold `containers/opencode-server/graphiti/memory_manager.py` with async initialization for FalkorDB, Valkey, Graphiti, and B2 clients.
- [ ] Implement `store_episode(content, metadata=None)` with timestamping, `source='opencode'`, cache invalidation, and Datadog trace span.
- [ ] Implement `query_memory(search_query, limit=5)` with deterministic cache key, 5-minute TTL, hit/miss metrics, trace span, and formatted bullet list output.
- [ ] Implement `export_to_b2()` to serialize the graph, generate timestamped filename `graphiti_export_<ts>.json`, upload via `b2sdk`, and return success message.
- [ ] Implement `get_entities(entity_type=None)` to list nodes with name/type dicts inside a trace span.
- [ ] Add CLI parsing for `store`, `query`, `export`, and `entities` commands; run async functions with `asyncio.run`, emit stderr errors, and exit non-zero on failure.

## Phase 3: Validation
- [ ] Smoke test CLI commands against FalkorDB/Valkey test instances and Backblaze test bucket.
- [ ] Verify cache hit latency target (<10ms) for repeated queries.
- [ ] Confirm Datadog traces and cache metrics appear in APM/metrics dashboards.

## Phase 4: Integration
- [ ] Reference the module in the OpenCode Containerfile and pod specs where applicable.
- [ ] Document usage examples for store/query/export/entities commands.
