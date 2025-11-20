# Change Proposal: OpenCode Memory Pod Orchestration via systemd + Podman

## Summary
Create a systemd-managed Podman pod (`opencode-memory-pod`) that runs the OpenCode server alongside Valkey cache, FalkorDB graph database, and Datadog Agent with a shared network namespace. The pod should expose OpenCode on port 4096, FalkorDB on ports 6379 and 3000, Valkey on port 6380, and Datadog APM/agent endpoints on port 8126, while persisting service data and loading secrets from `/run/secrets/opencode.env`.

## Problem
The current repository lacks a declarative specification for orchestrating the OpenCode memory stack. Prior work attempted to add a direct Nix host file, but the project expects changes of this scope to follow the OpenSpec proposal workflow. Without a vetted spec, it is unclear how Podman should structure the pod, which environment files and mounts are required, and how health checks or start ordering should be enforced.

## Goals
- Document a complete orchestration plan for an OpenCode memory pod using systemd and Podman.
- Preserve shared networking so all containers communicate over `localhost`.
- Define persistent volumes for Valkey, FalkorDB, and OpenCode state.
- Capture health checks, restart policies, and ordered startup.
- Ensure Datadog Agent integrates for logs, APM, and LLM observability with Podman socket access.

## Non-Goals
- Building the `opencode-server` image itself (handled by a separate build unit).
- Deploying Kubernetes manifests or Docker Compose alternatives.
- Implementing additional monitoring beyond Datadog Agent.

## Proposed Solution
- Add a systemd service `opencode-memory-pod.service` that creates and manages a Podman pod with shared network namespace and published ports 4096, 6379, 6380, 3000, and 8126.
- Sequence container startup using `ExecStartPre` steps: create pod → start Valkey → start FalkorDB → start Datadog Agent → start OpenCode.
- Define container configurations:
  - **Valkey**: image `valkey/valkey:7.2`, port 6380, args `--port 6380 --maxmemory 2gb --maxmemory-policy allkeys-lru --save 60 1000`, volume `/persist/containers/valkey:/data`, health check `valkey-cli -p 6380 ping`.
  - **FalkorDB**: image `falkordb/falkordb:latest`, ports 6379 and 3000, volume `/persist/containers/falkordb:/data`, env `REDIS_ARGS="--save 60 100"`.
  - **Datadog Agent**: image `datadog/agent:latest`, environment from `/run/secrets/opencode.env` plus `DD_LOGS_ENABLED=true`, `DD_APM_ENABLED=true`, `DD_APM_NON_LOCAL_TRAFFIC=true`, `DD_LLM_OBSERVABILITY_ENABLED=true`, mount Podman socket `/var/run/podman/podman.sock:/var/run/docker.sock:ro`.
  - **OpenCode Server**: image `opencode-server:latest`, port 4096, volumes `/persist/containers/opencode:/root/.local/share/opencode`, optional plugin mount `/path/to/plugin:/root/.opencode/plugin:ro`, optional Graphiti mount `/path/to/graphiti:/root/.opencode/graphiti:ro`, environment from `/run/secrets/opencode.env`, health check `curl -f http://localhost:4096/config`.
- Configure `ExecStop`/`ExecStopPost` to stop and remove the pod gracefully.
- Set `Type=forking`, `RemainAfterExit=yes`, `After=network-online.target tailscaled.service onepassword-secrets.service`, and restart on failure with `RestartSec=10s`.
- Include acceptance criteria covering port exposure, intra-pod localhost communication, persistent state, and Datadog telemetry.

## Risks and Mitigations
- **Port conflicts**: Document published ports and require host availability checks before deployment.
- **Secret management**: Depend on `/run/secrets/opencode.env`; validate presence before startup.
- **Data persistence**: Use bind mounts under `/persist/containers/*` to avoid data loss between restarts.
- **Health checks**: Define explicit readiness commands to detect failed containers early.

## Rollout Plan
1. Review and approve this proposal under OpenSpec workflow.
2. Implement systemd unit(s) and Podman definitions per the spec.
3. Validate by starting the pod and confirming service health and port exposure.
4. Iterate on monitoring/telemetry if Datadog reporting gaps are found.

## Acceptance Criteria
- Pod `opencode-memory-pod` starts with Valkey, FalkorDB, Datadog Agent, and OpenCode containers sharing the same network namespace.
- Services listen on host ports 4096 (OpenCode), 6379/3000 (FalkorDB), 6380 (Valkey), and 8126 (Datadog APM) via Podman published ports.
- OpenCode reaches Valkey and FalkorDB over `localhost` within the pod.
- Persistent data stored under `/persist/containers/{valkey,falkordb,opencode}`.
- Datadog Agent gathers logs/APM/LLM observability metrics from all containers.
