#!/usr/bin/env bash

# Script to fully configure fish shell with diagnostics for misconfigurations
# Checks fish configuration, Nix integration, direnv setup, and provides fixes

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "Fish Shell Configuration and Diagnostic Tool"
echo "============================================"

# Function to print with color
print_status() {
    printf "${GREEN}[INFO]${NC} $1\n"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} $1\n"
}

print_error() {
    printf "${RED}[ERROR]${NC} $1\n"
}

print_diagnostic() {
    printf "${BLUE}[DIAGNOSTIC]${NC} $1\n"
}

# Check if fish is installed
if ! command -v fish &> /dev/null; then
    print_error "Fish shell is not installed!"
    print_status "Install fish using: sudo nix profile install nixpkgs#fish"
    exit 1
else
    print_status "✓ Fish shell is installed"
fi

# Get fish config path
FISH_CONFIG="$HOME/.config/fish/config.fish"

# Function to check if a command exists in a file
check_config_contains() {
    local pattern=$1
    local file=$2
    if [ -f "$file" ] && grep -q "$pattern" "$file"; then
        return 0
    else
        return 1
    fi
}

# Check if fish config file exists
if [ ! -f "$FISH_CONFIG" ]; then
    print_warning "Fish config file does not exist: $FISH_CONFIG"
    print_status "Creating fish config directory and file..."
    mkdir -p "$(dirname "$FISH_CONFIG")"
    touch "$FISH_CONFIG"
    print_status "Created $FISH_CONFIG"
fi

print_status "Checking fish configuration..."

# Check for Nix initialization
if check_config_contains "nix.fish" "$FISH_CONFIG"; then
    print_status "✓ Nix initialization found in fish config"
else
    print_warning "Nix initialization not found in fish config"
    print_status "Adding Nix initialization to fish config..."
    {
        echo ""
        echo "# Nix configuration (if not already loaded by system)"
        echo 'if test -e "/nix/var/nix/profiles/default/etc/profile.d/nix.fish"'
        echo "    source /nix/var/nix/profiles/default/etc/profile.d/nix.fish"
        echo "end"
    } >> "$FISH_CONFIG"
    print_status "Nix initialization added to fish config"
fi

# Check for direnv integration
if check_config_contains "direnv hook fish" "$FISH_CONFIG"; then
    print_status "✓ Direnv hook found in fish config"
else
    print_warning "Direnv hook not found in fish config"
    print_status "Adding direnv hook to fish config..."
    {
        echo ""
        echo "# direnv configuration"
        echo "if type -q direnv"
        echo "    direnv hook fish | source"
        echo "end"
    } >> "$FISH_CONFIG"
    print_status "Direnv hook added to fish config"
fi

# Check for fnm configuration (if used)
if check_config_contains "fnm env" "$FISH_CONFIG"; then
    print_status "✓ fnm configuration found in fish config"
else
    print_diagnostic "fnm configuration not found in fish config (this may be OK if not using fnm)"
    # Add improved fnm configuration
    {
        echo ""
        echo "# fnm (Fast Node Manager) initialization"
        echo "# Check if fnm is available before initializing"
        echo "if type -q fnm"
        echo "    fnm env --use-on-cd --shell fish | source"
        echo "else"
        echo "    # Fallback: add fnm to PATH if installed in standard location"
        echo '    if test -d "$HOME/.fnm"'
        echo '        set -gx PATH $PATH "$HOME/.fnm"'
        echo "    end"
        echo "end"
    } >> "$FISH_CONFIG"
    print_status "Added improved fnm configuration to fish config"
fi

print_status "Checking direnv installation..."

# Check if direnv is installed
if command -v direnv &> /dev/null; then
    print_status "✓ Direnv is installed"
else
    print_error "Direnv is not installed!"
    print_status "Installing direnv using nix..."
    nix profile install nixpkgs#direnv
    print_status "Direnv installed"
fi

# Check if direnv is working with fish
print_status "Checking direnv integration with fish shell..."
FISH_FUNC_DIR="$HOME/.config/fish/functions"
mkdir -p "$FISH_FUNC_DIR"

# Check if direnv has created the necessary function file
if [ -f "$FISH_FUNC_DIR/direnv.fish" ]; then
    print_status "✓ Direnv fish function file exists"
else
    # Try to create the hook manually if it's not in the config
    print_status "Creating direnv fish hook..."
    direnv hook fish > "$FISH_FUNC_DIR/direnv.fish"
    if [ -f "$FISH_FUNC_DIR/direnv.fish" ]; then
        print_status "Direnv fish hook created"
    else
        print_error "Failed to create direnv fish hook"
    fi
fi

# Check project .envrc file
PANTHEROS_DIR="$HOME/dev/pantherOS"
if [ -d "$PANTHEROS_DIR" ]; then
    ENVRC_FILE="$PANTHEROS_DIR/.envrc"
    if [ -f "$ENVRC_FILE" ]; then
        print_status "✓ .envrc file exists in pantherOS directory"
        # Check if it contains the proper configuration
        if grep -q "use flake" "$ENVRC_FILE"; then
            print_status "✓ .envrc file contains 'use flake' directive"
        else
            print_warning ".envrc file doesn't contain 'use flake' directive"
            print_status "Updating .envrc file to use flake..."
            echo '#!/usr/bin/env bash

# Enable direnv to load the nix development environment from flake.nix
use flake

# Optionally, you can specify the devShells attribute explicitly
# use nix develop' > "$ENVRC_FILE"
            print_status ".envrc file updated with flake directive"
        fi
    else
        print_warning "No .envrc file found in pantherOS directory"
        print_status "Creating .envrc file in pantherOS directory..."
        echo '#!/usr/bin/env bash

# Enable direnv to load the nix development environment from flake.nix
use flake

# Optionally, you can specify the devShells attribute explicitly
# use nix develop' > "$ENVRC_FILE"
        print_status ".envrc file created"
    fi
    
    # Ensure the .envrc file is allowed by direnv
    cd "$PANTHEROS_DIR"
    if direnv status 2>/dev/null | grep -q "Found RC allowed 0"; then
        print_warning "Direnv not allowed for pantherOS directory"
        print_status "Allowing direnv for pantherOS directory..."
        direnv allow
        print_status "Direnv allowed for pantherOS directory"
    else
        print_status "✓ Direnv is allowed for pantherOS directory"
    fi
else
    print_warning "pantherOS directory not found at $PANTHEROS_DIR"
    print_status "This script assumes the project is at $HOME/dev/pantherOS"
fi

# Verify nix commands work in fish
print_status "Testing Nix integration in fish shell..."
if fish -c "nix --version" &>/dev/null; then
    print_status "✓ Nix commands work in fish shell"
else
    print_error "Nix commands don't work properly in fish shell"
    print_warning "You may need to restart your shell or relogin for changes to take effect"
fi

# Check if fish is the current shell
if [ "$SHELL" = "$(which fish)" ]; then
    print_status "✓ Fish is set as the current shell"
else
    print_warning "Fish is not set as the current shell"
    print_status "To change your default shell to fish, run: chsh -s $(which fish)"
fi

# Final summary
print_status "Fish shell configuration complete!"
print_status ""
print_status "Next steps:"
print_status "1. If this is a new configuration, restart your shell or run: source $FISH_CONFIG"
print_status "2. Enter your project directory (cd ~/dev/pantherOS) to test automatic environment loading"
print_status "3. You should see the development environment load automatically with direnv"

# Run a diagnostic check
print_diagnostic ""
print_diagnostic "Diagnostic Summary:"
print_diagnostic "- Fish shell: $(if command -v fish &> /dev/null; then echo 'INSTALLED'; else echo 'NOT INSTALLED'; fi)"
print_diagnostic "- Nix integration: $(if check_config_contains 'nix.fish' '$FISH_CONFIG'; then echo 'CONFIGURED'; else echo 'NOT CONFIGURED'; fi)"
print_diagnostic "- Direnv integration: $(if check_config_contains 'direnv hook fish' '$FISH_CONFIG'; then echo 'CONFIGURED'; else echo 'NOT CONFIGURED'; fi)"
print_diagnostic "- Project .envrc: $(if [ -f '$HOME/dev/pantherOS/.envrc' ]; then echo 'EXISTS'; else echo 'NOT FOUND'; fi)"
print_diagnostic ""