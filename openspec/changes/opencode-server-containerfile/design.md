# Design: OpenCode Server Container with Graphiti, Datadog, and Backblaze Support

## Build Overview
This design defines how to construct a Containerfile for the OpenCode server that layers Graphiti memory management, Datadog APM tracing, and Backblaze B2 backups on top of `node:20-slim`. The image must deliver required system tools, an isolated Python environment for Graphiti and observability helpers, and a Datadog-instrumented entrypoint that runs `opencode serve` on port 4096.

## Design Principles

### 1. Minimal, Reproducible Base
**Principle**: Start from `node:20-slim` and install only the system packages necessary to support OpenCode, Graphiti, observability, and backups.

**Implementation**:
- Install Python tooling (`python3`, `python3-pip`, `python3-venv`) and utility dependencies (`git`, `curl`, `redis-tools`, `rclone`, `cron`).
- Use `npm install -g opencode` to provide the server runtime from the base image, avoiding extra language runtimes.

### 2. Isolated Python Runtime for Memory Manager
**Principle**: Keep Graphiti and supporting Python libraries in a dedicated virtual environment to avoid dependency collisions with Node tooling.

**Implementation**:
- Create `/opt/venv` with `python3 -m venv` and install `graphiti-core[falkordb]`, `falkordb`, `redis`, `ddtrace`, `datadog-api-client`, and `b2sdk` via `pip`.
- Ensure helper scripts reference the venv for consistent interpreter and site-packages usage.

### 3. Prescribed Directory Layout for Config and Extensibility
**Principle**: Align filesystem paths with OpenCode and Graphiti expectations while keeping host-mounted assets organized.

**Implementation**:
- Bundle the full OpenAgents developer package (https://github.com/darrenhinde/OpenAgents) in the image, including plugin and Graphiti assets sourced from the build context, to supply the developer tooling.
- Place operational helper scripts under `/app/scripts/` sourced from build context `scripts/`.
- Copy `config.json` from the build context to `/root/.config/opencode/opencode.json` to configure the server.

### 4. First-Class Observability
**Principle**: Run OpenCode under Datadog tracing and provide health visibility.

**Implementation**:
- Use `ddtrace-run opencode serve --hostname 0.0.0.0 --port 4096` as the entrypoint so HTTP traffic and Graphiti interactions are instrumented.
- Declare a health check (`curl -f http://localhost:4096/config || exit 1`) with 30s interval, 10s timeout, and 40s start period to verify readiness.

### 5. Sensible Defaults for Local Dependencies
**Principle**: Ship default environment values that match the pod expectations while allowing overrides.

**Implementation**:
- Default `FALKORDB_HOST=localhost`, `FALKORDB_PORT=6379`, `VALKEY_HOST=localhost`, `VALKEY_PORT=6380` in the image.
- Leave Datadog credentials and Backblaze secrets external to the image; rely on runtime environment injection.

## Build Flow
1. Start from `node:20-slim` and install required apt packages.
2. Install OpenCode globally via npm.
3. Create `/opt/venv` and install Graphiti plus observability and backup Python packages.
4. Copy plugin, Graphiti, scripts, and configuration assets from the build context into their destination paths.
5. Expose port 4096, define default environment variables, and set the Datadog-traced entrypoint and health check.

## Security and Maintenance Considerations
- Keep secrets (Datadog keys, Backblaze credentials) out of the image; rely on runtime environment files.
- Prefer pinned package versions during implementation if upstream instability is observed (not specified in current requirements).
- Ensure scripts and configs have appropriate permissions to execute within the container without escalating privileges.
