# OpenCode Memory Pod Specification

## ADDED Requirements

### Pod Definition and Networking
**Requirement**: Create Podman pod `opencode-memory-pod` with shared network namespace and published host ports 4096, 6379, 6380, 3000, and 8126.

**Details**:
- Pod must enable intra-container communication via `localhost`.
- Published ports map to the same container ports for OpenCode (4096), FalkorDB (6379/3000), Valkey (6380), and Datadog APM (8126).
- Pod lifecycle managed by systemd unit `opencode-memory-pod.service`.

### Container Inventory and Configuration
**Requirement**: Attach four containers to the pod with the following configurations:

1. **Valkey Cache**
   - Image: `valkey/valkey:7.2`
   - Arguments: `--port 6380 --maxmemory 2gb --maxmemory-policy allkeys-lru --save 60 1000`
   - Volume: `/persist/containers/valkey:/data`
   - Health check: `valkey-cli -p 6380 ping`

2. **FalkorDB Graph Database**
   - Image: `falkordb/falkordb:latest`
   - Ports: 6379, 3000
   - Volume: `/persist/containers/falkordb:/data`
   - Environment: `REDIS_ARGS="--save 60 100"`

3. **Datadog Agent**
   - Image: `datadog/agent:latest`
   - EnvironmentFile: `/run/secrets/opencode.env`
   - Environment variables: `DD_LOGS_ENABLED=true`, `DD_APM_ENABLED=true`, `DD_APM_NON_LOCAL_TRAFFIC=true`, `DD_LLM_OBSERVABILITY_ENABLED=true`
   - Volume: `/var/run/podman/podman.sock:/var/run/docker.sock:ro`

4. **OpenCode Server**
   - Image: `opencode-server:latest`
   - Port: 4096
   - Volumes:
     - `/persist/containers/opencode:/root/.local/share/opencode`
     - Optional: `/path/to/plugin:/root/.opencode/plugin:ro`
     - Optional: `/path/to/graphiti:/root/.opencode/graphiti:ro`
   - EnvironmentFile: `/run/secrets/opencode.env`
   - Health check: `curl -f http://localhost:4096/config`

### Startup Ordering and Lifecycle
**Requirement**: Enforce ordered startup and graceful shutdown through systemd.

**Details**:
- `ExecStartPre` steps create pod, then start Valkey → FalkorDB → Datadog containers.
- `ExecStart` launches OpenCode container after dependencies are running.
- `ExecStop` stops the pod; `ExecStopPost` removes the pod.
- Unit properties: `Type=forking`, `RemainAfterExit=yes`, `Restart=on-failure`, `RestartSec=10s`, `After=network-online.target tailscaled.service onepassword-secrets.service`, `Wants=network-online.target`.

### Persistence and Secrets
**Requirement**: Persist service data and externalize secrets.

**Details**:
- Bind mounts under `/persist/containers/{valkey,falkordb,opencode}` store service data across restarts.
- All secrets are read from `/run/secrets/opencode.env`; images must not bake secrets.
- Plugin and Graphiti mounts remain read-only to protect host content.

## ACCEPTANCE CRITERIA
- Pod starts successfully with all four containers attached and healthy.
- Services are reachable on host ports 4096 (OpenCode), 6379/3000 (FalkorDB), 6380 (Valkey), and 8126 (Datadog APM).
- Containers communicate with each other via `localhost` inside the pod.
- Data persists under `/persist/containers/{valkey,falkordb,opencode}` after restart.
- Datadog Agent collects logs and APM/LLM telemetry from all containers via shared network and Podman socket access.
