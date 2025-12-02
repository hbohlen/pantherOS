#!/usr/bin/env bash
# Setup script for GitHub Copilot Coding Agent with NixOS testing capabilities
# This script helps configure the local environment and VPS access

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

check_command() {
    if command -v "$1" &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_warning "$1 is not installed"
        return 1
    fi
}

# Main script
print_header "GitHub Copilot Coding Agent Setup"

print_info "This script will help you set up the environment for GitHub Copilot"
print_info "with NixOS testing capabilities and MCP servers."
echo ""

# Check prerequisites
print_header "Checking Prerequisites"

# Check Nix
if check_command "nix"; then
    NIX_VERSION=$(nix --version)
    print_info "Nix version: $NIX_VERSION"
else
    print_error "Nix is not installed. Please install it first:"
    echo "  curl -L https://nixos.org/nix/install | sh -s -- --daemon"
    exit 1
fi

# Check Node.js
if check_command "node"; then
    NODE_VERSION=$(node --version)
    print_info "Node.js version: $NODE_VERSION"
else
    print_warning "Node.js is not installed. Installing via Nix..."
    nix profile install nixpkgs#nodejs
    print_success "Node.js installed"
fi

# Check Git
if check_command "git"; then
    GIT_VERSION=$(git --version)
    print_info "Git version: $GIT_VERSION"
else
    print_error "Git is not installed"
    exit 1
fi

# Check SSH
if check_command "ssh"; then
    print_success "SSH is available"
else
    print_error "SSH is not installed"
    exit 1
fi

# Configure Nix with flakes
print_header "Configuring Nix"

NIX_CONFIG_DIR="$HOME/.config/nix"
NIX_CONFIG_FILE="$NIX_CONFIG_DIR/nix.conf"

if [ ! -f "$NIX_CONFIG_FILE" ]; then
    print_info "Creating Nix configuration with flakes enabled..."
    mkdir -p "$NIX_CONFIG_DIR"
    cat > "$NIX_CONFIG_FILE" << 'EOF'
experimental-features = nix-command flakes
EOF
    print_success "Nix configuration created"
else
    if grep -q "experimental-features.*flakes" "$NIX_CONFIG_FILE"; then
        print_success "Flakes already enabled in Nix configuration"
    else
        print_warning "Adding flakes to Nix configuration..."
        echo "experimental-features = nix-command flakes" >> "$NIX_CONFIG_FILE"
        print_success "Flakes enabled"
    fi
fi

# Setup SSH for VPS (optional)
print_header "VPS SSH Configuration"

read -p "Do you want to configure SSH access to a VPS? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Setting up SSH for VPS access..."
    
    # Get VPS details
    read -p "Enter VPS hostname or IP: " VPS_HOST
    read -p "Enter SSH username (default: nixos): " VPS_USER
    VPS_USER=${VPS_USER:-nixos}
    read -p "Enter SSH port (default: 22): " VPS_PORT
    VPS_PORT=${VPS_PORT:-22}
    
    SSH_KEY_PATH="$HOME/.ssh/copilot_vps"
    
    # Check if key exists
    if [ ! -f "$SSH_KEY_PATH" ]; then
        print_info "Generating SSH key pair..."
        ssh-keygen -t ed25519 -C "copilot-nixos-access" -f "$SSH_KEY_PATH" -N ""
        print_success "SSH key pair generated"
        
        print_info "Public key:"
        cat "${SSH_KEY_PATH}.pub"
        echo ""
        print_warning "Please add this public key to your VPS authorized_keys"
        read -p "Press Enter when you've added the key to your VPS..."
    else
        print_success "SSH key already exists at $SSH_KEY_PATH"
    fi
    
    # Create SSH config
    SSH_CONFIG="$HOME/.ssh/config"
    SSH_CONFIG_ENTRY="Host nixos-vps
  HostName $VPS_HOST
  User $VPS_USER
  Port $VPS_PORT
  IdentityFile $SSH_KEY_PATH
  StrictHostKeyChecking accept-new
  ServerAliveInterval 60
  ServerAliveCountMax 3"
    
    if [ ! -f "$SSH_CONFIG" ]; then
        touch "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
    fi
    
    if grep -q "Host nixos-vps" "$SSH_CONFIG"; then
        print_warning "nixos-vps entry already exists in SSH config"
        read -p "Do you want to update it? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Remove old entry and add new one
            sed -i '/Host nixos-vps/,/^$/d' "$SSH_CONFIG"
            echo "$SSH_CONFIG_ENTRY" >> "$SSH_CONFIG"
            print_success "SSH config updated"
        fi
    else
        echo "$SSH_CONFIG_ENTRY" >> "$SSH_CONFIG"
        print_success "SSH config entry added"
    fi
    
    # Test connection
    print_info "Testing VPS connection..."
    if ssh -o ConnectTimeout=10 nixos-vps 'echo "Connection successful"' 2>/dev/null; then
        print_success "VPS connection successful!"
        
        # Test Nix on VPS
        print_info "Checking Nix installation on VPS..."
        if ssh nixos-vps 'nix --version' 2>/dev/null; then
            print_success "Nix is available on VPS"
        else
            print_error "Nix is not available on VPS"
        fi
    else
        print_error "Could not connect to VPS"
        print_warning "Please check your VPS settings and try again"
    fi
    
    # GitHub Secrets reminder
    print_header "GitHub Secrets Configuration"
    print_warning "Don't forget to add the following secrets to your GitHub repository:"
    echo ""
    echo "1. VPS_HOST: $VPS_HOST"
    echo "2. VPS_USER: $VPS_USER"
    echo "3. VPS_PORT: $VPS_PORT"
    echo "4. VPS_SSH_KEY: (content of $SSH_KEY_PATH)"
    echo ""
    print_info "Private key content:"
    cat "$SSH_KEY_PATH"
    echo ""
fi

# Test MCP servers
print_header "Testing MCP Servers"

print_info "Testing sequential-thinking MCP server..."
if npx -y @modelcontextprotocol/server-sequential-thinking --version 2>/dev/null; then
    print_success "Sequential-thinking MCP server is available"
else
    print_warning "Could not verify sequential-thinking MCP server"
fi

# Brave Search API key
print_info "For Brave Search MCP, you'll need an API key"
print_info "Get one at: https://brave.com/search/api/"
read -p "Do you have a Brave Search API key? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your Brave Search API key: " BRAVE_API_KEY
    print_warning "Add this to GitHub Secrets as: BRAVE_API_KEY"
fi

# Test local NixOS build
print_header "Testing Local NixOS Build"

if [ -f "flake.nix" ]; then
    print_info "Testing flake validation..."
    if nix flake check 2>&1 | grep -q "error:"; then
        print_warning "Flake check found issues"
        print_info "Run 'nix flake check' for details"
    else
        print_success "Flake validation passed"
    fi
    
    print_info "Available NixOS configurations:"
    nix flake show --json 2>/dev/null | grep -o '"nixosConfigurations":{[^}]*}' || print_info "Run 'nix flake show' to see configurations"
else
    print_warning "No flake.nix found in current directory"
fi

# Summary
print_header "Setup Complete!"

print_success "Your environment is now configured for GitHub Copilot Coding Agent"
echo ""
print_info "Next steps:"
echo "  1. Add required secrets to GitHub repository settings:"
echo "     - BRAVE_API_KEY (if using Brave Search)"
echo "     - VPS_SSH_KEY, VPS_HOST, VPS_USER, VPS_PORT (if using VPS)"
echo ""
echo "  2. Review the documentation:"
echo "     - .github/copilot/SETUP.md"
echo "     - .github/copilot/action-setup.yml"
echo ""
echo "  3. Test the configuration:"
echo "     - Local: nix build .#nixosConfigurations.<config>.config.system.build.toplevel"
echo "     - VPS: ssh nixos-vps 'cd ~/pantherOS && nixos-rebuild build --flake .#<config>'"
echo ""
print_info "For more information, see .github/copilot/SETUP.md"

exit 0
