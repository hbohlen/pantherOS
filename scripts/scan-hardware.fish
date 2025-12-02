#!/usr/bin/env fish
# Hardware Scanning Script for NixOS Devices
# This script automates the hardware detection process using nixos-facter

# Configuration
set SCRIPT_DIR (cd (dirname (status -f)); and pwd)
set PROJECT_ROOT (dirname "$SCRIPT_DIR")
set OUTPUT_DIR "$PROJECT_ROOT/hardware-reports"
set TIMESTAMP (date +%Y%m%d-%H%M%S)

# Colors for output
set -g RED '\033[0;31m'
set -g GREEN '\033[0;32m'
set -g YELLOW '\033[1;33m'
set -g BLUE '\033[0;34m'
set -g NC '\033[0m' # No Color

# Logging functions
function log_info
    printf "%b[INFO]%b %s\n" "$BLUE" "$NC" $argv
end

function log_success
    printf "%b[SUCCESS]%b %s\n" "$GREEN" "$NC" $argv
end

function log_warning
    printf "%b[WARNING]%b %s\n" "$YELLOW" "$NC" $argv
end

function log_error
    printf "%b[ERROR]%b %s\n" "$RED" "$NC" $argv
end

# Check if running as root
function check_root
    if test (id -u) -ne 0
        log_error "This script must be run as root for hardware detection"
        log_info "Usage: sudo "(status -f)" [device-name]"
        exit 1
    end
end

# Check nix availability
function check_nix
    if not command -v nix &> /dev/null
        log_error "Nix is not available. Please install Nix first."
        exit 1
    end
end

# Generate hardware report using nixos-facter
function generate_report
    set device_name $argv[1]
    set output_file "$OUTPUT_DIR/$device_name-$TIMESTAMP.json"

    log_info "Generating hardware report for device: $device_name"
    log_info "Output file: $output_file"

    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Run nixos-facter
    if nix run nixpkgs#nixos-facter -- -o "$output_file"
        log_success "Hardware report generated successfully"

        # Display basic info from the report
        if command -v jq &> /dev/null
            log_info "Hardware summary:"
            echo "  System: "(jq -r '.system // "unknown"' "$output_file")

            # CPU info
            set cpu_model (jq -r '.hardware.cpu[0].model_name // "unknown"' "$output_file")
            set cpu_cores (jq -r '.hardware.cpu[0].cores // 0' "$output_file")
            set cpu_threads (jq -r '.hardware.cpu[0].siblings // 0' "$output_file")
            echo "  CPU: $cpu_model ($cpu_cores cores, $cpu_threads threads)"

            # Memory info
            set memory_bytes (jq -r '.hardware.memory[0].resources[0].range // 0' "$output_file")
            set memory_gb (math "$memory_bytes / 1024 / 1024 / 1024")
            echo "  Memory: {$memory_gb}GB"

            # Count disks
            set disk_count (jq '.hardware.disk | length' "$output_file")
            echo "  Disks: $disk_count"

            # Count network interfaces
            set net_count (jq '.hardware.network_interface | length' "$output_file")
            echo "  Network Interfaces: $net_count"
        else
            log_warning "jq not available - skipping hardware summary display"
        end

        echo "$output_file"
    else
        log_error "Failed to generate hardware report"
        return 1
    end
end

# Validate report file
function validate_report
    set report_file $argv[1]

    if not test -f "$report_file"
        log_error "Report file does not exist: $report_file"
        return 1
    end

    if not jq empty "$report_file" 2>/dev/null
        log_error "Report file is not valid JSON: $report_file"
        return 1
    end

    log_success "Report file validated: $report_file"
end

# Main function
function main
    set device_name $argv[1]

    if test -z "$device_name"
        log_error "Device name is required"
        log_info "Usage: "(status -f)" <device-name>"
        log_info "Example: "(status -f)" zephyrus"
        exit 1
    end

    log_info "Starting hardware scanning for device: $device_name"
    log_info "Output directory: $OUTPUT_DIR"

    check_root
    check_nix

    set report_file (generate_report "$device_name")
    if test -n "$report_file"
        validate_report "$report_file"
        log_success "Hardware scanning completed successfully"
        log_info "Report saved to: $report_file"
        log_info "Next steps:"
        log_info "  1. Transfer this file to your NixOS configuration repository"
        log_info "  2. Use nixos-facter-modules to generate hardware configuration"
        log_info "  3. Create host configuration in hosts/\$device_name/"
    else
        log_error "Hardware scanning failed"
        exit 1
    end
end

# Show usage if requested
if test "$argv[1]" = "--help" -o "$argv[1]" = "-h"
    echo "Hardware Scanning Script for NixOS Devices"
    echo ""
    echo "This script uses nixos-facter to generate detailed hardware reports"
    echo "that can be used with nixos-facter-modules for automatic configuration."
    echo ""
    echo "Usage: sudo "(status -f)" <device-name>"
    echo ""
    echo "Examples:"
    echo "  sudo "(status -f)" zephyrus"
    echo "  sudo "(status -f)" yoga"
    echo "  sudo "(status -f)" desktop"
    echo ""
    echo "Requirements:"
    echo "  - Root access (for hardware detection)"
    echo "  - Nix installed and available"
    echo "  - Internet connection (for nixpkgs access)"
    echo ""
    echo "Output:"
    echo "  Reports are saved to: hardware-reports/<device>-<timestamp>.json"
    exit 0
end

# Run main function
main $argv
