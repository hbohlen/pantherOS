#!/usr/bin/env bash
# Rollback utility for pantherOS
# Lists and manages system generations
# Usage: ./rollback.sh [hostname] [--list|--rollback N]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Arguments
HOSTNAME="${1:-}"
ACTION="${2:-list}"
GENERATION="${3:-}"

# Validation
if [[ -z "$HOSTNAME" ]]; then
    HOSTNAME="$(hostname)"
fi

# Header
clear
echo -e "${BLUE}=== PantherOS Rollback Utility ===${NC}"
echo ""
echo "Host: $HOSTNAME"
echo "Action: $ACTION"
echo ""

# List generations
list_generations() {
    echo "Available Generations:"
    echo ""

    nixos-rebuild list-generations --flake .#$HOSTNAME | while read -r line; do
        if [[ "$line" =~ current ]]; then
            echo -e "${GREEN}$line${NC}"
        else
            echo "$line"
        fi
    done
}

# Rollback to specific generation
rollback_to() {
    local gen=$1

    if [[ -z "$gen" ]]; then
        echo -e "${RED}Error: generation number required${NC}" >&2
        echo "Usage: $0 $HOSTNAME rollback <generation-number>"
        exit 1
    fi

    echo -e "${YELLOW}WARNING: Rolling back to generation $gen${NC}"
    echo "This will revert all system changes since that generation."
    echo ""

    # Ask for confirmation
    read -r -p "Continue? (yes/no) " CONFIRM

    if [[ "$CONFIRM" != "yes" ]]; then
        echo "Rollback cancelled"
        exit 0
    fi

    echo ""
    echo "Rolling back..."
    if nixos-rebuild switch --generation "$gen" --flake .#$HOSTNAME; then
        echo ""
        echo -e "${GREEN}Rollback successful${NC}"
    else
        echo ""
        echo -e "${RED}Rollback failed${NC}"
        exit 1
    fi
}

# Rollback to previous generation
rollback_prev() {
    echo "Rolling back to previous generation..."
    echo ""

    if nixos-rebuild switch --rollback --flake .#$HOSTNAME; then
        echo ""
        echo -e "${GREEN}Rollback successful${NC}"
    else
        echo ""
        echo -e "${RED}Rollback failed${NC}"
        exit 1
    fi
}

# Main logic
case "$ACTION" in
    list)
        list_generations
        ;;
    rollback)
        if [[ -n "$GENERATION" ]]; then
            rollback_to "$GENERATION"
        else
            rollback_prev
        fi
        ;;
    *)
        echo -e "${RED}Error: invalid action '$ACTION'${NC}" >&2
        echo ""
        echo "Usage: $0 [hostname] [--list|--rollback [N]]"
        echo ""
        echo "Actions:"
        echo "  --list                List all generations (default)"
        echo "  --rollback            Rollback to previous generation"
        echo "  --rollback N          Rollback to generation N"
        echo ""
        echo "Examples:"
        echo "  $0 yoga --list                    # List yoga generations"
        echo "  $0 zephyrus --rollback            # Rollback zephyrus"
        echo "  $0 hetzner-vps --rollback 123     # Rollback to generation 123"
        exit 1
        ;;
esac
