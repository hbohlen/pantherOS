#!/usr/bin/env bash
# Hardware Scanner for pantherOS
# Automates Phase 1 hardware discovery and documentation
# Usage: ./scan-hardware.sh <hostname> [output-dir]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Arguments
HOSTNAME="${1:-}"
OUTPUT_DIR="${2:-.}"

# Validation
if [[ -z "$HOSTNAME" ]]; then
    echo -e "${RED}Error: hostname required${NC}" >&2
    echo "Usage: $0 <hostname> [output-dir]"
    exit 1
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}=== PantherOS Hardware Scanner ===${NC}"
echo -e "Hostname: ${GREEN}$HOSTNAME${NC}"
echo -e "Output Directory: ${GREEN}$OUTPUT_DIR${NC}"
echo ""

# Create output files
HW_DOC="$OUTPUT_DIR/${HOSTNAME}-hardware.md"
SYS_INFO="$OUTPUT_DIR/${HOSTNAME}-system-info.txt"

echo -e "${YELLOW}Scanning hardware...${NC}"

{
    echo "# Hardware Documentation for $HOSTNAME"
    echo ""
    echo "Generated: $(date)"
    echo ""
    echo "## System Overview"
    echo ""
    echo "This document contains complete hardware specifications for $HOSTNAME."
    echo ""
    echo "---"
    echo ""

    # CPU Information
    echo "## CPU"
    echo ""
    {
        echo "### Model"
        grep "Model name" /proc/cpuinfo | head -1 | sed 's/Model name.*: //'
        echo ""
        echo "### Details"
        lscpu | grep -E "Architecture:|CPU\(s\):|Thread|MHz|Cache|Model|Socket|Virtualization"
    } | tee /tmp/cpu_info.txt
    echo ""

    # Memory Information
    echo "## Memory"
    echo ""
    {
        echo "### Total Memory"
        lsmem | grep "Total online memory:" | sed 's/Total online memory: //'
        echo ""
        echo "### Memory Details"
        lsmem
    } | tee /tmp/mem_info.txt
    echo ""

    # Storage Information
    echo "## Storage"
    echo ""
    {
        echo "### Block Devices"
        lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,MODEL
        echo ""
        echo "### Disk Space"
        df -h
    } | tee /tmp/storage_info.txt
    echo ""

    # PCI Devices
    echo "## PCI Devices"
    echo ""
    {
        echo "### Graphics"
        lspci | grep -i vga
        echo ""
        echo "### All PCI Devices"
        lspci
    } | tee /tmp/pci_info.txt
    echo ""

    # Network Interfaces
    echo "## Network Interfaces"
    echo ""
    {
        ip addr show
    } | tee /tmp/network_info.txt
    echo ""

    # Hardware Summary (for disko.nix generation)
    echo "---"
    echo ""
    echo "## Hardware Summary for Configuration"
    echo ""
    echo "```nix"
    echo "# Copy these values into your disko.nix"
    echo ""
    echo "# Disk layout detected:"
    echo "diskType = \"$(lsblk -d -o ROTATION | grep -v ROTATION | head -1 | awk '{if($1==0) {print "ssd"} else {print "hdd"}}')\";"
    echo ""
    echo "# Block devices:"
    echo "$(lsblk -d -o NAME,SIZE | grep -v NAME | head -5 | awk '{print "  " $1 " (" $2 ")"}')"
    echo ""
    echo "# Recommended filesystem: btrfs (subvolumes) for all devices"
    echo "# Root mount point: /"
    echo "# EFI partition: /boot (FAT32)"
    echo "```"
    echo ""

} > "$HW_DOC"

# Generate system info file (raw command output)
{
    echo "=== System Information for $HOSTNAME ==="
    echo ""
    echo "--- CPU ---"
    lscpu
    echo ""
    echo "--- Memory ---"
    lsmem
    echo ""
    echo "--- Block Devices ---"
    lsblk
    echo ""
    echo "--- PCI ---"
    lspci
    echo ""
    echo "--- Network ---"
    ip addr show
    echo ""
    echo "--- Filesystems ---"
    df -h
    echo ""
} > "$SYS_INFO"

echo -e "${GREEN}✓ Hardware scan complete!${NC}"
echo ""
echo "Generated files:"
echo "  - ${BLUE}$HW_DOC${NC} (hardware documentation)"
echo "  - ${BLUE}$SYS_INFO${NC} (raw system information)"
echo ""

# Generate suggested disko.nix template
DISKO_TEMPLATE="$OUTPUT_DIR/${HOSTNAME}-disko.nix.template"
cat > "$DISKO_TEMPLATE" << 'EOF'
{ config, lib, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";  # TODO: Verify actual device
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            main = {
              size = "100%";
              type = "8300";
              content = {
                type = "btrfs";
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                  };
                  "/home" = {
                    mountpoint = "/home";
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
EOF

echo -e "${GREEN}✓ Generated disko.nix template${NC}"
echo "  - ${BLUE}$DISKO_TEMPLATE${NC}"
echo ""

echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review $HW_DOC"
echo "  2. Verify and customize $DISKO_TEMPLATE"
echo "  3. Copy template to: hosts/$HOSTNAME/disko.nix"
echo "  4. Continue with Phase 2: Module Development"
echo ""

# Cleanup temp files
rm -f /tmp/*_info.txt
