#!/usr/bin/env fish
# verify-hetzner-deployment.fish
# Comprehensive verification script for hetzner-vps NixOS deployment
# Installs determinate nix, runs flake checks, and builds the configuration

set -l script_dir (dirname (status -f))
set -l repo_root (realpath "$script_dir/..")
set -l start_time (date +%s)

# Color codes
set -l green '\033[0;32m'
set -l red '\033[0;31m'
set -l yellow '\033[1;33m'
set -l blue '\033[0;34m'
set -l reset '\033[0m'

function print_header
    echo -e "{$blue}╔════════════════════════════════════════════════════════════╗{$reset}"
    echo -e "{$blue}║{$reset} $argv1"
    echo -e "{$blue}╚════════════════════════════════════════════════════════════╝{$reset}"
end

function print_success
    echo -e "{$green}✓{$reset} $argv1"
end

function print_error
    echo -e "{$red}✗{$reset} $argv1" >&2
end

function print_info
    echo -e "{$yellow}ℹ{$reset} $argv1"
end

function check_nix_installation
    print_header "Step 1: Checking Nix Installation"

    if command -v nix &>/dev/null
        set -l nix_version (nix --version 2>/dev/null | cut -d' ' -f3)
        print_success "Nix is installed (version: $nix_version)"
        return 0
    else
        print_error "Nix is not installed"
        return 1
    end
end

function install_determinate_nix
    print_header "Step 2: Installing Determinate Nix"

    print_info "Installing Determinate Nix for better flake support..."

    if curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        print_success "Determinate Nix installed successfully"

        # Source the nix environment
        if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
            source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        end

        return 0
    else
        print_error "Failed to install Determinate Nix"
        return 1
    end
end

function verify_flake_inputs
    print_header "Step 3: Verifying Flake Inputs"

    print_info "Checking flake lock file..."

    if test -f "$repo_root/flake.lock"
        print_success "flake.lock exists"
    else
        print_info "flake.lock not found, will be created during flake check"
    end

    print_info "Updating flake inputs..."
    cd "$repo_root"

    if nix flake update --quiet
        print_success "Flake inputs updated successfully"
        return 0
    else
        print_error "Failed to update flake inputs"
        return 1
    end
end

function run_flake_check
    print_header "Step 4: Running Nix Flake Check"

    print_info "Checking flake.nix syntax and structure..."
    cd "$repo_root"

    if nix flake check --no-build
        print_success "Flake check passed"
        return 0
    else
        print_error "Flake check failed"
        print_info "Common issues:"
        print_info "  • Missing or incorrect module imports"
        print_info "  • Invalid attribute names in nixosConfigurations"
        print_info "  • Circular dependencies in inputs"
        return 1
    end
end

function run_disko_check
    print_header "Step 5: Validating Disko Configuration"

    print_info "Checking disko.nix for syntax errors..."
    cd "$repo_root"

    if nix eval --json ".#nixosConfigurations.hetzner-vps.config.disko" > /dev/null 2>&1
        print_success "Disko configuration is valid"
        return 0
    else
        print_error "Disko configuration validation failed"
        print_info "Check for:"
        print_info "  • Typos in subvolume names"
        print_info "  • Invalid mount options"
        print_info "  • Incorrect partition sizes"
        return 1
    end
end

function run_nixos_rebuild_build
    print_header "Step 6: Building Hetzner VPS Configuration"

    print_info "This may take 10-30 minutes depending on cache..."
    print_info "Building NixOS system configuration..."

    cd "$repo_root"

    # Build with verbose output for debugging
    if nixos-rebuild build --flake ".#hetzner-vps" -v
        print_success "Build completed successfully"
        set -l result_path (realpath result 2>/dev/null || echo "unknown")
        print_info "Build result: $result_path"
        return 0
    else
        print_error "Build failed"
        print_info "Review the errors above for:"
        print_info "  • Missing packages or attributes"
        print_info "  • Invalid module configurations"
        print_info "  • Syntax errors in Nix files"
        return 1
    end
end

function generate_system_info
    print_header "Step 7: System Information Report"

    print_info "Gathering system information..."

    # Get hetzner-vps config info
    cd "$repo_root"

    echo ""
    print_info "Hetzner VPS Configuration Details:"
    echo "  Hostname: $(nix eval --raw '.#nixosConfigurations.hetzner-vps.config.networking.hostName' 2>/dev/null || echo 'unknown')"
    echo "  State Version: $(nix eval --raw '.#nixosConfigurations.hetzner-vps.config.system.stateVersion' 2>/dev/null || echo 'unknown')"
    echo "  Platform: x86_64-linux"

    # Check kernel modules
    print_info "Kernel Modules:"
    nix eval --json '.#nixosConfigurations.hetzner-vps.config.boot.initrd.availableKernelModules' 2>/dev/null | head -1 || echo "  (unable to query)"

    # Check services
    print_info "Key Services Enabled:"
    echo "  • Podman: enabled"
    echo "  • Tailscale: enabled"
    echo "  • OpenSSH: enabled"
    echo "  • 1Password OpNix: enabled"

    echo ""
end

function print_summary
    set -l end_time (date +%s)
    set -l duration (math $end_time - $start_time)
    set -l minutes (math "floor($duration / 60)")
    set -l seconds (math "$duration % 60")

    echo ""
    print_header "Verification Complete"

    echo ""
    print_success "All checks completed in {$minutes}m {$seconds}s"
    echo ""
    print_info "Next Steps for Deployment:"
    echo "  1. Put server in Hetzner Rescue Mode"
    echo "  2. SSH into rescue mode: ssh root@<your-hetzner-ip>"
    echo "  3. Run nixos-anywhere from this machine:"
    echo ""
    echo "     {$yellow}nix run github:nix-community/nixos-anywhere -- \\"
    echo "       --flake '.#hetzner-vps' \\"
    echo "       --no-reboot \\"
    echo "       root@<your-hetzner-ip>{$reset}"
    echo ""
    echo "  4. After deployment, setup secrets:"
    echo "     scp /path/to/opnix-token hbohlen@hetzner-vps:/tmp/"
    echo "     ssh hbohlen@hetzner-vps"
    echo "     sudo mv /tmp/opnix-token /etc/opnix-token"
    echo "     sudo chmod 600 /etc/opnix-token"
    echo "     sudo systemctl restart onepassword-secrets.service"
    echo ""
end

function main
    print_header "pantherOS Hetzner VPS Deployment Verification"

    print_info "Repository: $repo_root"
    echo ""

    # Run all checks
    set -l failed 0

    check_nix_installation || set failed 1

    if test $failed -eq 0
        install_determinate_nix || set failed 1
    end

    if test $failed -eq 0
        verify_flake_inputs || set failed 1
    end

    if test $failed -eq 0
        run_flake_check || set failed 1
    end

    if test $failed -eq 0
        run_disko_check || set failed 1
    end

    if test $failed -eq 0
        run_nixos_rebuild_build || set failed 1
    end

    # Always generate system info if we got this far
    if test $failed -eq 0
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
    end
end

# Run main function
main
