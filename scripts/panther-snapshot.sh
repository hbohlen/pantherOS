#!/bin/bash
# panther-snapshot - Manual Snapshot Management Script
# Convenient wrapper for snapper operations
#
# Usage:
#   panther-snapshot create [description]  - Create a manual snapshot
#   panther-snapshot list [subvolume]      - List snapshots for subvolume
#   panther-snapshot delete <number>       - Delete snapshot by number
#   panther-snapshot restore-info <number> - Show restore info for snapshot
#   panther-snapshot help                  - Show this help message

set -euo pipefail

# ===== CONFIGURATION =====
SNAPPER_BIN="${SNAPPER_BIN:-snapper}"
DEFAULT_SUBNVOLUME="@"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ===== HELPER FUNCTIONS =====
print_help() {
  cat << 'EOF'
panther-snapshot - Manual Snapshot Management Script

DESCRIPTION
    panther-snapshot provides convenient commands for creating, listing,
    and managing Btrfs snapshots using snapper.

COMMANDS
    create [description] [subvolume]
        Create a manual snapshot with optional description.
        If subvolume is omitted, defaults to '@' (root filesystem).

        Examples:
            panther-snapshot create "Before system update"
            panther-snapshot create "Pre-database migration" "@home"
            panther-snapshot create

    list [subvolume]
        List all snapshots for the specified subvolume.
        If subvolume is omitted, shows snapshots for '@'.

        Examples:
            panther-snapshot list
            panther-snapshot list "@home"

    delete <number>
        Delete snapshot with the specified number.
        Prompts for confirmation before deletion.

        Examples:
            panther-snapshot delete 42

    restore-info <number>
        Show detailed information about a snapshot and how to restore it.
        Includes snapshot metadata, creation time, and restoration instructions.

        Examples:
            panther-snapshot restore-info 42

    help
        Show this help message.

SUBSVOLUMES
    Common subvolumes:
        @       Root filesystem (/)
        @home   Home directory (/home)
        @nix    Nix store (/nix)
        @log    System logs (/var/log)

EXIT CODES
    0   Success
    1   Error (invalid arguments, snapper command failed, etc.)
    2   User cancelled operation

ENVIRONMENT VARIABLES
    SNAPPER_BIN    Path to snapper binary (default: snapper)

EOF
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
}

print_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

print_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

# ===== COMMAND FUNCTIONS =#

cmd_create() {
    local description="${1:-}"
    local subvolume="${2:-$DEFAULT_SUBNVOLUME}"

    # Build snapper create command
    local snapper_args=(
        "create"
        "--type" "single"
        "--cleanup-algorithm" "number"
        "--subvolume" "$subvolume"
    )

    # Add description if provided
    if [[ -n "$description" ]]; then
        snapper_args+=("--description" "$description")
    else
        snapper_args+=("--description" "Manual snapshot")
    fi

    print_info "Creating snapshot for subvolume: $subvolume"
    [[ -n "$description" ]] && print_info "Description: $description"

    # Execute snapper create
    local snapshot_num
    snapshot_num=$($SNAPPER_BIN "${snapper_args[@]}" 2>&1) || {
        print_error "Failed to create snapshot"
        return 1
    }

    print_success "Snapshot created: #$snapshot_num"
    print_info "Subvolume: $subvolume"
    return 0
}

cmd_list() {
    local subvolume="${1:-$DEFAULT_SUBNVOLUME}"

    print_info "Listing snapshots for subvolume: $subvolume"
    echo ""

    # Get list of snapshots
    if ! $SNAPPER_BIN list "$subvolume" 2>&1; then
        print_error "Failed to list snapshots for subvolume: $subvolume"
        return 1
    fi

    echo ""
    print_info "Total snapshots listed above"
    return 0
}

cmd_delete() {
    local snapshot_num="$1"

    # Validate snapshot number
    if [[ -z "$snapshot_num" ]]; then
        print_error "Snapshot number is required"
        print_info "Usage: $0 delete <number>"
        return 1
    fi

    if [[ ! "$snapshot_num" =~ ^[0-9]+$ ]]; then
        print_error "Invalid snapshot number: $snapshot_num"
        print_info "Snapshot number must be a positive integer"
        return 1
    fi

    # Get snapshot info before deletion
    local snapshot_info
    if ! snapshot_info=$($SNAPPER_BIN list "$DEFAULT_SUBNVOLUME" 2>&1 | grep "^ $snapshot_num " 2>/dev/null); then
        print_error "Snapshot #$snapshot_num not found"
        return 1
    fi

    print_warning "About to delete snapshot #$snapshot_num"
    echo "$snapshot_info"
    echo ""
    read -p "Are you sure? (yes/no): " -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Deletion cancelled"
        return 2
    fi

    # Delete snapshot
    print_info "Deleting snapshot #$snapshot_num..."
    if $SNAPPER_BIN delete "$snapshot_num" 2>&1; then
        print_success "Snapshot #$snapshot_num deleted successfully"
        return 0
    else
        print_error "Failed to delete snapshot #$snapshot_num"
        return 1
    fi
}

cmd_restore_info() {
    local snapshot_num="$1"

    # Validate snapshot number
    if [[ -z "$snapshot_num" ]]; then
        print_error "Snapshot number is required"
        print_info "Usage: $0 restore-info <number>"
        return 1
    fi

    if [[ ! "$snapshot_num" =~ ^[0-9]+$ ]]; then
        print_error "Invalid snapshot number: $snapshot_num"
        print_info "Snapshot number must be a positive integer"
        return 1
    fi

    # Get snapshot details
    print_info "Snapshot #$snapshot_num details:"
    echo ""

    # Show the snapshot listing
    if ! $SNAPPER_BIN list "$DEFAULT_SUBNVOLUME" 2>&1 | grep "^ $snapshot_num " 2>/dev/null; then
        print_error "Snapshot #$snapshot_num not found"
        return 1
    fi

    echo ""

    # Show detailed information
    print_info "Snapshot metadata:"
    $SNAPPER_BIN show "$snapshot_num" 2>&1 || true

    echo ""
    print_info "Restore instructions:"
    cat << 'RESTORE_EOF'
To restore from this snapshot, you have several options:

1. BOOT INTO SNAPSHOT:
   - Reboot your system
   - At GRUB menu, select "Advanced options for NixOS"
   - Select the snapshot you want to restore
   - This will boot into the snapshot without modifying the current system

2. ROLLBACK TO SNAPSHOT:
   - Boot into the snapshot (option 1)
   - Once booted, run:
     sudo snapper rollback
   - Reboot your system
   - The rollback will be reflected in the default GRUB entry

3. MOUNT SNAPSHOT DIRECTLY:
   - sudo mkdir -p /mnt/snapshot
   - sudo mount -o subvol=@/.snapshots/<number>/snapshot /dev/<btrfs-device> /mnt/snapshot
   - Browse and copy files as needed
   - sudo umount /mnt/snapshot

WARNING: Rolling back to a snapshot will permanently delete all changes
made after the snapshot was created!

For more information: man snapper-rollback
RESTORE_EOF

    return 0
}

# ===== MAIN =#

# Check if snapper is available
if ! command -v "$SNAPPER_BIN" &> /dev/null; then
    print_error "snapper command not found. Is snapper installed and enabled?"
    exit 1
fi

# Parse command
if [[ $# -eq 0 ]]; then
    print_error "No command specified"
    echo ""
    print_info "Run '$0 help' for usage information"
    exit 1
fi

command="$1"
shift

# Execute command
case "$command" in
    create)
        cmd_create "$@"
        ;;
    list)
        cmd_list "$@"
        ;;
    delete)
        cmd_delete "$@"
        ;;
    restore-info)
        cmd_restore_info "$@"
        ;;
    help|--help|-h)
        print_help
        exit 0
        ;;
    *)
        print_error "Unknown command: $command"
        echo ""
        print_info "Run '$0 help' for usage information"
        exit 1
        ;;
esac

exit $?
