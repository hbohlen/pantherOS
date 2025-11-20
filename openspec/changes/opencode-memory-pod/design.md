# Design: OpenCode Memory Pod Orchestration

## Architectural Overview
This design captures how the OpenCode memory stack (OpenCode server, Valkey, FalkorDB, and Datadog Agent) will be orchestrated using a systemd-managed Podman pod with a shared network namespace. The pod exposes OpenCode (4096), FalkorDB (6379/3000), Valkey (6380), and Datadog APM (8126) to the host while persisting container state under `/persist/containers` and consuming secrets from `/run/secrets/opencode.env`.

## Design Principles

### 1. Shared Network Namespace with Explicit Port Publishing
**Principle**: Containers communicate internally via `localhost`, while only required ports are published to the host.

**Rationale**: Shared networking simplifies service discovery and avoids cross-container addressing issues. Publishing only necessary ports reduces surface area.

**Implementation**:
- Podman pod `opencode-memory-pod` created with published ports 4096, 6379, 6380, 3000, 8126.
- All containers join the pod to share loopback networking; host access occurs through the published mappings.

### 2. Deterministic Startup Ordering with Health Awareness
**Principle**: Dependencies start in order (Valkey → FalkorDB → Datadog → OpenCode) with clear health checks.

**Rationale**: Ordered startup prevents transient failures from unmet dependencies and improves observability.

**Implementation**:
- `ExecStartPre` sequence creates pod then starts Valkey, FalkorDB, Datadog in order.
- Health checks: Valkey `valkey-cli -p 6380 ping`; FalkorDB readiness on 6379; OpenCode HTTP check `curl -f http://localhost:4096/config`.
- Restart policy `on-failure` with `RestartSec=10s` on the systemd unit.

### 3. Persistent Data with Secret-Safe Configuration
**Principle**: Data is persisted explicitly, and secrets are sourced from host-provided environment files.

**Rationale**: Ensures durable state across restarts while keeping secrets outside images.

**Implementation**:
- Bind mounts `/persist/containers/{valkey,falkordb,opencode}` to container data paths.
- EnvironmentFile `/run/secrets/opencode.env` for Datadog and OpenCode.
- Optional plugin/Graphiti mounts remain read-only to protect host content.

### 4. Observability First
**Principle**: Datadog Agent must capture logs, APM, and LLM telemetry for all containers.

**Rationale**: Unified observability is required for operational insight and debugging.

**Implementation**:
- Datadog Agent container with Podman socket bind `/var/run/podman/podman.sock:/var/run/docker.sock:ro`.
- Env flags: `DD_LOGS_ENABLED=true`, `DD_APM_ENABLED=true`, `DD_APM_NON_LOCAL_TRAFFIC=true`, `DD_LLM_OBSERVABILITY_ENABLED=true`.
- Containers label/route traffic through shared network namespace for agent discovery.

## System Components

### Pod Definition
- Name: `opencode-memory-pod`
- Ports published to host: 4096/tcp, 6379/tcp, 6380/tcp, 3000/tcp, 8126/tcp
- Network: shared namespace among all containers

### Containers
- **Valkey**: `valkey/valkey:7.2`; args `--port 6380 --maxmemory 2gb --maxmemory-policy allkeys-lru --save 60 1000`; volume `/persist/containers/valkey:/data`; health check via `valkey-cli -p 6380 ping`.
- **FalkorDB**: `falkordb/falkordb:latest`; env `REDIS_ARGS="--save 60 100"`; volume `/persist/containers/falkordb:/data`; ports 6379/3000.
- **Datadog Agent**: `datadog/agent:latest`; environment file `/run/secrets/opencode.env`; env vars for logs/APM/LLM; socket mount `/var/run/podman/podman.sock:/var/run/docker.sock:ro`.
- **OpenCode Server**: `opencode-server:latest`; volume `/persist/containers/opencode:/root/.local/share/opencode`; optional plugin `/path/to/plugin:/root/.opencode/plugin:ro` and Graphiti `/path/to/graphiti:/root/.opencode/graphiti:ro`; environment file `/run/secrets/opencode.env`; health check HTTP to `/config` on port 4096.

### Systemd Integration
- Unit: `opencode-memory-pod.service`
- Type: `forking`; `RemainAfterExit=yes`
- Ordering: `After=network-online.target tailscaled.service onepassword-secrets.service`; `Wants=network-online.target`
- ExecStartPre: create pod → start Valkey → start FalkorDB → start Datadog
- ExecStart: start OpenCode container
- ExecStop: `podman pod stop opencode-memory-pod`
- ExecStopPost: `podman pod rm opencode-memory-pod`
- Restart policy: `Restart=on-failure`, `RestartSec=10s`
- User: root (for Podman socket access)

## Data Flow
- Client requests reach OpenCode via host port 4096; OpenCode uses `localhost` to reach Valkey (6380) and FalkorDB (6379/3000) inside pod.
- Datadog Agent scrapes/logs from containers through shared namespace and Podman socket.

## Security Considerations
- Secrets remain in `/run/secrets/opencode.env` outside images.
- Read-only mounts for plugin/Graphiti assets to prevent mutation.
- Limited host port exposure reduces attack surface.

## Open Questions
- Should Valkey or FalkorDB enforce additional auth via `requirepass` or TLS? (not specified in current request)
- Does OpenCode require additional volume paths for uploads or logs beyond stated mounts?
