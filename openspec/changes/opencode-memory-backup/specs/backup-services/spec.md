# Specification: Systemd Backup Automation for OpenCode Memory

## Problem Statement
OpenCode's memory components (FalkorDB graph, Valkey cache data, and Graphiti exports) require automated, reliable backups to Backblaze B2 with point-in-time consistency. Backups should run unattended on the hetzner-vps host, include retention management for local snapshots, and tolerate transient failures by retrying on the next schedule.

## Requirements

### Services and Scheduling
- Define `opencode-backup.service` as `Type=oneshot`, `User=opencode`, `After=opencode-memory-pod.service`, and `EnvironmentFile=/run/secrets/opencode.env`.
- Define `opencode-backup.timer` with `OnCalendar=0/6:00:00` (every 6 hours) and `Persistent=true` so missed events run after reboot.
- Both units live in `hosts/hetzner-vps/opencode-memory.nix` and are enabled for hetzner-vps.

### Snapshot Creation
- Before uploads, create a Btrfs snapshot of `/persist` named `/.snapshots/persist-<timestamp>`, where `<timestamp>` is an ISO-like UTC string usable in paths (e.g., `2025-01-01T12-00-00Z`).
- Snapshot step must run once per backup invocation and fail the service if snapshot creation fails.

### Backblaze B2 Uploads (via rclone)
- Upload FalkorDB data from `/persist/containers/falkordb` to `s3:opencode-memory-backups/falkordb-<timestamp>`.
- Upload Valkey data from `/persist/containers/valkey` to `s3:opencode-memory-backups/valkey-<timestamp>`.
- rclone must be configured with:
  - `--s3-provider Other`
  - `--s3-endpoint s3.us-west-004.backblazeb2.com`
  - Authentication via env vars `B2_KEY_ID` and `B2_APP_KEY` from `/run/secrets/opencode.env`.

### Graphiti Export
- Invoke the Graphiti memory manager from the full OpenAgents developer package (https://github.com/darrenhinde/OpenAgents) to produce a JSON export and upload it to the B2 bucket via existing `b2sdk` logic.
- Use the same `<timestamp>` for associating this export with the snapshot window (e.g., include in logs or rely on script naming convention).

### Retention and Cleanup
- After uploads, delete Btrfs snapshots in `/.snapshots/` older than 30 days using `find /.snapshots/ -maxdepth 1 -mtime +30 -exec btrfs subvolume delete {} \;` (or equivalent handling that preserves the top-level directory).
- Cleanup should ignore errors deleting already-removed subvolumes but log failures.

### Error Handling and Idempotence
- If any step fails (snapshot, upload, export), the oneshot should exit non-zero; the timer will re-attempt on the next scheduled run.
- Avoid leaving partial configuration changes; snapshots may remain if uploads fail, which is acceptable for retry safety.

## Acceptance Criteria
- `opencode-backup.timer` triggers the service every six hours and catches up after downtime.
- Each run creates a `/.snapshots/persist-<timestamp>` snapshot before uploads.
- Backblaze bucket `opencode-memory-backups` contains timestamped directories for FalkorDB and Valkey plus the Graphiti export artifact.
- Snapshots older than 30 days are removed automatically during the backup run.
- Manual execution `systemctl start opencode-backup.service` completes without errors when credentials and directories exist.
