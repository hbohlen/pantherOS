# Fish completions for direnv
# Completions for direnv environment switcher

complete -c direnv -n '__fish_use_subcommand' -a 'allow' -d 'Grant permission to load .envrc'
complete -c direnv -n '__fish_use_subcommand' -a 'deny' -d 'Revoke permission to load .envrc'
complete -c direnv -n '__fish_use_subcommand' -a 'edit' -d 'Edit .envrc file'
complete -c direnv -n '__fish_use_subcommand' -a 'exec' -d 'Execute command with environment'
complete -c direnv -n '__fish_use_subcommand' -a 'export' -d 'Export shell commands'
complete -c direnv -n '__fish_use_subcommand' -a 'hook' -d 'Output shell hook'
complete -c direnv -n '__fish_use_subcommand' -a 'prune' -d 'Remove old allowed files'
complete -c direnv -n '__fish_use_subcommand' -a 'reload' -d 'Reload environment'
complete -c direnv -n '__fish_use_subcommand' -a 'status' -d 'Show direnv status'
complete -c direnv -n '__fish_use_subcommand' -a 'version' -d 'Show version'

# Complete with shell names for hook command
complete -c direnv -n '__fish_seen_subcommand_from hook' -a 'bash zsh fish' -d 'Shell type'

# Complete with directories that have .envrc files (cached)
complete -c direnv -n '__fish_seen_subcommand_from allow deny' -xa '(__fish_direnv_directories)'

# Function to find directories with .envrc files (cached)
function __fish_direnv_directories
    set -l cache_file "$FISH_COMPLETION_CACHE_DIR/direnv-directories"
    set -l cache_timeout $FISH_COMPLETION_CACHE_TIMEOUT
    
    if test -n "$cache_file" -a -f "$cache_file"
        set -l cache_age (math (date +%s) - (stat -c %Y "$cache_file" 2>/dev/null || echo 0))
        if test $cache_age -lt $cache_timeout
            cat "$cache_file"
            return
        end
    end
    
    # Generate fresh directory list
    if command -v direnv &>/dev/null
        find . -maxdepth 3 -name .envrc -type f -exec dirname {} \; 2>/dev/null | tee "$cache_file"
    end
end
