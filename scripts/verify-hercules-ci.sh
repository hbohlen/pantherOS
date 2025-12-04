#!/usr/bin/env bash
# Verification script for Hercules CI Agent connectivity and job execution
# This script checks the Hercules CI agent service logs to verify successful connection

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="hercules-ci-agent"
LOG_LINES=100

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Verify Hercules CI Agent connectivity and job execution.

OPTIONS:
    -h, --help          Show this help message
    -l, --lines N       Number of log lines to check (default: ${LOG_LINES})
    -v, --verbose       Show detailed log output

EXAMPLES:
    # Basic verification
    $(basename "$0")

    # Check with more log lines
    $(basename "$0") --lines 200

    # Show detailed logs
    $(basename "$0") --verbose

EOF
    exit 1
}

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Parse command line arguments
VERBOSE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -l|--lines)
            if [[ -z "${2:-}" ]] || ! [[ "${2:-}" =~ ^[0-9]+$ ]] || [[ "${2:-0}" -lt 1 ]]; then
                print_error "Invalid value for --lines: ${2:-<missing>} (must be a positive integer)"
                exit 1
            fi
            LOG_LINES="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]] && ! command -v sudo &> /dev/null; then
    print_error "This script requires root privileges or sudo to access service logs"
    exit 1
fi

SUDO=""
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

# Main verification function
verify_hercules_ci() {
    local exit_code=0
    
    print_info "Starting Hercules CI Agent verification..."
    echo ""
    
    # Step 1: Check if service exists
    print_info "Step 1: Checking if ${SERVICE_NAME} service exists..."
    if $SUDO systemctl list-unit-files "${SERVICE_NAME}.service" &>/dev/null; then
        print_success "Service ${SERVICE_NAME} is configured"
    else
        print_error "Service ${SERVICE_NAME} is not configured"
        print_info "Have you enabled services.ci.herculesCI.enable in your NixOS configuration?"
        exit 1
    fi
    echo ""
    
    # Step 2: Check service status
    print_info "Step 2: Checking service status..."
    if $SUDO systemctl is-active --quiet "${SERVICE_NAME}"; then
        print_success "Service ${SERVICE_NAME} is active and running"
    else
        local status
        status=$($SUDO systemctl is-active "${SERVICE_NAME}" || echo "inactive")
        print_error "Service ${SERVICE_NAME} is not running (status: ${status})"
        
        # Try to get more information about why it failed
        if $SUDO systemctl is-failed --quiet "${SERVICE_NAME}"; then
            print_warning "Service has failed. Recent logs:"
            $SUDO journalctl -u "${SERVICE_NAME}" -n 20 --no-pager
        fi
        exit 1
    fi
    echo ""
    
    # Step 3: Check for required secret files
    print_info "Step 3: Checking for required secret files..."
    local secrets_missing=false
    
    if [[ -f /etc/hercules-ci/README ]]; then
        # Extract paths from the README using sed for portability
        # Note: Assumes paths are in /var and contain no spaces (as per module configuration)
        local token_path
        local caches_path
        token_path=$(grep "Cluster Join Token:" /etc/hercules-ci/README | sed -n 's/.*\(\/var[^ ]*\).*/\1/p' || echo "")
        caches_path=$(grep "Binary Caches Configuration:" /etc/hercules-ci/README | sed -n 's/.*\(\/var[^ ]*\).*/\1/p' || echo "")
        
        # Check token file
        if [[ -n "$token_path" ]]; then
            if $SUDO test -f "$token_path"; then
                print_success "Cluster join token found at: ${token_path}"
            else
                print_warning "Cluster join token NOT found at: ${token_path}"
                secrets_missing=true
            fi
        fi
        
        # Check binary caches file
        if [[ -n "$caches_path" ]]; then
            if $SUDO test -f "$caches_path"; then
                print_success "Binary caches config found at: ${caches_path}"
            else
                print_warning "Binary caches config NOT found at: ${caches_path}"
                secrets_missing=true
            fi
        fi
    else
        print_warning "Could not find /etc/hercules-ci/README to check secret paths"
    fi
    
    if $secrets_missing; then
        print_warning "Some required secret files are missing. The agent may not connect successfully."
        print_info "See: /etc/hercules-ci/README for setup instructions"
    fi
    echo ""
    
    # Step 4: Check service logs for connectivity messages
    print_info "Step 4: Checking service logs for connectivity messages..."
    local logs
    logs=$($SUDO journalctl -u "${SERVICE_NAME}" -n "${LOG_LINES}" --no-pager --output=cat)
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_info "Recent logs (last ${LOG_LINES} lines):"
        echo "---"
        echo "$logs"
        echo "---"
        echo ""
    fi
    
    # Check for various connection-related messages
    local found_connection=false
    local found_ready=false
    local found_error=false
    
    # Patterns that indicate successful connection
    if echo "$logs" | grep -iq "connected to\|connection established\|agent connected\|successfully connected"; then
        print_success "Found connection message in logs"
        found_connection=true
    fi
    
    # Patterns that indicate the agent is ready
    if echo "$logs" | grep -iq "ready to process\|ready for tasks\|waiting for jobs\|agent ready"; then
        print_success "Found 'ready to process' message in logs"
        found_ready=true
    fi
    
    # Patterns that indicate errors
    if echo "$logs" | grep -iq "error\|failed\|cannot connect\|connection refused"; then
        print_warning "Found error-related messages in logs"
        found_error=true
        
        if [[ "$VERBOSE" == "false" ]]; then
            print_info "Run with --verbose to see detailed logs"
        fi
    fi
    
    echo ""
    
    # Step 5: Summary
    print_info "Step 5: Verification Summary"
    echo ""
    
    if $found_connection && $found_ready; then
        print_success "Hercules CI Agent is connected and ready to process tasks!"
        echo ""
        print_info "The agent should now be visible in your Hercules CI dashboard"
        print_info "Dashboard: https://hercules-ci.com"
        exit_code=0
    elif $found_connection; then
        print_success "Hercules CI Agent is connected"
        print_warning "But 'ready to process' message not found in recent logs"
        print_info "The agent may still be initializing. Check again in a few moments."
        exit_code=0
    elif $found_error; then
        print_error "Hercules CI Agent connection verification failed"
        print_error "Error messages were found in the logs"
        echo ""
        print_info "Troubleshooting steps:"
        print_info "1. Check that secret files exist and have correct permissions"
        print_info "2. Verify the cluster join token is valid"
        print_info "3. Check network connectivity"
        print_info "4. Review detailed logs: journalctl -u ${SERVICE_NAME} -f"
        exit_code=1
    else
        print_warning "Could not determine agent connection status from logs"
        print_info "The agent may still be starting up or may not have connected yet"
        echo ""
        print_info "Try these steps:"
        print_info "1. Wait a few moments and run this script again"
        print_info "2. Check logs in real-time: journalctl -u ${SERVICE_NAME} -f"
        print_info "3. Restart the service: systemctl restart ${SERVICE_NAME}"
        exit_code=2
    fi
    
    return $exit_code
}

# Run the verification
verify_hercules_ci
