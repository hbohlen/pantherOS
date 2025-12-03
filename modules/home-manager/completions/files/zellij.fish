# Fish completions for Zellij
# Completions for the Zellij terminal multiplexer

complete -c zellij -n '__fish_use_subcommand' -a 'attach' -d 'Attach to session'
complete -c zellij -n '__fish_use_subcommand' -a 'action' -d 'Send action to session'
complete -c zellij -n '__fish_use_subcommand' -a 'convert-config' -d 'Convert config format'
complete -c zellij -n '__fish_use_subcommand' -a 'convert-layout' -d 'Convert layout format'
complete -c zellij -n '__fish_use_subcommand' -a 'convert-theme' -d 'Convert theme format'
complete -c zellij -n '__fish_use_subcommand' -a 'edit' -d 'Edit file in new pane'
complete -c zellij -n '__fish_use_subcommand' -a 'kill-all-sessions' -d 'Kill all sessions'
complete -c zellij -n '__fish_use_subcommand' -a 'kill-session' -d 'Kill specific session'
complete -c zellij -n '__fish_use_subcommand' -a 'list-sessions' -d 'List active sessions'
complete -c zellij -n '__fish_use_subcommand' -a 'options' -d 'Show configuration options'
complete -c zellij -n '__fish_use_subcommand' -a 'run' -d 'Run command in new pane'
complete -c zellij -n '__fish_use_subcommand' -a 'setup' -d 'Setup config files'

# Common options
complete -c zellij -s s -l session -d 'Session name' -r
complete -c zellij -s l -l layout -d 'Layout file to use' -r -F
complete -c zellij -s c -l config -d 'Config file to use' -r -F
complete -c zellij -l debug -d 'Enable debug mode'

# Complete with session names for attach/kill (cached)
complete -c zellij -n '__fish_seen_subcommand_from attach kill-session' -xa '(__fish_zellij_sessions)'

# Function to list Zellij sessions (cached)
function __fish_zellij_sessions
    set -l cache_file "$FISH_COMPLETION_CACHE_DIR/zellij-sessions"
    set -l cache_timeout $FISH_COMPLETION_CACHE_TIMEOUT
    
    if test -n "$cache_file" -a -f "$cache_file"
        set -l cache_age (math (date +%s) - (stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0))
        if test $cache_age -lt $cache_timeout
            cat "$cache_file"
            return
        end
    end
    
    # Generate fresh session list
    if command -v zellij &>/dev/null
        zellij list-sessions 2>/dev/null | awk '{print $1}' | tee "$cache_file"
    end
end
