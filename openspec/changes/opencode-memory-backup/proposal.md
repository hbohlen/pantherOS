# Change Proposal: Automated Btrfs Snapshots and Backblaze B2 Backups for OpenCode Memory

## Summary
Create systemd-managed automation on `hosts/hetzner-vps/opencode-memory.nix` that produces Btrfs snapshots and uploads OpenCode memory data to Backblaze B2 every six hours. The change introduces an `opencode-backup.service` oneshot unit and an `opencode-backup.timer` that trigger snapshot creation, rclone uploads of FalkorDB and Valkey data, Graphiti exports via `memory_manager.py`, and retention cleanup of aged Btrfs snapshots.

## Goals
- Ensure recurring backups of FalkorDB, Valkey, and Graphiti exports land in a B2 bucket with timestamped prefixes.
- Capture consistent point-in-time data using Btrfs subvolume snapshots before uploads.
- Run unattended on a 6-hour cadence with persistence across reboots and minimal manual intervention.
- Enforce snapshot retention of 30 days to control disk usage.

## Non-Goals
- Replacing or redesigning existing pod/service orchestration for OpenCode.
- Providing restore workflows from B2 (future work).
- Encrypting backups; rely on B2 controls and environment-provided credentials.

## Success Criteria
- Timer fires every six hours (including catch-up after downtime) and executes the backup service without manual triggers.
- Snapshots appear under `/.snapshots/` with timestamped names preceding each upload run.
- B2 bucket `opencode-memory-backups` contains per-run prefixes for FalkorDB, Valkey, and Graphiti export artifacts.
- Snapshots older than 30 days are removed automatically after each run.
- Failures do not halt future runs; next timer invocation re-attempts backup.

## Risks & Mitigations
- **Credential issues**: Missing `B2_KEY_ID`/`B2_APP_KEY` would fail uploads. Mitigation: service sources `/run/secrets/opencode.env` and should fail fast with clear logs.
- **Disk usage growth**: Snapshot accumulation could consume space. Mitigation: daily cleanup (30-day retention) baked into the service steps.
- **Snapshot failure**: If Btrfs snapshot creation fails, uploads might be inconsistent. Mitigation: fail the oneshot early before uploads; log errors for diagnosis.
- **Upload latency/bandwidth**: Large graphs may slow uploads. Mitigation: oneshot unit design tolerates long runtime; timer persistence ensures eventual consistency.

## Proposed Implementation
1. Define `opencode-backup.service` (Type=oneshot, User=opencode, After=opencode-memory-pod.service, EnvironmentFile=/run/secrets/opencode.env) that executes a shell script performing snapshot creation, rclone uploads for FalkorDB and Valkey paths, Graphiti export via `python3 /root/.opencode/graphiti/memory_manager.py export`, and snapshot cleanup older than 30 days.
2. Add `opencode-backup.timer` with `OnCalendar=0/6:00:00` and `Persistent=true` to trigger the service every six hours, catching up missed runs after downtime.
3. Emit timestamped destination prefixes such as `falkordb-{timestamp}` and `valkey-{timestamp}` under `s3:opencode-memory-backups` using the Backblaze S3 endpoint `s3.us-west-004.backblazeb2.com` configured via rclone environment.
4. Integrate both units into `hosts/hetzner-vps/opencode-memory.nix`, ensuring they are enabled alongside the existing pod orchestration.
5. Document acceptance expectations and validation steps within accompanying design/spec/tasks files.

## Alternatives Considered
- Running backups from within the OpenCode pod: rejected to keep backup credentials and tooling on the host side and avoid container resource coupling.
- Using plain cron instead of systemd timer: rejected to maintain consistent systemd-managed lifecycle, logging, and persistence guarantees.

## Rollout Plan
- Add units disabled by default, then enable for hetzner-vps host in `opencode-memory.nix`.
- Deploy to hetzner-vps, monitor first scheduled run logs for success.
- Iterate on scheduling or retention thresholds based on observed storage and upload durations.

## Open Questions
- Should uploads be throttled/bandwidth-limited? (Not specified; default to unrestricted.)
- Should snapshots be compressed prior to upload? (Out of scope for this proposal.)
