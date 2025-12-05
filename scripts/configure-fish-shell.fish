#!/usr/bin/env fish

# Script to fully configure fish shell with diagnostics for misconfigurations
# Checks fish configuration, Nix integration, direnv setup, and provides fixes

# Colors for output
set -g RED '\033[0;31m'
set -g GREEN '\033[0;32m'
set -g YELLOW '\033[1;33m'
set -g BLUE '\033[0;34m'
set -g NC '\033[0m' # No Color

echo "Fish Shell Configuration and Diagnostic Tool"
echo "============================================"

# Function to print with color
function print_status
    printf "%b[INFO]%b %s\n" "$GREEN" "$NC" $argv
end

function print_warning
    printf "%b[WARNING]%b %s\n" "$YELLOW" "$NC" $argv
end

function print_error
    printf "%b[ERROR]%b %s\n" "$RED" "$NC" $argv
end

function print_diagnostic
    printf "%b[DIAGNOSTIC]%b %s\n" "$BLUE" "$NC" $argv
end

# Check if fish is installed
if not command -v fish &> /dev/null
    print_error "Fish shell is not installed!"
    print_status "Install fish using: sudo nix profile install nixpkgs#fish"
    exit 1
else
    print_status "✓ Fish shell is installed"
end

# Get fish config path
set FISH_CONFIG "$HOME/.config/fish/config.fish"

# Function to check if a command exists in a file
function check_config_contains
    set pattern $argv[1]
    set file $argv[2]
    if test -f "$file"; and grep -q "$pattern" "$file"
        return 0
    else
        return 1
    end
end

# Check if fish config file exists
if not test -f "$FISH_CONFIG"
    print_warning "Fish config file does not exist: $FISH_CONFIG"
    print_status "Creating fish config directory and file..."
    mkdir -p (dirname "$FISH_CONFIG")
    touch "$FISH_CONFIG"
    print_status "Created $FISH_CONFIG"
end

print_status "Checking fish configuration..."

# Check for Nix initialization
if check_config_contains "nix.fish" "$FISH_CONFIG"
    print_status "✓ Nix initialization found in fish config"
else
    print_warning "Nix initialization not found in fish config"
    print_status "Adding Nix initialization to fish config..."
    echo "" >> "$FISH_CONFIG"
    echo "# Nix configuration (if not already loaded by system)" >> "$FISH_CONFIG"
    echo 'if test -e "/nix/var/nix/profiles/default/etc/profile.d/nix.fish"' >> "$FISH_CONFIG"
    echo "    source /nix/var/nix/profiles/default/etc/profile.d/nix.fish" >> "$FISH_CONFIG"
    echo "end" >> "$FISH_CONFIG"
    print_status "Nix initialization added to fish config"
end

# Check for direnv integration
if check_config_contains "direnv hook fish" "$FISH_CONFIG"
    print_status "✓ Direnv hook found in fish config"
else
    print_warning "Direnv hook not found in fish config"
    print_status "Adding direnv hook to fish config..."
    echo "" >> "$FISH_CONFIG"
    echo "# direnv configuration" >> "$FISH_CONFIG"
    echo "if type -q direnv" >> "$FISH_CONFIG"
    echo "    direnv hook fish | source" >> "$FISH_CONFIG"
    echo "end" >> "$FISH_CONFIG"
    print_status "Direnv hook added to fish config"
end

# Check for fnm configuration (if used)
if check_config_contains "fnm env" "$FISH_CONFIG"
    print_status "✓ fnm configuration found in fish config"
else
    print_diagnostic "fnm configuration not found in fish config (this may be OK if not using fnm)"
    # Add improved fnm configuration
    echo "" >> "$FISH_CONFIG"
    echo "# fnm (Fast Node Manager) initialization" >> "$FISH_CONFIG"
    echo "# Check if fnm is available before initializing" >> "$FISH_CONFIG"
    echo "if type -q fnm" >> "$FISH_CONFIG"
    echo "    fnm env --use-on-cd --shell fish | source" >> "$FISH_CONFIG"
    echo "else" >> "$FISH_CONFIG"
    echo "    # Fallback: add fnm to PATH if installed in standard location" >> "$FISH_CONFIG"
    echo '    if test -d "$HOME/.fnm"' >> "$FISH_CONFIG"
    echo '        set -gx PATH $PATH "$HOME/.fnm"' >> "$FISH_CONFIG"
    echo "    end" >> "$FISH_CONFIG"
    echo "end" >> "$FISH_CONFIG"
    print_status "Added improved fnm configuration to fish config"
end

print_status "Checking direnv installation..."

# Check if direnv is installed
if command -v direnv &> /dev/null
    print_status "✓ Direnv is installed"
else
    print_error "Direnv is not installed!"
    print_status "Installing direnv using nix..."
    nix profile install nixpkgs#direnv
    print_status "Direnv installed"
end

# Check if direnv is working with fish
print_status "Checking direnv integration with fish shell..."
set FISH_FUNC_DIR "$HOME/.config/fish/functions"
mkdir -p "$FISH_FUNC_DIR"

# Check if direnv has created the necessary function file
if test -f "$FISH_FUNC_DIR/direnv.fish"
    print_status "✓ Direnv fish function file exists"
else
    # Try to create the hook manually if it's not in the config
    print_status "Creating direnv fish hook..."
    direnv hook fish > "$FISH_FUNC_DIR/direnv.fish"
    if test -f "$FISH_FUNC_DIR/direnv.fish"
        print_status "Direnv fish hook created"
    else
        print_error "Failed to create direnv fish hook"
    end
end

# Check project .envrc file
set PANTHEROS_DIR "$HOME/dev/pantherOS"
if test -d "$PANTHEROS_DIR"
    set ENVRC_FILE "$PANTHEROS_DIR/.envrc"
    if test -f "$ENVRC_FILE"
        print_status "✓ .envrc file exists in pantherOS directory"
        # Check if it contains the proper configuration
        if grep -q "use flake" "$ENVRC_FILE"
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
        end
    else
        print_warning "No .envrc file found in pantherOS directory"
        print_status "Creating .envrc file in pantherOS directory..."
        echo '#!/usr/bin/env bash

# Enable direnv to load the nix development environment from flake.nix
use flake

# Optionally, you can specify the devShells attribute explicitly
# use nix develop' > "$ENVRC_FILE"
        print_status ".envrc file created"
    end

    # Ensure the .envrc file is allowed by direnv
    cd "$PANTHEROS_DIR"
    if direnv status 2>/dev/null | grep -q "Found RC allowed 0"
        print_warning "Direnv not allowed for pantherOS directory"
        print_status "Allowing direnv for pantherOS directory..."
        direnv allow
        print_status "Direnv allowed for pantherOS directory"
    else
        print_status "✓ Direnv is allowed for pantherOS directory"
    end
else
    print_warning "pantherOS directory not found at $PANTHEROS_DIR"
    print_status "This script assumes the project is at \$HOME/dev/pantherOS"
end

# Verify nix commands work in fish
print_status "Testing Nix integration in fish shell..."
if fish -c "nix --version" &>/dev/null
    print_status "✓ Nix commands work in fish shell"
else
    print_error "Nix commands don't work properly in fish shell"
    print_warning "You may need to restart your shell or relogin for changes to take effect"
end

# Check if fish is the current shell
if test "$SHELL" = (which fish)
    print_status "✓ Fish is set as the current shell"
else
    print_warning "Fish is not set as the current shell"
    print_status "To change your default shell to fish, run: chsh -s "(which fish)
end

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
if command -v fish &> /dev/null
    print_diagnostic "- Fish shell: INSTALLED"
else
    print_diagnostic "- Fish shell: NOT INSTALLED"
end
if check_config_contains 'nix.fish' "$FISH_CONFIG"
    print_diagnostic "- Nix integration: CONFIGURED"
else
    print_diagnostic "- Nix integration: NOT CONFIGURED"
end
if check_config_contains 'direnv hook fish' "$FISH_CONFIG"
    print_diagnostic "- Direnv integration: CONFIGURED"
else
    print_diagnostic "- Direnv integration: NOT CONFIGURED"
end
if test -f "$HOME/dev/pantherOS/.envrc"
    print_diagnostic "- Project .envrc: EXISTS"
else
    print_diagnostic "- Project .envrc: NOT FOUND"
end
print_diagnostic ""
