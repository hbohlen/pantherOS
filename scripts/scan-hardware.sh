#!/usr/bin/env bash
# Hardware Scanning Script for NixOS Devices
# This script automates the hardware detection process using nixos-facter

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${PROJECT_ROOT}/hardware-reports"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root for hardware detection"
        log_info "Usage: sudo $0 [device-name]"
        exit 1
    fi
}

# Check nix availability
check_nix() {
    if ! command -v nix &> /dev/null; then
        log_error "Nix is not available. Please install Nix first."
        exit 1
    fi
}

# Generate hardware report using nixos-facter
generate_report() {
    local device_name="$1"
    local output_file="${OUTPUT_DIR}/${device_name}-${TIMESTAMP}.json"

    log_info "Generating hardware report for device: $device_name"
    log_info "Output file: $output_file"

    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Run nixos-facter
    if nix run nixpkgs#nixos-facter -- -o "$output_file"; then
        log_success "Hardware report generated successfully"

        # Display basic info from the report
        if command -v jq &> /dev/null; then
            log_info "Hardware summary:"
            echo "  System: $(jq -r '.system // "unknown"' "$output_file")"

            # CPU info
            local cpu_model
            cpu_model=$(jq -r '.hardware.cpu[0].model_name // "unknown"' "$output_file")
            local cpu_cores
            cpu_cores=$(jq -r '.hardware.cpu[0].cores // 0' "$output_file")
            local cpu_threads
            cpu_threads=$(jq -r '.hardware.cpu[0].siblings // 0' "$output_file")
            echo "  CPU: $cpu_model (${cpu_cores} cores, ${cpu_threads} threads)"

            # Memory info
            local memory_bytes
            memory_bytes=$(jq -r '.hardware.memory[0].resources[0].range // 0' "$output_file")
            local memory_gb=$((memory_bytes / 1024 / 1024 / 1024))
            echo "  Memory: ${memory_gb}GB"

            # Count disks
            local disk_count
            disk_count=$(jq '.hardware.disk | length' "$output_file")
            echo "  Disks: $disk_count"

            # Count network interfaces
            local net_count
            net_count=$(jq '.hardware.network_interface | length' "$output_file")
            echo "  Network Interfaces: $net_count"
        else
            log_warning "jq not available - skipping hardware summary display"
        fi

        echo "$output_file"
    else
        log_error "Failed to generate hardware report"
        return 1
    fi
}

# Validate report file
validate_report() {
    local report_file="$1"

    if [[ ! -f "$report_file" ]]; then
        log_error "Report file does not exist: $report_file"
        return 1
    fi

    if ! jq empty "$report_file" 2>/dev/null; then
        log_error "Report file is not valid JSON: $report_file"
        return 1
    fi

    log_success "Report file validated: $report_file"
}

# Main function
main() {
    local device_name="${1:-}"

    if [[ -z "$device_name" ]]; then
        log_error "Device name is required"
        log_info "Usage: $0 <device-name>"
        log_info "Example: $0 zephyrus"
        exit 1
    fi

    log_info "Starting hardware scanning for device: $device_name"
    log_info "Output directory: $OUTPUT_DIR"

    check_root
    check_nix

    local report_file
    if report_file=$(generate_report "$device_name"); then
        validate_report "$report_file"
        log_success "Hardware scanning completed successfully"
        log_info "Report saved to: $report_file"
        log_info "Next steps:"
        log_info "  1. Transfer this file to your NixOS configuration repository"
        log_info "  2. Use nixos-facter-modules to generate hardware configuration"
        log_info "  3. Create host configuration in hosts/$device_name/"
    else
        log_error "Hardware scanning failed"
        exit 1
    fi
}

# Show usage if requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Hardware Scanning Script for NixOS Devices"
    echo ""
    echo "This script uses nixos-facter to generate detailed hardware reports"
    echo "that can be used with nixos-facter-modules for automatic configuration."
    echo ""
    echo "Usage: sudo $0 <device-name>"
    echo ""
    echo "Examples:"
    echo "  sudo $0 zephyrus"
    echo "  sudo $0 yoga"
    echo "  sudo $0 desktop"
    echo ""
    echo "Requirements:"
    echo "  - Root access (for hardware detection)"
    echo "  - Nix installed and available"
    echo "  - Internet connection (for nixpkgs access)"
    echo ""
    echo "Output:"
    echo "  Reports are saved to: hardware-reports/<device>-<timestamp>.json"
    exit 0
fi

# Run main function
main "$@"
