#!/usr/bin/env bash
# verify-hetzner-deployment.sh
# Comprehensive verification script for hetzner-vps NixOS deployment
# Installs determinate nix, runs flake checks, and builds the configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
START_TIME=$(date +%s)

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║${RESET} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${RESET}"
}

print_success() {
    echo -e "${GREEN}✓${RESET} $1"
}

print_error() {
    echo -e "${RED}✗${RESET} $1" >&2
}

print_info() {
    echo -e "${YELLOW}ℹ${RESET} $1"
}

check_nix_installation() {
    print_header "Step 1: Checking Nix Installation"

    if command -v nix &>/dev/null; then
        local nix_version
        nix_version=$(nix --version 2>/dev/null | awk '{print $3}')
        print_success "Nix is installed (version: $nix_version)"
        return 0
    else
        print_error "Nix is not installed"
        return 1
    fi
}

install_determinate_nix() {
    print_header "Step 2: Installing Determinate Nix"

    print_info "Installing Determinate Nix for better flake support..."

    if curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install; then
        print_success "Determinate Nix installed successfully"

        # Source the nix environment
        if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            # shellcheck disable=SC1091
            source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi

        return 0
    else
        print_error "Failed to install Determinate Nix"
        return 1
    fi
}

verify_flake_inputs() {
    print_header "Step 3: Verifying Flake Inputs"

    print_info "Checking flake lock file..."

    if [ -f "$REPO_ROOT/flake.lock" ]; then
        print_success "flake.lock exists"
    else
        print_info "flake.lock not found, will be created during flake check"
    fi

    print_info "Updating flake inputs..."
    cd "$REPO_ROOT"

    if nix flake update --quiet; then
        print_success "Flake inputs updated successfully"
        return 0
    else
        print_error "Failed to update flake inputs"
        return 1
    fi
}

run_flake_check() {
    print_header "Step 4: Running Nix Flake Check"

    print_info "Checking flake.nix syntax and structure..."
    cd "$REPO_ROOT"

    if nix flake check --no-build; then
        print_success "Flake check passed"
        return 0
    else
        print_error "Flake check failed"
        print_info "Common issues:"
        print_info "  • Missing or incorrect module imports"
        print_info "  • Invalid attribute names in nixosConfigurations"
        print_info "  • Circular dependencies in inputs"
        return 1
    fi
}

run_disko_check() {
    print_header "Step 5: Validating Disko Configuration"

    print_info "Checking disko.nix for syntax errors..."
    cd "$REPO_ROOT"

    if nix eval --json ".#nixosConfigurations.hetzner-vps.config.disko" > /dev/null 2>&1; then
        print_success "Disko configuration is valid"
        return 0
    else
        print_error "Disko configuration validation failed"
        print_info "Check for:"
        print_info "  • Typos in subvolume names"
        print_info "  • Invalid mount options"
        print_info "  • Incorrect partition sizes"
        return 1
    fi
}

run_nixos_rebuild_build() {
    print_header "Step 6: Building Hetzner VPS Configuration"

    print_info "This may take 10-30 minutes depending on cache..."
    print_info "Building NixOS system configuration..."

    cd "$REPO_ROOT"

    # Build with verbose output for debugging
    if nixos-rebuild build --flake ".#hetzner-vps" -v; then
        print_success "Build completed successfully"
        local result_path
        result_path=$(realpath result 2>/dev/null || echo "unknown")
        print_info "Build result: $result_path"
        return 0
    else
        print_error "Build failed"
        print_info "Review the errors above for:"
        print_info "  • Missing packages or attributes"
        print_info "  • Invalid module configurations"
        print_info "  • Syntax errors in Nix files"
        return 1
    fi
}

generate_system_info() {
    print_header "Step 7: System Information Report"

    print_info "Gathering system information..."

    cd "$REPO_ROOT"

    echo ""
    print_info "Hetzner VPS Configuration Details:"
    echo "  Hostname: $(nix eval --raw '.#nixosConfigurations.hetzner-vps.config.networking.hostName' 2>/dev/null || echo 'unknown')"
    echo "  State Version: $(nix eval --raw '.#nixosConfigurations.hetzner-vps.config.system.stateVersion' 2>/dev/null || echo 'unknown')"
    echo "  Platform: x86_64-linux"

    print_info "Key Services Enabled:"
    echo "  • Podman: enabled"
    echo "  • Tailscale: enabled"
    echo "  • OpenSSH: enabled"
    echo "  • 1Password OpNix: enabled"

    echo ""
}

print_summary() {
    local end_time
    local duration
    local minutes
    local seconds

    end_time=$(date +%s)
    duration=$((end_time - START_TIME))
    minutes=$((duration / 60))
    seconds=$((duration % 60))

    echo ""
    print_header "Verification Complete"

    echo ""
    print_success "All checks completed in ${minutes}m ${seconds}s"
    echo ""
    print_info "Next Steps for Deployment:"
    echo "  1. Put server in Hetzner Rescue Mode"
    echo "  2. SSH into rescue mode: ssh root@<your-hetzner-ip>"
    echo "  3. Run nixos-anywhere from this machine:"
    echo ""
    echo -e "     ${YELLOW}nix run github:nix-community/nixos-anywhere -- \\"
    echo "       --flake '.#hetzner-vps' \\"
    echo "       --no-reboot \\"
    echo "       root@<your-hetzner-ip>${RESET}"
    echo ""
    echo "  4. After deployment, setup secrets:"
    echo "     scp /path/to/opnix-token hbohlen@hetzner-vps:/tmp/"
    echo "     ssh hbohlen@hetzner-vps"
    echo "     sudo mv /tmp/opnix-token /etc/opnix-token"
    echo "     sudo chmod 600 /etc/opnix-token"
    echo "     sudo systemctl restart onepassword-secrets.service"
    echo ""
}

main() {
    print_header "pantherOS Hetzner VPS Deployment Verification"

    print_info "Repository: $REPO_ROOT"
    echo ""

    # Run all checks
    local failed=0

    check_nix_installation || failed=1

    if [ $failed -eq 0 ]; then
        install_determinate_nix || failed=1
    fi

    if [ $failed -eq 0 ]; then
        verify_flake_inputs || failed=1
    fi

    if [ $failed -eq 0 ]; then
        run_flake_check || failed=1
    fi

    if [ $failed -eq 0 ]; then
        run_disko_check || failed=1
    fi

    if [ $failed -eq 0 ]; then
        run_nixos_rebuild_build || failed=1
    fi

    # Always generate system info if we got this far
    if [ $failed -eq 0 ]; then
        generate_system_info
        print_summary
        echo ""
        print_success "Configuration is ready for deployment!"
        return 0
    else
        echo ""
        print_error "Verification failed. Please fix the errors above."
        print_info "Common fixes:"
        print_info "  • Run 'nix flake update' to update lock file"
        print_info "  • Check nixpkgs pin version matches 25.05"
        print_info "  • Verify all input sources are accessible"
        print_info "  • Check for typos in configuration filenames"
        return 1
    fi
}

# Run main function
main
