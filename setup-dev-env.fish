#!/usr/bin/env fish

# Setup script for PantherOS development environment

echo "Setting up PantherOS development environment..."

# Install direnv for automatic environment loading when entering directories
echo "Installing direnv..."
nix profile install nixpkgs#direnv

# Ensure Nix configuration is added to fish config
set fish_config ~/.config/fish/config.fish

# Check if Nix initialization is already present in fish config
if not grep -q "source /nix/var/nix/profiles/default/etc/profile.d/nix.fish" $fish_config 2>/dev/null
    echo "Adding Nix initialization to fish config..."
    echo "
# Nix configuration (if not already loaded by system)
if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix.fish'
    source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
end" >> $fish_config
end

# Check if direnv hook is already present in fish config
if not grep -q "direnv hook fish" $fish_config 2>/dev/null
    echo "Adding direnv hook to fish config..."
    echo "
# direnv configuration
if type -q direnv
    direnv hook fish | source
end" >> $fish_config
end

# Check if fnm configuration needs to be updated
if not grep -q "fnm env --use-on-cd --shell fish" $fish_config 2>/dev/null
    echo "Updating fnm configuration in fish config..."
    # Remove any existing fnm section first
    set temp_config (mktemp)
    awk '
    !in_fnm_block { print }
    /^# fnm \(Fast Node Manager\) initialization/ {
        in_fnm_block = 1
    }
    in_fnm_block && /^end$/ {
        in_fnm_block = 0
    }
    ' $fish_config > $temp_config
    mv $temp_config $fish_config

    # Add the updated fnm configuration
    echo "
# fnm (Fast Node Manager) initialization
# Check if fnm is available before initializing
if type -q fnm
    fnm env --use-on-cd --shell fish | source
else
    # Fallback: add fnm to PATH if installed in standard location
    if test -d \"$HOME/.fnm\"
        set -gx PATH \$PATH \"$HOME/.fnm\"
    end
end" >> $fish_config
end

# Create .envrc file to enable automatic loading of Nix development environment
set envrc_file (pwd)/.envrc
if not test -f $envrc_file
    echo "Creating .envrc file to enable automatic Nix environment loading..."
    echo '#!/usr/bin/env bash

# Enable direnv to load the nix development environment from flake.nix
use flake

# Optionally, you can specify the devShells attribute explicitly
# use nix develop' > $envrc_file

    # Allow the .envrc file to be executed by direnv
    direnv allow
end

# Verify the development shell is properly configured
echo "Verifying development environment..."
if nix flake show . 2>/dev/null | grep -q "devShells.x86_64-linux.default"
    echo "✓ Development shell is properly configured"
else
    echo "⚠ Warning: Development shell may not be properly configured"
end

echo "Environment setup complete!"
echo "For the changes to take effect, please restart your shell or run: source ~/.config/fish/config.fish"
echo "You can now work on your NixOS configuration. The environment will automatically load when you enter this directory."