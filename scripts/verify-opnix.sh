#!/bin/bash
set -e

# OpNix Verification Script
# This script verifies that OpNix is properly configured and working

echo "=== OpNix Verification Script ==="
echo ""
echo "This script checks that:"
echo "  - OpNix token file exists"
echo "  - OpNix service is running"
echo "  - SSH keys are populated from OpNix"
echo "  - Tailscale is configured correctly"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
all_passed=true

# Check 1: Token file exists
echo "Check 1: OpNix token file"
if [ -f /etc/opnix-token ]; then
    echo -e "${GREEN}✓${NC} Token file exists at /etc/opnix-token"
    ls -lh /etc/opnix-token
else
    echo -e "${RED}✗${NC} Token file missing at /etc/opnix-token"
    all_passed=false
fi
echo ""

# Check 2: OpNix service is running
echo "Check 2: OpNix service status"
if systemctl is-active --quiet onepassword-secrets.service; then
    echo -e "${GREEN}✓${NC} onepassword-secrets.service is running"
    systemctl status onepassword-secrets.service --no-pager -l
else
    echo -e "${RED}✗${NC} onepassword-secrets.service is not running"
    echo ""
    echo "Recent logs:"
    journalctl -u onepassword-secrets.service --no-pager -n 20
    all_passed=false
fi
echo ""

# Check 3: SSH keys populated
echo "Check 3: SSH keys from OpNix"

# Check root SSH keys
if [ -f /root/.ssh/authorized_keys ] && [ -s /root/.ssh/authorized_keys ]; then
    local root_key_count=$(wc -l < /root/.ssh/authorized_keys)
    echo -e "${GREEN}✓${NC} Root SSH keys populated ($root_key_count keys)"
    echo "  First key: $(head -1 /root/.ssh/authorized_keys | cut -c1-50)..."
else
    echo -e "${RED}✗${NC} Root SSH keys missing or empty"
    all_passed=false
fi

# Check user SSH keys
if [ -f /home/hbohlen/.ssh/authorized_keys ] && [ -s /home/hbohlen/.ssh/authorized_keys ]; then
    local user_key_count=$(wc -l < /home/hbohlen/.ssh/authorized_keys)
    echo -e "${GREEN}✓${NC} User SSH keys populated ($user_key_count keys)"
    echo "  First key: $(head -1 /home/hbohlen/.ssh/authorized_keys | cut -c1-50)..."
else
    echo -e "${RED}✗${NC} User SSH keys missing or empty"
    all_passed=false
fi
echo ""

# Check 4: Tailscale configuration
echo "Check 4: Tailscale service"
if systemctl is-active --quiet tailscaled.service; then
    echo -e "${GREEN}✓${NC} tailscaled.service is running"

    # Check if Tailscale is up
    if tailscale status >/dev/null 2>&1; then
        local ts_status=$(tailscale status --json | jq -r '.BackendState' 2>/dev/null || echo "unknown")
        echo "  Tailscale status: $ts_status"
    else
        echo -e "${YELLOW}⚠${NC} Tailscale not authenticated (expected after first boot)"
    fi

    # Check auth key file
    if [ -f /etc/tailscale/auth-key ]; then
        echo -e "${GREEN}✓${NC} Auth key file exists"
    else
        echo -e "${RED}✗${NC} Auth key file missing"
        all_passed=false
    fi
else
    echo -e "${RED}✗${NC} tailscaled.service is not running"
    all_passed=false
fi
echo ""

# Check 5: OpNix can list secrets
echo "Check 5: OpNix can access vault"
if command -v opnix >/dev/null 2>&1; then
    if opnix secrets list >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} OpNix can list secrets from vault"
        echo "Available secrets:"
        opnix secrets list --format human | sed 's/^/  /'
    else
        echo -e "${YELLOW}⚠${NC} OpNix cannot list secrets (may be normal if token not yet active)"
    fi
else
    echo -e "${YELLOW}⚠${NC} opnix command not available"
fi
echo ""

# Check 6: SSH configuration
echo "Check 6: SSH configuration"
if [ -f /etc/ssh/sshd_config ]; then
    echo "Current SSH settings:"
    echo "  PasswordAuthentication: $(grep '^PasswordAuthentication' /etc/ssh/sshd_config || echo 'not explicitly set')"
    echo "  PermitRootLogin: $(grep '^PermitRootLogin' /etc/ssh/sshd_config || echo 'not explicitly set')"
    echo "  PubkeyAuthentication: $(grep '^PubkeyAuthentication' /etc/ssh/sshd_config || echo 'not explicitly set')"
fi
echo ""

# Check 7: File permissions
echo "Check 7: Security permissions"
if [ -f /etc/opnix-token ]; then
    local token_perms=$(stat -c '%a' /etc/opnix-token)
    if [ "$token_perms" = "600" ]; then
        echo -e "${GREEN}✓${NC} Token file permissions correct (600)"
    else
        echo -e "${YELLOW}⚠${NC} Token file permissions: $token_perms (should be 600)"
    fi
fi

if [ -f /root/.ssh/authorized_keys ]; then
    local root_keys_perms=$(stat -c '%a' /root/.ssh/authorized_keys)
    if [ "$root_keys_perms" = "600" ]; then
        echo -e "${GREEN}✓${NC} Root authorized_keys permissions correct (600)"
    else
        echo -e "${YELLOW}⚠${NC} Root authorized_keys permissions: $root_keys_perms (should be 600)"
    fi
fi
echo ""

# Summary
echo "=== Verification Summary ==="
echo ""
if [ "$all_passed" = true ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    echo ""
    echo "Your OpNix configuration is working correctly."
    echo "You can now safely rebuild with the final configuration:"
    echo "  sudo nixos-rebuild switch --flake '.#hetzner-vps'"
    echo ""
    echo "To test SSH access:"
    echo "  ssh hbohlen@$(hostname -I | awk '{print $1}')"
    exit 0
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo ""
    echo "Please review the errors above and:"
    echo "  1. Ensure the OpNix token is correctly placed at /etc/opnix-token"
    echo "  2. Restart the OpNix service: sudo systemctl restart onepassword-secrets.service"
    echo "  3. Check OpNix logs: journalctl -u onepassword-secrets.service"
    echo "  4. Verify OpNix vault accessibility: opnix secrets list"
    echo ""
    echo "For emergency recovery, see: docs/HETZNER_DEPLOYMENT.md#emergency-recovery"
    exit 1
fi
