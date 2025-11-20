# Tasks: Automated Backups for OpenCode Memory

## Phase 1: Validation and Preconditions
- Verify `/persist` is a Btrfs subvolume and `/.snapshots` directory exists (create if absent).
- Ensure `rclone`, `btrfs-progs`, and Python are available in the hetzner-vps environment.
- Confirm `/run/secrets/opencode.env` provides `B2_KEY_ID` and `B2_APP_KEY` credentials.

## Phase 2: Unit Definitions
- Add `opencode-backup.service` to `hosts/hetzner-vps/opencode-memory.nix` as `Type=oneshot`, `User=opencode`, `After=opencode-memory-pod.service`, sourcing `/run/secrets/opencode.env`.
- Implement service script steps: timestamp generation, Btrfs snapshot of `/persist`, rclone sync for FalkorDB and Valkey directories, Graphiti export invocation, and snapshot cleanup >30 days.
- Add `opencode-backup.timer` with `OnCalendar=0/6:00:00` and `Persistent=true`, linked to the service.

## Phase 3: Scheduling and Enablement
- Enable both units in `opencode-memory.nix` for hetzner-vps; ensure proper ordering with existing OpenCode pod service.
- Validate unit files via `systemctl cat/status` in a build or test environment.

## Phase 4: Verification
- Trigger a manual `systemctl start opencode-backup.service` and inspect logs for snapshot creation, uploads, Graphiti export, and cleanup actions.
- Confirm B2 bucket `opencode-memory-backups` receives timestamped FalkorDB, Valkey, and Graphiti artifacts.
- Check `/.snapshots` retention behavior after 30+ days (or by adjusting `-mtime` in a test) to verify cleanup logic.
