# Tasks: OpenCode Memory Pod Orchestration

## Implementation Roadmap
This document enumerates the ordered tasks required to deliver the OpenCode memory pod using systemd and Podman with shared networking.

### Phase 1: Specification Finalization
**Objective**: Confirm scope, dependencies, and environment inputs before implementation.

- [ ] Validate `/run/secrets/opencode.env` presence and required keys for Datadog and OpenCode.
- [ ] Confirm host paths for persistent volumes under `/persist/containers/{valkey,falkordb,opencode}`.
- [ ] Decide plugin and Graphiti mount paths or confirm they remain disabled.
- [ ] Verify published port availability on host: 4096, 6379, 6380, 3000, 8126.

### Phase 2: Pod and Container Definitions
**Objective**: Author Podman pod and container definitions consistent with the design.

- [ ] Define Podman pod `opencode-memory-pod` with published ports and shared network namespace.
- [ ] Specify Valkey container: image `valkey/valkey:7.2`, args, volume, health check.
- [ ] Specify FalkorDB container: image `falkordb/falkordb:latest`, env `REDIS_ARGS`, volume, ports.
- [ ] Specify Datadog Agent container: environment file, observability env vars, Podman socket mount.
- [ ] Specify OpenCode container: image reference, volumes, optional plugin/Graphiti mounts, health check.

### Phase 3: systemd Unit Authoring
**Objective**: Encode orchestration flow in a systemd service with ordered startup.

- [ ] Add `opencode-memory-pod.service` with `Type=forking` and `RemainAfterExit=yes`.
- [ ] Implement `ExecStartPre` sequence: create pod → start Valkey → start FalkorDB → start Datadog.
- [ ] Implement `ExecStart` to launch OpenCode container.
- [ ] Implement `ExecStop` and `ExecStopPost` to stop and remove pod gracefully.
- [ ] Set `After=network-online.target tailscaled.service onepassword-secrets.service` and `Wants=network-online.target`.
- [ ] Apply restart policy `Restart=on-failure` with `RestartSec=10s`.

### Phase 4: Validation and Acceptance
**Objective**: Prove the deployment meets acceptance criteria.

- [ ] Start pod and verify containers share network namespace (`localhost` connectivity tests).
- [ ] Confirm host access: OpenCode 4096, FalkorDB 6379/3000, Valkey 6380, Datadog APM 8126.
- [ ] Check persistence under `/persist/containers/*` after restart.
- [ ] Validate Datadog Agent telemetry collection for logs/APM/LLM.
