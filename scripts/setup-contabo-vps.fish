#!/usr/bin/env fish
# setup-contabo-vps.fish
# Hardware detection and Determinate Nix installation script for Contabo VPS
# Run this script in NixOS live environment to detect hardware and prepare for deployment

set -l RED '\033[0;31m'
set -l GREEN '\033[0;32m'
set -l YELLOW '\033[1;33m'
set -l BLUE '\033[0;34m'
set -l RESET '\033[0m'

function print_header
    echo -e "{$BLUE}╔════════════════════════════════════════════════════════════╗{$RESET}"
    echo -e "{$BLUE}║{$RESET} $argv1"
    echo -e "{$BLUE}╚════════════════════════════════════════════════════════════╝{$RESET}"
end

function print_success
    echo -e "{$GREEN}✓{$RESET} $argv1"
end

function print_error
    echo -e "{$RED}✗{$RESET} $argv1" >&2
end

function print_info
    echo -e "{$YELLOW}ℹ{$RESET} $argv1"
end

print_header "Contabo VPS Hardware Detection and Setup"

# Check if running NixOS
print_info "Checking NixOS environment..."
if test ! -f /etc/os-release
    print_error "Cannot detect OS"
    exit 1
end

# Source os-release
set -l os_id (grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
if test "$os_id" != "nixos"
    print_error "This script must run on NixOS (detected: $os_id)"
    exit 1
end

print_success "Running on NixOS"

# Install hardware detection tools if needed
print_header "Step 1: Preparing Hardware Detection"

print_info "Ensuring required packages are available..."

# Check if nix is available
if not command -v nix &>/dev/null
    print_error "Nix is not available in current environment"
    exit 1
end

print_success "Nix is available"

# Prepare output directory
set -l OUTPUT_DIR "/tmp/contabo-detection"
mkdir -p $OUTPUT_DIR

print_info "Output directory: $OUTPUT_DIR"

# Detect hardware using multiple methods
print_header "Step 2: Detecting Hardware"

print_info "Detecting system information..."

# Detect CPU
set -l cpu_model (lscpu | grep 'Model name' | cut -d: -f2 | xargs)
set -l cores (nproc --all)
set -l memory (free -h | grep Mem | awk '{print $2}')

print_info "CPU: $cpu_model"
print_info "Cores: $cores"
print_info "Memory: $memory"

# Detect disks
print_info "Disks detected:"
lsblk -d -n -o NAME,SIZE,TYPE | grep -E 'nvme|sda|vda' | while read -l line
    echo "  - $line"
end

# Detect network interfaces
print_info "Network interfaces detected:"
ip link show | grep "^[0-9]" | grep -v "lo:" | awk '{print $2}' | sed 's/:$//' | while read -l iface
    echo "  - $iface"
end

# Generate facter output
print_header "Step 3: Generating Hardware Information (facter)"

print_info "Running system detection to generate hardware specification..."

# Create hardware info JSON
set -l hw_json "$OUTPUT_DIR/hardware-info.json"

# Collect disks
set -l disk_info (lsblk -d -n -o NAME,SIZE,ROTA | grep -E 'nvme|sda|vda' | head -1)
set -l disk_name (echo $disk_info | awk '{print $1}')
set -l disk_size (echo $disk_info | awk '{print $2}')

# Collect network interfaces
set -l interfaces
for iface in (ip link show | grep "^[0-9]" | grep -v "lo:" | awk '{print $2}' | sed 's/:$//')
    set -a interfaces "\"$iface\""
end

# Generate JSON
cat > $hw_json <<EOF
{
  "version": 1,
  "system": "$(uname -m)-linux",
  "virtualisation": "kvm",
  "hardware": {
    "cpu": "$cpu_model",
    "cores": $cores,
    "memory_gb": $(free -g | grep Mem | awk '{print $2}'),
    "disk": {
      "device": "$disk_name",
      "size": "$disk_size",
      "path": "/dev/disk/by-id/$(ls -l /dev/disk/by-id/ | grep $disk_name | awk '{print $NF}' | head -1)"
    },
    "network_interfaces": [
      $(string join ", " $interfaces)
    ]
  },
  "detected_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

print_success "Hardware info saved to: $hw_json"

# Display detection results
print_header "Step 4: Hardware Detection Summary"

echo ""
echo "Detected Hardware:"
cat $hw_json | grep -E '(system|cpu|cores|memory|disk|network)' || true
echo ""

# Install Determinate Nix
print_header "Step 5: Installing Determinate Nix"

print_info "Installing Determinate Nix for flake support..."

if curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install 2>&1
    print_success "Determinate Nix installed successfully"

    # Source nix environment
    if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    end
else
    print_error "Failed to install Determinate Nix"
    print_info "You can try installing manually later:"
    print_info "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
end

# Provide next steps
print_header "Next Steps"

echo ""
echo "Hardware detection complete! Here's what to do next:"
echo ""
echo "1. Transfer hardware detection to local machine:"
echo "   scp root@<contabo-ip>:$OUTPUT_DIR/hardware-info.json /home/user/pantherOS/hosts/servers/contabo-vps/facter.json"
echo ""
echo "2. Review the detected hardware:"
echo "   cat /home/user/pantherOS/hosts/servers/contabo-vps/facter.json"
echo ""
echo "3. Update configuration files with detected values:"
echo "   - Update hardware.nix with kernel modules and CPU info"
echo "   - Update disko.nix with correct disk device ID"
echo "   - Update default.nix with correct network interface name"
echo ""
echo "4. Run verification script on local machine:"
echo "   cd /home/user/pantherOS"
echo "   ./scripts/verify-contabo-deployment.fish"
echo ""
echo "5. Deploy with nixos-anywhere:"
echo "   nix run github:nix-community/nixos-anywhere -- \\"
echo "     --flake '.#contabo-vps' \\"
echo "     --no-reboot \\"
echo "     root@<contabo-ip>"
echo ""

# Show hardware info file location
print_info "Hardware info available at: $OUTPUT_DIR/hardware-info.json"
echo ""

# Verify Determinate Nix is available
print_header "Verification"

if command -v nix &>/dev/null
    set -l nix_version (nix --version 2>/dev/null | awk '{print $3}')
    print_success "Nix is ready (version: $nix_version)"
else
    print_error "Nix is not yet available - may need shell restart"
end

echo ""
print_success "Setup complete!"
echo ""
