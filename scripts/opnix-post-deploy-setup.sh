#!/bin/bash
set -e

# OpNix Post-Deployment Setup Script
# This script sets up the OpNix token after initial deployment
# Run this AFTER nixos-anywhere deployment and first boot

echo "=== OpNix Post-Deployment Setup ==="
echo ""
echo "This script will help you transfer the OpNix token to enable"
echo "1Password-based secret management and finalize your secure configuration."
echo ""

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Server detected at IP: $SERVER_IP"
echo ""

# Function to check if SSH is accessible
check_ssh_access() {
    echo "Checking SSH access..."
    if ssh -o ConnectTimeout=5 -o BatchMode=yes root@localhost exit 2>/dev/null; then
        echo "✓ SSH access confirmed (key-based auth working)"
        return 0
    else
        echo "✗ SSH access not available via keys"
        echo ""
        echo "If you can't SSH with keys, you may need to:"
        echo "1. Use Hetzner console to SSH with password (temporarily)"
        echo "2. Or boot into Hetzner Rescue Mode"
        return 1
    fi
}

# Function to install token
install_token() {
    local token_path="$1"
    local server_ip="$2"

    echo ""
    echo "Installing OpNix token from: $token_path"
    echo ""

    # Copy token to server
    if [ ! -f "$token_path" ]; then
        echo "✗ Token file not found at: $token_path"
        return 1
    fi

    echo "Copying token to server..."
    scp -o StrictHostKeyChecking=no "$token_path" root@${server_ip}:/tmp/opnix-token

    echo "Installing token..."
    ssh root@${server_ip} "
        set -e
        sudo mv /tmp/opnix-token /etc/opnix-token
        sudo chmod 600 /etc/opnix-token
        echo 'Token installed successfully'
    "

    echo "✓ Token installed!"
    return 0
}

# Function to verify OpNix service
verify_opnix() {
    local server_ip="$1"

    echo ""
    echo "Verifying OpNix service and secrets..."

    # Check if token file exists on server
    if ! ssh root@${server_ip} "test -f /etc/opnix-token"; then
        echo "✗ Token file not found on server"
        return 1
    fi
    echo "✓ Token file exists"

    # Restart OpNix service
    echo "Restarting OpNix service..."
    ssh root@${server_ip} "sudo systemctl restart onepassword-secrets.service"
    sleep 5

    # Check service status
    if ! ssh root@${server_ip} "systemctl is-active --quiet onepassword-secrets.service"; then
        echo "✗ OpNix service failed to start"
        echo ""
        echo "Check logs with:"
        echo "  ssh root@${server_ip} 'journalctl -u onepassword-secrets.service -n 50'"
        return 1
    fi
    echo "✓ OpNix service is running"

    # Check SSH keys
    echo ""
    echo "Checking SSH keys..."

    if ssh root@${server_ip} "test -s /root/.ssh/authorized_keys"; then
        local root_key_count=$(ssh root@${server_ip} "wc -l < /root/.ssh/authorized_keys")
        echo "✓ Root SSH keys populated ($root_key_count keys)"
    else
        echo "✗ Root SSH keys missing or empty"
        return 1
    fi

    if ssh root@${server_ip} "test -s /home/hbohlen/.ssh/authorized_keys"; then
        local user_key_count=$(ssh root@${server_ip} "wc -l < /home/hbohlen/.ssh/authorized_keys")
        echo "✓ User SSH keys populated ($user_key_count keys)"
    else
        echo "✗ User SSH keys missing or empty"
        return 1
    fi

    # Check Tailscale
    echo ""
    echo "Checking Tailscale..."
    if ssh root@${server_ip} "systemctl is-active --quiet tailscaled.service"; then
        echo "✓ Tailscale service is running"
    else
        echo "⚠ Tailscale service not running (may need auth)"
    fi

    return 0
}

# Function to offer to rebuild with final config
offer_rebuild() {
    local server_ip="$1"

    echo ""
    echo "=== Setup Complete ==="
    echo ""
    echo "All secrets have been populated successfully!"
    echo ""
    echo "Your SSH configuration is now fully secure with key-based auth only."
    echo "You can now rebuild with the final configuration (though it's already applied)."
    echo ""
    echo "To rebuild and ensure everything is consistent:"
    echo "  ssh root@${server_ip}"
    echo "  sudo nixos-rebuild switch --flake '.#hetzner-vps'"
    echo ""
    echo "To test SSH as the hbohlen user:"
    echo "  ssh hbohlen@${server_ip}"
    echo ""
    echo "To verify OpNix is working:"
    echo "  ssh root@${server_ip} '/root/scripts/verify-opnix.sh'"
    echo ""
}

# Main execution
main() {
    # Check if token path provided
    if [ -z "$1" ]; then
        echo "Usage: $0 <path-to-opnix-token> [server-ip]"
        echo ""
        echo "Example:"
        echo "  $0 ~/opnix-token.txt"
        echo "  $0 ~/opnix-token.txt 1.2.3.4"
        echo ""
        return 1
    fi

    local token_path="$1"
    local server_ip="${2:-$SERVER_IP}"

    # Check SSH access first
    if ! check_ssh_access; then
        echo ""
        echo "Note: This script requires SSH key access to the server."
        echo "If you need to use password auth temporarily, you can:"
        echo "  1. Use Hetzner console to SSH"
        echo "  2. Run this script locally on the server after SSH'ing in"
        echo ""
        echo "Attempting to continue anyway..."
        echo ""
    fi

    # Install token
    if ! install_token "$token_path" "$server_ip"; then
        echo ""
        echo "✗ Failed to install token"
        echo ""
        echo "You can try again with:"
        echo "  $0 $token_path $server_ip"
        return 1
    fi

    # Verify OpNix
    if ! verify_opnix "$server_ip"; then
        echo ""
        echo "✗ Verification failed"
        echo ""
        echo "Troubleshooting steps:"
        echo "  1. Check OpNix logs: ssh root@${server_ip} 'journalctl -u onepassword-secrets.service'"
        echo "  2. Verify token is valid: cat /etc/opnix-token"
        echo "  3. Check OpNix vault: ssh root@${server_ip} 'opnix secrets list'"
        return 1
    fi

    # Offer rebuild
    offer_rebuild "$server_ip"

    return 0
}

main "$@"
