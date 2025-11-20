# Tasks: OpenCode Server Containerfile

## Implementation Roadmap
This roadmap outlines the steps to author and validate the OpenCode server Containerfile with Graphiti, Datadog, and Backblaze capabilities.

### Phase 1: Inputs and Context Validation
**Objective**: Confirm build-time and runtime assumptions before writing the Containerfile.

- [ ] Verify build context includes `plugin/`, `graphiti/`, `scripts/`, and `config.json`.
- [ ] Confirm required secrets (Datadog, Backblaze) will be provided at runtime and are not baked into the image.
- [ ] Decide on any pinning for npm or pip packages if stability requires.

### Phase 2: Base Image and System Dependencies
**Objective**: Establish the foundation on `node:20-slim` with necessary tooling.

- [ ] Add apt installs for `python3`, `python3-pip`, `python3-venv`, `git`, `curl`, `redis-tools`, `rclone`, and `cron`.
- [ ] Install OpenCode globally via `npm install -g opencode`.

### Phase 3: Python Environment and Assets
**Objective**: Provision Graphiti and observability tooling within an isolated venv and lay down application assets.

- [ ] Create `/opt/venv` and install `graphiti-core[falkordb]`, `falkordb`, `redis`, `ddtrace`, `datadog-api-client`, and `b2sdk` via pip.
- [ ] Copy `plugin/` to `/root/.opencode/plugin/` and `graphiti/` to `/root/.opencode/graphiti/`.
- [ ] Copy `scripts/` to `/app/scripts/` and `config.json` to `/root/.config/opencode/opencode.json`.

### Phase 4: Runtime Configuration and Health
**Objective**: Define runtime defaults, port exposure, and observability entrypoint.

- [ ] Expose port 4096 and set environment defaults `FALKORDB_HOST=localhost`, `FALKORDB_PORT=6379`, `VALKEY_HOST=localhost`, `VALKEY_PORT=6380`.
- [ ] Configure health check `curl -f http://localhost:4096/config || exit 1` with 30s interval, 10s timeout, and 40s start period.
- [ ] Set entrypoint `ddtrace-run opencode serve --hostname 0.0.0.0 --port 4096`.

### Phase 5: Validation
**Objective**: Ensure the image meets acceptance criteria.

- [ ] Build the Containerfile without errors.
- [ ] Run the image and confirm the health check passes after the start period.
- [ ] Verify Graphiti components can connect to FalkorDB/Valkey defaults over localhost.
- [ ] Confirm Datadog tracing initializes via the `ddtrace-run` entrypoint and backup tooling (`rclone`, `b2sdk`) is present.
