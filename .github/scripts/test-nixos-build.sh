#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test NixOS builds locally before pushing
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Starting NixOS Build Tests for pantherOS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo -e "${RED}❌ Nix is not installed. Please install Nix first.${NC}"
    echo "   Install with: sh <(curl -L https://nixos.org/nix/install) --daemon"
    exit 1
fi

echo -e "${GREEN}✓ Nix found: $(nix --version)${NC}"

# Enable flakes if not already enabled
export NIX_CONFIG="experimental-features = nix-command flakes"

# Test 1: Flake check
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📋 Test 1: Checking flake validity..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if nix flake check --no-build 2>&1; then
    echo -e "${GREEN}✓ Flake check passed${NC}"
else
    echo -e "${RED}❌ Flake check failed${NC}"
    exit 1
fi

# Test 2: Show flake info
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📋 Test 2: Flake metadata..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
nix flake metadata

# Test 3: Build configurations
HOSTS=("ovh-cloud" "hetzner-cloud")
for host in "${HOSTS[@]}"; do
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "📋 Test 3: Building $host configuration..."
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if nix build ".#nixosConfigurations.$host.config.system.build.toplevel" \
        --print-build-logs \
        --show-trace 2>&1; then
        echo -e "${GREEN}✓ $host build successful${NC}"
        
        # Show closure size
        SIZE=$(nix path-info -S ".#nixosConfigurations.$host.config.system.build.toplevel" 2>/dev/null | \
            awk '{printf "%.2f GB", $2/1024/1024/1024}')
        echo -e "  ${GREEN}Closure size: $SIZE${NC}"
    else
        echo -e "${RED}❌ $host build failed${NC}"
        exit 1
    fi
done

# Test 4: Validate module syntax
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📋 Test 4: Validating NixOS module syntax..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if find hosts -name "*.nix" -exec nix-instantiate --parse {} \; > /dev/null 2>&1; then
    echo -e "${GREEN}✓ All modules have valid syntax${NC}"
else
    echo -e "${RED}❌ Syntax errors found in modules${NC}"
    exit 1
fi

# Test 5: Check for common issues
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📋 Test 5: Checking for common issues..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check for trailing whitespace
if find hosts -name "*.nix" -exec grep -l '[[:space:]]$' {} + 2>/dev/null; then
    echo -e "${YELLOW}⚠ Warning: Trailing whitespace found${NC}"
fi

# Check for tabs
if find hosts -name "*.nix" -exec grep -l $'\t' {} + 2>/dev/null; then
    echo -e "${YELLOW}⚠ Warning: Tabs found (use spaces instead)${NC}"
fi

echo -e "${GREEN}✓ Code quality checks completed${NC}"

# Test 6: Evaluate configurations
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📋 Test 6: Evaluating configuration options..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
for host in "${HOSTS[@]}"; do
    echo "  $host:"
    VERSION=$(nix eval ".#nixosConfigurations.$host.config.system.nixos.version" --raw 2>/dev/null || echo "unknown")
    HOSTNAME=$(nix eval ".#nixosConfigurations.$host.config.networking.hostName" --raw 2>/dev/null || echo "unknown")
    echo "    - NixOS version: $VERSION"
    echo "    - Hostname: $HOSTNAME"
done

# Test 7: Module documentation validation
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📋 Test 7: Validating module documentation..."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

MODULES=(
    "audio-system"
    "wifi-network"
    "display-management"
    "touchpad-input"
    "thermal-management"
    "bluetooth-config"
    "usb-thunderbolt"
)

doc_errors=0
for module in "${MODULES[@]}"; do
    file="code_snippets/system_config/nixos/${module}.nix.md"
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Missing documentation for ${module}${NC}"
        ((doc_errors++))
    else
        echo -e "${GREEN}✓ Documentation exists for ${module}${NC}"
    fi
done

if [ $doc_errors -gt 0 ]; then
    echo -e "${RED}❌ Found $doc_errors missing documentation file(s)${NC}"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ All tests passed successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Summary:${NC}"
echo "  ✓ Flake validation passed"
echo "  ✓ All host configurations built successfully"
echo "  ✓ Module syntax validated"
echo "  ✓ Configuration evaluation completed"
echo "  ✓ Documentation validated"
echo ""
echo -e "${GREEN}You can now safely commit and push your changes.${NC}"
