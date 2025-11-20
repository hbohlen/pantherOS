# Design: Automated Snapshots and Backblaze Backups for OpenCode Memory

## Overview
This design introduces systemd automation on the hetzner-vps host to snapshot OpenCode memory data and upload it to Backblaze B2. A oneshot service orchestrates Btrfs snapshot creation, rclone syncs for FalkorDB and Valkey data, a Graphiti export via the Python memory manager, and retention cleanup. A companion timer schedules runs every six hours with persistence across reboots.

## Components
- **opencode-backup.service**: Oneshot unit (User=opencode) that performs the full backup sequence after the OpenCode pod is available. Uses `/run/secrets/opencode.env` for Backblaze credentials and environment setup.
- **opencode-backup.timer**: Systemd timer with `OnCalendar=0/6:00:00` and `Persistent=true` to execute the service every six hours and catch up missed events.
- **Btrfs Snapshots**: Subvolume snapshots under `/.snapshots/persist-<timestamp>` capturing `/persist` before uploads to ensure consistency.
- **rclone Uploads**: S3-compatible uploads targeting `s3:opencode-memory-backups/<dataset>-<timestamp>` using endpoint `s3.us-west-004.backblazeb2.com` and B2 credentials from env vars.
- **Graphiti Export**: Use the Graphiti memory manager from the full OpenAgents developer package (https://github.com/darrenhinde/OpenAgents) to write a JSON export that the service uploads via `b2sdk` (per existing script behavior).
- **Snapshot Cleanup**: Retention enforcement deleting Btrfs snapshots older than 30 days using `find` + `btrfs subvolume delete`.

## Backup Flow
1. **Preconditions**: Ensure `opencode-memory-pod.service` has started; the backup service declares `After=opencode-memory-pod.service` to avoid racing data directories.
2. **Timestamp Generation**: Compute a UTC timestamp (e.g., `2025-01-01T12-00-00Z`) reused for snapshot names and B2 prefixes for correlation.
3. **Create Snapshot**: `btrfs subvolume snapshot /persist /.snapshots/persist-<timestamp>` to capture a consistent view before uploads.
4. **Upload FalkorDB Data**: `rclone sync /persist/containers/falkordb s3:opencode-memory-backups/falkordb-<timestamp> --s3-provider Other --s3-endpoint s3.us-west-004.backblazeb2.com` using `B2_KEY_ID`/`B2_APP_KEY` from the environment.
5. **Upload Valkey Data**: `rclone sync /persist/containers/valkey s3:opencode-memory-backups/valkey-<timestamp> ...` with the same endpoint/auth options.
6. **Graphiti Export**: Run the memory manager export command; the script itself uploads to B2 via `b2sdk` using env credentials.
7. **Snapshot Cleanup**: `find /.snapshots/ -maxdepth 1 -mtime +30 -type d -exec btrfs subvolume delete {} \;` to prune old snapshots.
8. **Logging & Exit**: Surface errors via systemd journal; failures mark the unit failed but timer will re-run later.

## Security & Secrets
- Credentials come from `/run/secrets/opencode.env` (contains `B2_KEY_ID`, `B2_APP_KEY`), sourced by the service; avoid logging sensitive values.
- Service runs as `opencode` user to limit privileges; snapshot and upload commands may require appropriate permissions (validated during implementation).
- No credential material is written to disk beyond existing secrets file.

## Observability & Operations
- Rely on systemd journal for run logs and exit codes; timer persistence ensures retries on next elapsed time.
- Timestamped prefixes aid correlating uploads with snapshots; consider future metrics via Datadog, but out of scope here.

## Failure Modes
- **Snapshot failure**: Abort subsequent steps to avoid inconsistent uploads; unit exits non-zero.
- **Upload failure**: Leave snapshot intact; subsequent timer run retries with a new timestamp.
- **Graphiti export failure**: Log error; unit still fails so next timer run re-attempts.

## Deployment Notes
- Configuration lives in `hosts/hetzner-vps/opencode-memory.nix` alongside existing OpenCode pod definitions.
- Ensure `/.snapshots` exists and `/persist` is a Btrfs subvolume; if absent, backup service should log and fail clearly.
- Validate that rclone and btrfs tools are available on the host profile or add them as needed when wiring the unit commands.
