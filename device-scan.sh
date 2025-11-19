#!/bin/bash

# Script to scan hardware capabilities and generate a markdown report
# Useful for NixOS configuration planning and disko.nix setups

# Don't exit on error - continue scanning even if some commands fail
set +e

# Default output file
OUTPUT_FILE="hardware-specs.md"

# Function to print usage
usage() {
    echo "Usage: $0 [-o output_file.md] [hostname]"
    echo "  -o output_file.md : Specify output markdown file (default: hardware-specs.md)"
    echo "  hostname          : Hostname to include in report (default: current hostname)"
    exit 1
}

# Parse command line arguments
while getopts "o:h" opt; do
    case $opt in
        o)
            OUTPUT_FILE="$OPTARG"
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done

shift $((OPTIND-1))
HOSTNAME="${1:-$(hostname)}"

echo "Scanning hardware capabilities for: $HOSTNAME"
echo "Output will be written to: $OUTPUT_FILE"

# Start writing the markdown file
cat > "$OUTPUT_FILE" << EOF
# Hardware Specifications Report

**Host:** $HOSTNAME  
**Scan Date:** $(date)

## System Information

EOF

# System information
echo "## System Information" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- **Hostname:** $(hostname)" >> "$OUTPUT_FILE"
echo "- **Kernel:** $(uname -r)" >> "$OUTPUT_FILE"
echo "- **Architecture:** $(uname -m)" >> "$OUTPUT_FILE"
echo "- **OS:** $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo 'Unknown')" >> "$OUTPUT_FILE"
echo "- **Uptime:** $(uptime -p 2>/dev/null || uptime)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# CPU Information
echo "## CPU Information" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
if command -v lscpu >/dev/null 2>&1; then
    echo "| Property | Value |" >> "$OUTPUT_FILE"
    echo "|----------|-------|" >> "$OUTPUT_FILE"
    lscpu | while IFS= read -r line; do
        if [[ $line =~ ^([A-Za-z\ ]+):[[:space:]]*(.*) ]]; then
            property="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            # Clean up property and value for markdown
            property=$(echo "$property" | sed 's/  */ /g' 2>/dev/null || echo "$property")
            value=$(echo "$value" | sed 's/  */ /g' 2>/dev/null || echo "$value")
            echo "| $property | $value |" >> "$OUTPUT_FILE"
        fi
    done
else
    echo "- **CPU Info:** lscpu not available" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Memory Information
echo "## Memory Information" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
if command -v dmidecode >/dev/null 2>&1; then
    echo "### Memory Details (from dmidecode):" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    dmidecode -t memory 2>/dev/null | grep -E "Size:|Type:|Speed:|Manufacturer:" | head -20 >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

echo "### Memory Summary:" >> "$OUTPUT_FILE"
echo "\`\`\`" >> "$OUTPUT_FILE"
if command -v free >/dev/null 2>&1; then
    free -h >> "$OUTPUT_FILE"
else
    cat /proc/meminfo | grep -E "^MemTotal|^MemFree|^SwapTotal|^SwapFree" >> "$OUTPUT_FILE"
fi
echo "\`\`\`" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Storage Information
echo "## Storage Information" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if command -v lsblk >/dev/null 2>&1; then
    # List block devices
    echo "### Block Devices:" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # Disk information with lsblk in tree format
    echo "### Disk Information (Tree Format):" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    lsblk -f >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
else
    echo "### Storage Information:" >> "$OUTPUT_FILE"
    echo "lsblk not available. Using alternative methods:" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    cat /proc/partitions >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# If available, get detailed disk info
if command -v smartctl >/dev/null 2>&1 && command -v lsblk >/dev/null 2>&1; then
    echo "### SMART Information (for supported drives):" >> "$OUTPUT_FILE"
    # Get disk list only if lsblk is available
    for disk in $(lsblk -nr -o NAME,TYPE | awk '$2=="disk" {print "/dev/"$1}'); do
        echo "" >> "$OUTPUT_FILE"
        echo "**$disk:**" >> "$OUTPUT_FILE"
        echo "\`\`\`" >> "$OUTPUT_FILE"
        smartctl -i "$disk" 2>/dev/null | grep -E "Model Family|Device Model|Serial Number|Capacity|Rotation Rate|Form Factor" || echo "No SMART info available for $disk"
        echo "\`\`\`" >> "$OUTPUT_FILE"
    done
    echo "" >> "$OUTPUT_FILE"
else
    echo "### SMART Information:" >> "$OUTPUT_FILE"
    echo "smartctl or lsblk not available" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# Motherboard Information
echo "## Motherboard Information" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -d /sys/class/dmi/id ]; then
    echo "- **Product Name:** $(cat /sys/class/dmi/id/product_name 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
    echo "- **Product Version:** $(cat /sys/class/dmi/id/product_version 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
    echo "- **Manufacturer:** $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
    echo "- **Board Name:** $(cat /sys/class/dmi/id/board_name 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
    echo "- **Board Version:** $(cat /sys/class/dmi/id/board_version 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
    echo "- **Board Vendor:** $(cat /sys/class/dmi/id/board_vendor 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# Graphics Information
echo "## Graphics Information" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if command -v lspci >/dev/null 2>&1; then
    echo "### Graphics Cards:" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    lspci | grep -i -E "vga|3d|display" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
else
    echo "### Graphics Information:" >> "$OUTPUT_FILE"
    echo "lspci not available" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# Network Information
echo "## Network Information" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if command -v ip >/dev/null 2>&1; then
    echo "### Network Interfaces:" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    ip addr show | grep -E "^[0-9]+:|inet " >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
else
    echo "### Network Interfaces:" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    if command -v ifconfig >/dev/null 2>&1; then
        ifconfig | grep -E "^[a-z]|inet " >> "$OUTPUT_FILE"
    else
        echo "No network interface tools available" >> "$OUTPUT_FILE"
    fi
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

if command -v lspci >/dev/null 2>&1; then
    echo "### Network Controllers:" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    lspci | grep -i -E "ethernet|network|wireless" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# USB Information
echo "## USB Information" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "### USB Controllers and Devices:" >> "$OUTPUT_FILE"
echo "\`\`\`" >> "$OUTPUT_FILE"
if command -v lspci >/dev/null 2>&1; then
    lspci | grep -i usb >> "$OUTPUT_FILE"
else
    echo "lspci not available" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"
if command -v lsusb >/dev/null 2>&1; then
    lsusb >> "$OUTPUT_FILE"
else
    echo "lsusb not available" >> "$OUTPUT_FILE"
fi
echo "\`\`\`" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Firmware Information
echo "## Firmware Information" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -f /sys/class/dmi/id/bios_version ]; then
    echo "- **BIOS Version:** $(cat /sys/class/dmi/id/bios_version 2>/dev/null)" >> "$OUTPUT_FILE"
    echo "- **BIOS Date:** $(cat /sys/class/dmi/id/bios_date 2>/dev/null)" >> "$OUTPUT_FILE"
fi
if [ -f /sys/class/dmi/id/bios_vendor ]; then
    echo "- **BIOS Vendor:** $(cat /sys/class/dmi/id/bios_vendor 2>/dev/null)" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# NixOS Specific Information
echo "## NixOS Configuration Notes" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "### For disko.nix setup considerations:" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- **Available storage devices:** List the block devices that could be used for partitioning" >> "$OUTPUT_FILE"
echo "- **Boot requirements:** Check if UEFI or legacy BIOS is needed based on system firmware" >> "$OUTPUT_FILE"
echo "- **Filesystem preferences:** Based on current filesystems in use" >> "$OUTPUT_FILE"
echo "- **Swap configuration:** Consider memory size and usage patterns" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "Hardware scan completed. Results written to $OUTPUT_FILE"