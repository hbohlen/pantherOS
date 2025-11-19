#!/usr/bin/env bash
# Deployment Orchestrator for pantherOS
# Automates the build → dry-activate → switch workflow
# Usage: ./deploy.sh <hostname> [--build-only|--dry-run]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Arguments
HOSTNAME="${1:-}"
MODE="${2:-deploy}"  # deploy, build-only, dry-run
FLAKE_REF="${FLAKE_REF:-$HOSTNAME}"

# Validation
if [[ -z "$HOSTNAME" ]]; then
    echo -e "${RED}Error: hostname required${NC}" >&2
    echo ""
    echo "Usage: $0 <hostname> [--build-only|--dry-run]"
    echo ""
    echo "Modes:"
    echo "  (default)    Full deployment: build → dry-activate → switch"
    echo "  --build-only Only build the system, don't activate"
    echo "  --dry-run    Build and test without switching"
    echo ""
    echo "Examples:"
    echo "  $0 yoga                 # Deploy to yoga"
    echo "  $0 zephyrus --dry-run   # Test configuration on zephyrus"
    echo "  $0 hetzner-vps --build-only # Build only hetzner-vps config"
    exit 1
fi

# Check if host exists
if [[ ! -d "hosts/$HOSTNAME" ]]; then
    echo -e "${RED}Error: host '$HOSTNAME' not found${NC}" >&2
    echo "Available hosts:"
    ls -1 hosts/
    exit 1
fi

# Validate flake.nix exists
if [[ ! -f "flake.nix" ]]; then
    echo -e "${RED}Error: flake.nix not found${NC}" >&2
    echo "Run this script from the pantherOS root directory"
    exit 1
fi

# Get current generation
CURRENT_GEN=$(nix-store --query --roots /run/current-system 2>/dev/null | head -1 || echo "unknown")

# Log file
LOG_DIR="logs/deploy"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/deploy-$HOSTNAME-$(date +%Y%m%d-%H%M%S).log"

# Logging function
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Success function
success() {
    log "${GREEN}✓ $1${NC}"
}

# Error function
error() {
    log "${RED}✗ $1${NC}"
}

# Warning function
warning() {
    log "${YELLOW}⚠ $1${NC}"
}

# Info function
info() {
    log "${CYAN}ℹ $1${NC}"
}

# Header
clear
log "${BLUE}=== PantherOS Deployment Orchestrator ===${NC}"
log ""
info "Hostname: $HOSTNAME"
info "Mode: $MODE"
info "Log: $LOG_FILE"
log ""

# Step 1: Build
info "Step 1/3: Building system configuration..."
log "Command: nixos-rebuild build .#$HOSTNAME"
log "---"

if BUILD_OUTPUT=$(nixos-rebuild build .#$HOSTNAME 2>&1); then
    success "Build successful"
    BUILD_PATH=$(echo "$BUILD_OUTPUT" | grep "built successfully" | awk '{print $1}' || echo "")
    log "$BUILD_OUTPUT"
else
    error "Build failed"
    log "$BUILD_OUTPUT"
    log ""
    error "Deployment aborted"
    exit 1
fi

log ""

# Step 2: Dry-run (if not build-only)
if [[ "$MODE" == "build-only" ]]; then
    success "Build-only mode: skipping dry-run and switch"
    log ""
    info "To complete deployment, run: nixos-rebuild switch --flake .#$HOSTNAME"
    exit 0
fi

info "Step 2/3: Testing configuration (dry-run)..."
log "Command: nixos-rebuild dry-activate --flake .#$HOSTNAME"
log "---"

if DRY_OUTPUT=$(nixos-rebuild dry-activate --flake .#$HOSTNAME 2>&1); then
    success "Dry-run successful"
    log "$DRY_OUTPUT"
else
    error "Dry-run failed"
    log "$DRY_OUTPUT"
    log ""
    warning "Configuration test failed"
    warning "Review the logs above and fix issues before deploying"
    warning "You can still build: nixos-rebuild build .#$HOSTNAME"
    exit 1
fi

log ""

# Check for system warnings
if echo "$DRY_OUTPUT" | grep -i "warning" > /dev/null; then
    warning "Configuration has warnings - review carefully"
    echo "$DRY_OUTPUT" | grep -i "warning" | while read -r line; do
        warning "  $line"
    done
    log ""
fi

# Step 3: Deploy (if not dry-run)
if [[ "$MODE" == "dry-run" ]]; then
    success "Dry-run mode: configuration validated but not applied"
    log ""
    info "To deploy, run: nixos-rebuild switch --flake .#$HOSTNAME"
    exit 0
fi

info "Step 3/3: Deploying system..."
log "Command: nixos-rebuild switch --flake .#$HOSTNAME"
log "---"

# Ask for confirmation
if [[ ! -t 0 ]] || [[ ! -f /dev/tty ]]; then
    # Non-interactive mode (CI/CD or pipe)
    CONFIRM="y"
else
    echo -e "${YELLOW}WARNING: This will modify the live system!${NC}"
    echo -e "${YELLOW}Current generation: $CURRENT_GEN${NC}"
    echo ""
    read -r -p "Continue with deployment? (yes/no) " CONFIRM
fi

if [[ "$CONFIRM" != "yes" ]]; then
    info "Deployment cancelled by user"
    exit 0
fi

log ""
log "Deploying... (this may take a few minutes)"
log "---"

if SWITCH_OUTPUT=$(nixos-rebuild switch --flake .#$HOSTNAME 2>&1); then
    success "Deployment successful!"
    log "$SWITCH_OUTPUT"
else
    error "Deployment failed"
    log "$SWITCH_OUTPUT"
    log ""
    error "Attempting rollback..."
    log "---"

    if ROLLBACK_OUTPUT=$(nixos-rebuild switch --rollback 2>&1); then
        success "Rollback successful"
        log "$ROLLBACK_OUTPUT"
    else
        error "Rollback failed - manual intervention required"
        log "$ROLLBACK_OUTPUT"
        log ""
        error "Your system may be in an inconsistent state"
        error "Check logs: journalctl -xb"
        error "Or manually select previous generation at boot"
        exit 1
    fi
fi

log ""

# Show new generation
NEW_GEN=$(nix-store --query --roots /run/current-system 2>/dev/null | head -1 || echo "unknown")
info "Previous generation: $CURRENT_GEN"
info "New generation: $NEW_GEN"
log ""

# Post-deployment checks
info "Running post-deployment checks..."

# Check if systemd is running
if systemctl is-system-running > /dev/null 2>&1; then
    success "System is running"
else
    warning "System state unclear - check with: systemctl is-system-running"
fi

# Check critical services
for service in "systemd-hostnamed" "network.target" "systemd-logind"; do
    if systemctl is-active "$service" > /dev/null 2>&1; then
        success "$service is active"
    else
        warning "$service is not active"
    fi
done

log ""
success "Deployment complete!"
log ""
log "Next steps:"
log "  - Verify system is working: systemctl status"
log "  - Check logs if needed: journalctl -xb"
log "  - Monitor system health: htop, iotop"
log ""

# Save deployment info
cat > "$LOG_DIR/deploy-$HOSTNAME-$(date +%Y%m%d).info" << EOF
Deployment Information
=====================

Hostname: $HOSTNAME
Date: $(date)
Mode: $MODE
Build Path: $BUILD_PATH
Previous Generation: $CURRENT_GEN
New Generation: $NEW_GEN
Log File: $LOG_FILE

Status: SUCCESS

EOF

success "Deployment log saved to: $LOG_FILE"
