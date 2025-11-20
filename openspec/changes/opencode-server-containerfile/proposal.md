# Change Proposal: Containerfile for OpenCode Server with Graphiti, Datadog, and Backblaze

## Summary
Author a Containerfile at `containers/opencode-server/Containerfile` that builds an OpenCode server image on `node:20-slim` with Graphiti memory manager support, Datadog APM tracing, and Backblaze B2 backup tooling. The image should install necessary system packages, create a Python virtual environment for Graphiti and observability libraries, copy plugin/Graphiti code and helper scripts from the build context, expose port 4096, default localhost cache/database endpoints, and run OpenCode under `ddtrace-run` with a health check on `/config`.

## Problem
The repository lacks a documented specification for the OpenCode server image that integrates Graphiti, Datadog tracing, and Backblaze backups. Without a dedicated proposal, image contents, directory layout, runtime defaults, and health expectations remain undefined, increasing the risk of inconsistent builds and missing dependencies.

## Goals
- Define a repeatable Containerfile based on `node:20-slim` for the OpenCode server.
- Include required system dependencies (Python stack, Git, curl, redis-tools, rclone, cron).
- Create a Python venv with Graphiti, FalkorDB client, Redis client, Datadog tracing, API client, and B2 SDK libraries.
- Copy plugin, Graphiti, helper scripts, and OpenCode config from the build context into correct in-image paths.
- Expose port 4096 and set default localhost endpoints for FalkorDB and Valkey.
- Run the server via `ddtrace-run opencode serve --hostname 0.0.0.0 --port 4096` with a defined HTTP health check.

## Non-Goals
- Building or publishing the image to a registry (only authoring the Containerfile is in scope).
- Managing runtime secrets for Datadog or Backblaze (they remain external to the image).
- Defining orchestration (handled by the OpenCode memory pod spec).

## Proposed Solution
- Base the image on `node:20-slim` and install system dependencies: `python3`, `python3-pip`, `python3-venv`, `git`, `curl`, `redis-tools`, `rclone`, and `cron`.
- Install OpenCode globally via `npm install -g opencode`.
- Create `/opt/venv` and install Python packages `graphiti-core[falkordb]`, `falkordb`, `redis`, `ddtrace`, `datadog-api-client`, and `b2sdk`.
- Copy build-context assets:
  - `plugin/` → `/root/.opencode/plugin/`
  - `graphiti/` → `/root/.opencode/graphiti/`
  - `scripts/` → `/app/scripts/`
  - `config.json` → `/root/.config/opencode/opencode.json`
- Declare environment defaults: `FALKORDB_HOST=localhost`, `FALKORDB_PORT=6379`, `VALKEY_HOST=localhost`, `VALKEY_PORT=6380`.
- Expose port 4096, define a health check (`curl -f http://localhost:4096/config || exit 1` with 30s interval, 10s timeout, 40s start period), and set entrypoint `ddtrace-run opencode serve --hostname 0.0.0.0 --port 4096`.

## Risks and Mitigations
- **Dependency drift**: Pin versions where needed during implementation; rely on venv isolation to prevent conflicts with Node packages.
- **Secret handling**: Keep Datadog and Backblaze credentials out of the image; document reliance on runtime environment variables.
- **Health visibility**: Health check ensures container start success; failures surfaced early via container runtime.

## Rollout Plan
1. Review and approve this Containerfile proposal under the OpenSpec process.
2. Implement the Containerfile in `containers/opencode-server/Containerfile` following the spec.
3. Build and run the image locally to validate health checks, port exposure, and Graphiti/Datadog integrations.
4. Integrate with orchestration (e.g., `opencode-memory-pod`) after validation.

## Acceptance Criteria
- Containerfile builds successfully without errors.
- OpenCode server starts and responds on port 4096 with the health check passing after the start period.
- Graphiti memory manager and Python dependencies are available via `/opt/venv`.
- Datadog tracing wraps OpenCode via the `ddtrace-run` entrypoint.
- Backblaze tooling (`rclone`, `b2sdk`) is present for backups.
