# Fish completions for Nix commands
# Enhanced completions for common Nix package manager operations

# nix-env completions
complete -c nix-env -s i -l install -d 'Install packages' -xa '(__fish_nix_packages)'
complete -c nix-env -s e -l uninstall -d 'Uninstall packages'
complete -c nix-env -s u -l upgrade -d 'Upgrade packages'
complete -c nix-env -s q -l query -d 'Query available/installed packages'
complete -c nix-env -l rollback -d 'Roll back to previous generation'
complete -c nix-env -l list-generations -d 'List all generations'

# nix-shell completions
complete -c nix-shell -s p -l packages -d 'Build environment with packages' -xa '(__fish_nix_packages)'
complete -c nix-shell -l pure -d 'Pure shell environment'
complete -c nix-shell -l run -d 'Run command in shell' -r

# nix flake completions
complete -c nix -n '__fish_seen_subcommand_from flake' -a 'show' -d 'Show flake info'
complete -c nix -n '__fish_seen_subcommand_from flake' -a 'check' -d 'Check flake validity'
complete -c nix -n '__fish_seen_subcommand_from flake' -a 'update' -d 'Update flake inputs'
complete -c nix -n '__fish_seen_subcommand_from flake' -a 'lock' -d 'Create/update lock file'

# Function to list available packages (cached)
function __fish_nix_packages
    # Cache packages for performance
    set -l cache_file "$FISH_COMPLETION_CACHE_DIR/nix-packages"
    set -l cache_timeout $FISH_COMPLETION_CACHE_TIMEOUT
    
    if test -n "$cache_file" -a -f "$cache_file"
        set -l cache_age (math (date +%s) - (stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0))
        if test $cache_age -lt $cache_timeout
            cat "$cache_file"
            return
        end
    end
    
    # Generate fresh package list
    if command -v nix &>/dev/null
        nix-env -qaP | cut -f2 -d' ' | tee "$cache_file"
    end
end
