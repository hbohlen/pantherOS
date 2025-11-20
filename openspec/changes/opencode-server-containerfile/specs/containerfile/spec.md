# OpenCode Server Containerfile Specification

## ADDED Requirements

### Base Image and System Packages
**Requirement**: Build the OpenCode server image from `node:20-slim` and install supporting system utilities.

**Details**:
- Install `python3`, `python3-pip`, `python3-venv`, `git`, `curl`, `redis-tools`, `rclone`, and `cron` via apt.
- Install OpenCode globally using `npm install -g opencode` within the image.

### Python Virtual Environment
**Requirement**: Provide an isolated Python environment at `/opt/venv` for Graphiti and observability libraries.

**Details**:
- Create the venv with `python3 -m venv /opt/venv`.
- Install packages: `graphiti-core[falkordb]`, `falkordb`, `redis`, `ddtrace`, `datadog-api-client`, and `b2sdk` using pip inside the venv.

### File and Directory Layout
**Requirement**: Lay out application assets and configuration in the container using build-context files.

**Details**:
 - Copy the full OpenAgents developer package (https://github.com/darrenhinde/OpenAgents) from the build context so the plugin and Graphiti assets are available together in the image.
 - Copy `scripts/` from the build context to `/app/scripts/`.
- Copy `config.json` from the build context to `/root/.config/opencode/opencode.json`.

### Runtime Defaults and Ports
**Requirement**: Configure runtime defaults and expose the OpenCode HTTP port.

**Details**:
- Expose port `4096/tcp`.
- Set default environment variables: `FALKORDB_HOST=localhost`, `FALKORDB_PORT=6379`, `VALKEY_HOST=localhost`, `VALKEY_PORT=6380`.
- Keep Datadog and Backblaze credentials external; do not bake secrets into the image.

### Health Check and Entrypoint
**Requirement**: Provide an instrumented entrypoint and container health check.

**Details**:
- Define health check command `curl -f http://localhost:4096/config || exit 1` with `--interval=30s`, `--timeout=10s`, and `--start-period=40s`.
- Set entrypoint `ddtrace-run opencode serve --hostname 0.0.0.0 --port 4096` to ensure Datadog APM wraps server execution.

## ACCEPTANCE CRITERIA
- Containerfile builds successfully without errors.
- OpenCode server starts and responds on port 4096; health check passes after the 40s start period.
- Python dependencies are available in `/opt/venv` for Graphiti and observability helpers.
- Datadog tracing instruments OpenCode via the `ddtrace-run` entrypoint.
- Backup tooling (`rclone`, `b2sdk`) is present for Backblaze integration.
