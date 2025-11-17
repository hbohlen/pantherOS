#!/usr/bin/env bash
#
# MCP Server Configuration Verification Script
# 
# This script validates the MCP server configuration and tests basic functionality
# for the GitHub Copilot coding agent.
#
# Usage: ./verify-mcp-config.sh
#

set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Print header
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}MCP Configuration Verification${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Print test result
print_result() {
    local status=$1
    local message=$2
    
    case $status in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC}: $message"
            ((PASSED++))
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC}: $message"
            ((FAILED++))
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN${NC}: $message"
            ((WARNINGS++))
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO${NC}: $message"
            ;;
    esac
}

# Check if file exists and is readable
check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ] && [ -r "$file" ]; then
        print_result "PASS" "$description exists and is readable: $file"
        return 0
    else
        print_result "FAIL" "$description not found or not readable: $file"
        return 1
    fi
}

# Validate JSON file
validate_json() {
    local file=$1
    local description=$2
    
    if command -v jq &> /dev/null; then
        if jq empty "$file" 2>/dev/null; then
            print_result "PASS" "$description has valid JSON syntax"
            return 0
        else
            print_result "FAIL" "$description has invalid JSON syntax"
            return 1
        fi
    else
        print_result "WARN" "jq not found, skipping JSON validation for $description"
        return 0
    fi
}

# Check if command exists
check_command() {
    local cmd=$1
    local description=$2
    
    if command -v "$cmd" &> /dev/null; then
        print_result "PASS" "$description is available: $(command -v $cmd)"
        return 0
    else
        print_result "WARN" "$description not found: $cmd"
        return 1
    fi
}

# Check environment variable
check_env_var() {
    local var=$1
    local description=$2
    local required=$3
    
    if [ -n "${!var}" ]; then
        # Mask the value for security
        local masked_value="${!var:0:10}..."
        print_result "PASS" "$description is set: $var=$masked_value"
        return 0
    else
        if [ "$required" = "required" ]; then
            print_result "FAIL" "$description is not set (required): $var"
            return 1
        else
            print_result "INFO" "$description is not set (optional): $var"
            return 0
        fi
    fi
}

# Validate MCP server configuration structure
validate_mcp_structure() {
    local config_file=$1
    
    if ! command -v jq &> /dev/null; then
        print_result "WARN" "jq not available, skipping structure validation"
        return 0
    fi
    
    # Check for required top-level keys
    if jq -e '.mcpServers' "$config_file" > /dev/null 2>&1; then
        print_result "PASS" "MCP servers configuration has required 'mcpServers' key"
    else
        print_result "FAIL" "MCP servers configuration missing 'mcpServers' key"
        return 1
    fi
    
    # Check for schema reference
    if jq -e '."$schema"' "$config_file" > /dev/null 2>&1; then
        local schema=$(jq -r '."$schema"' "$config_file")
        print_result "PASS" "Schema reference found: $schema"
    else
        print_result "WARN" "No schema reference found in configuration"
    fi
    
    # Count configured servers
    local server_count=$(jq '.mcpServers | keys | length' "$config_file")
    print_result "INFO" "Total MCP servers configured: $server_count"
    
    # List all servers
    echo -e "\n${BLUE}Configured MCP Servers:${NC}"
    jq -r '.mcpServers | keys[]' "$config_file" | while read server; do
        echo "  - $server"
    done
    echo ""
    
    return 0
}

# Main execution
main() {
    print_header
    
    echo -e "${BLUE}[1/7] Checking Configuration Files${NC}"
    echo "-----------------------------------"
    check_file ".github/mcp-servers.json" "MCP servers configuration"
    check_file ".github/MCP-SETUP.md" "MCP setup documentation"
    check_file ".github/copilot-instructions.md" "Copilot instructions"
    check_file ".github/SECRETS-QUICK-REFERENCE.md" "Secrets quick reference"
    check_file "flake.nix" "Nix flake configuration"
    echo ""
    
    echo -e "${BLUE}[2/7] Validating JSON Configuration${NC}"
    echo "------------------------------------"
    validate_json ".github/mcp-servers.json" "MCP servers configuration"
    if [ -f ".github/devcontainer.json" ]; then
        validate_json ".github/devcontainer.json" "Dev container configuration"
    fi
    echo ""
    
    echo -e "${BLUE}[3/7] Validating MCP Structure${NC}"
    echo "--------------------------------"
    validate_mcp_structure ".github/mcp-servers.json"
    echo ""
    
    echo -e "${BLUE}[4/7] Checking Required Tools${NC}"
    echo "------------------------------"
    check_command "node" "Node.js runtime"
    check_command "npm" "npm package manager"
    check_command "npx" "npx command runner"
    check_command "git" "Git version control"
    check_command "jq" "JSON processor"
    echo ""
    
    echo -e "${BLUE}[5/7] Checking Nix Tools${NC}"
    echo "------------------------"
    check_command "nix" "Nix package manager"
    check_command "nix-shell" "Nix shell"
    check_command "nixpkgs-fmt" "Nix formatter"
    echo ""
    
    echo -e "${BLUE}[6/7] Checking Environment Variables${NC}"
    echo "--------------------------------------"
    check_env_var "GITHUB_TOKEN" "GitHub API token" "optional"
    check_env_var "GH_TOKEN" "GitHub token (alternative)" "optional"
    check_env_var "BRAVE_API_KEY" "Brave Search API key" "optional"
    check_env_var "POSTGRES_CONNECTION_STRING" "PostgreSQL connection" "optional"
    check_env_var "MCP_CONFIG_PATH" "MCP config path" "optional"
    echo ""
    
    echo -e "${BLUE}[7/7] Testing MCP Server Availability${NC}"
    echo "---------------------------------------"
    if command -v npx &> /dev/null; then
        echo "Testing GitHub MCP server package availability..."
        # Just check if the package can be resolved, don't actually run it
        if npm info @modelcontextprotocol/server-github &> /dev/null; then
            print_result "PASS" "GitHub MCP server package is available in npm registry"
        else
            print_result "WARN" "Could not verify GitHub MCP server package availability"
        fi
        
        if npm info @modelcontextprotocol/server-filesystem &> /dev/null; then
            print_result "PASS" "Filesystem MCP server package is available in npm registry"
        else
            print_result "WARN" "Could not verify filesystem MCP server package availability"
        fi
    else
        print_result "WARN" "npx not available, skipping MCP server tests"
    fi
    echo ""
    
    # Summary
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Verification Summary${NC}"
    echo -e "${BLUE}================================${NC}"
    echo -e "${GREEN}Passed:${NC}   $PASSED"
    echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
    echo -e "${RED}Failed:${NC}   $FAILED"
    echo ""
    
    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}✅ MCP configuration verification completed successfully!${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Set required environment variables (see .github/SECRETS-QUICK-REFERENCE.md)"
        echo "  2. Enter development environment: nix develop .#mcp"
        echo "  3. Test MCP servers: npx -y @modelcontextprotocol/server-github"
        echo ""
        return 0
    else
        echo -e "${RED}❌ MCP configuration verification failed with $FAILED error(s)${NC}"
        echo ""
        echo "Please review the errors above and check:"
        echo "  - Configuration files exist and are readable"
        echo "  - JSON syntax is valid"
        echo "  - Required tools are installed"
        echo ""
        return 1
    fi
}

# Run main function
main
exit $?
