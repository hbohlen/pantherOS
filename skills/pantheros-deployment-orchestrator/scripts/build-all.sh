#!/usr/bin/env bash
# Build All Hosts - Parallel system builder for pantherOS
# Tests all host configurations in parallel
# Usage: ./build-all.sh [--jobs N]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Arguments
JOBS="${1:-}"

# Log file
LOG_DIR="logs/build"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/build-all-$(date +%Y%m%d-%H%M%S).log"

# Logging functions
log() { echo -e "$1" | tee -a "$LOG_FILE"; }
success() { log "${GREEN}✓ $1${NC}"; }
error() { log "${RED}✗ $1${NC}"; }
info() { log "${BLUE}ℹ $1${NC}"; }

# Get list of hosts
HOSTS=$(find hosts -maxdepth 1 -type d -not -path "hosts" | sed 's|hosts/||' | sort)

if [[ -z "$HOSTS" ]]; then
    error "No hosts found in hosts/ directory"
    exit 1
fi

# Header
clear
log "${BLUE}=== PantherOS Parallel Build Tool ===${NC}"
log ""
info "Building all host configurations..."
log "Hosts: $(echo $HOSTS | tr '\n' ' ')"
log "Log: $LOG_FILE"
log ""

# Build function
build_host() {
    local host=$1
    local log_file="logs/build/build-$host-$(date +%Y%m%d-%H%M%S).log"

    log "${BLUE}Building $host...${NC}"

    if nixos-rebuild build .#$host > "$log_file" 2>&1; then
        success "✓ $host"
        return 0
    else
        error "✗ $host"
        return 1
    fi
}

# Export functions for parallel
export -f build_host
export -f log
export -f success
export -f error
export -f info

# Build all hosts in parallel
if [[ -n "$JOBS" ]]; then
    info "Building with $JOBS parallel jobs..."
    echo "$HOSTS" | tr ' ' '\n' | xargs -P "$JOBS" -I {} bash -c 'build_host "$@"' _ {}
else
    info "Building with auto-detected parallel jobs..."
    echo "$HOSTS" | tr ' ' '\n' | xargs -P $(nproc) -I {} bash -c 'build_host "$@"' _ {}
fi

log ""
log "=== Build Summary ==="
log ""

# Check results
PASSED=0
FAILED=0

for host in $HOSTS; do
    if ls logs/build/build-$host-*.log 2>/dev/null | tail -1 | xargs grep -q "built successfully" 2>/dev/null; then
        log "${GREEN}✓ $host${NC}"
        PASSED=$((PASSED + 1))
    else
        log "${RED}✗ $host${NC}"
        log "  Log: logs/build/build-$host-*.log"
        FAILED=$((FAILED + 1))
    fi
done

log ""
info "Passed: $PASSED"
info "Failed: $FAILED"
info "Total: $((PASSED + FAILED))"

if [[ $FAILED -eq 0 ]]; then
    success "All hosts built successfully!"
    exit 0
else
    error "Some hosts failed to build"
    exit 1
fi
