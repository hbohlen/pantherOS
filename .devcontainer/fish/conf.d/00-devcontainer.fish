# DevContainer Fish Shell Configuration
# Auto-loaded when fish starts in the devcontainer

# Set environment variables
set -gx EDITOR vim
set -gx VISUAL vim

# Nix integration
if test -e "/nix/var/nix/profiles/default/etc/profile.d/nix.fish"
    source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
end

# direnv integration for automatic environment loading
if type -q direnv
    direnv hook fish | source
end

# Aliases for common operations
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Nix aliases
alias nb='nix build'
alias nd='nix develop'
alias nf='nix flake'
alias nr='nix run'

# OpenCode aliases
if type -q opencode
    alias oc='opencode'
end

# Better ls with eza if available
if type -q eza
    alias ls='eza --icons'
    alias ll='eza -lah --icons'
    alias la='eza -A --icons'
    alias lt='eza --tree --icons'
end

# Welcome message
if status is-interactive
    echo "🐟 Fish shell in pantherOS devcontainer"
    echo "📦 Nix, OpenCode, and development tools ready"
end
