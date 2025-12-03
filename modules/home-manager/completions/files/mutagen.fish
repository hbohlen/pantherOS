# Fish completions for Mutagen
# Completions for Mutagen file synchronization tool

# Main mutagen subcommands
complete -c mutagen -n '__fish_use_subcommand' -a 'sync' -d 'Manage sync sessions'
complete -c mutagen -n '__fish_use_subcommand' -a 'forward' -d 'Manage forwarding sessions'
complete -c mutagen -n '__fish_use_subcommand' -a 'daemon' -d 'Manage Mutagen daemon'
complete -c mutagen -n '__fish_use_subcommand' -a 'project' -d 'Manage projects'
complete -c mutagen -n '__fish_use_subcommand' -a 'compose' -d 'Orchestrate projects'

# sync subcommands
complete -c mutagen -n '__fish_seen_subcommand_from sync' -a 'create' -d 'Create sync session'
complete -c mutagen -n '__fish_seen_subcommand_from sync' -a 'list' -d 'List sync sessions'
complete -c mutagen -n '__fish_seen_subcommand_from sync' -a 'monitor' -d 'Monitor sync sessions'
complete -c mutagen -n '__fish_seen_subcommand_from sync' -a 'pause' -d 'Pause sync sessions'
complete -c mutagen -n '__fish_seen_subcommand_from sync' -a 'resume' -d 'Resume sync sessions'
complete -c mutagen -n '__fish_seen_subcommand_from sync' -a 'terminate' -d 'Terminate sync sessions'
complete -c mutagen -n '__fish_seen_subcommand_from sync' -a 'reset' -d 'Reset sync sessions'
complete -c mutagen -n '__fish_seen_subcommand_from sync' -a 'flush' -d 'Flush sync sessions'

# forward subcommands
complete -c mutagen -n '__fish_seen_subcommand_from forward' -a 'create' -d 'Create forward session'
complete -c mutagen -n '__fish_seen_subcommand_from forward' -a 'list' -d 'List forward sessions'
complete -c mutagen -n '__fish_seen_subcommand_from forward' -a 'pause' -d 'Pause forward sessions'
complete -c mutagen -n '__fish_seen_subcommand_from forward' -a 'resume' -d 'Resume forward sessions'
complete -c mutagen -n '__fish_seen_subcommand_from forward' -a 'terminate' -d 'Terminate forward sessions'

# Complete with session names (cached)
complete -c mutagen -n '__fish_seen_subcommand_from pause resume terminate reset flush; and __fish_seen_subcommand_from sync forward' -xa '(__fish_mutagen_sessions)'

# Function to list Mutagen sessions (cached)
function __fish_mutagen_sessions
    set -l cache_file "$FISH_COMPLETION_CACHE_DIR/mutagen-sessions"
    set -l cache_timeout $FISH_COMPLETION_CACHE_TIMEOUT
    
    if test -n "$cache_file" -a -f "$cache_file"
        set -l cache_age (math (date +%s) - (stat -c %Y "$cache_file" 2>/dev/null || echo 0))
        if test $cache_age -lt $cache_timeout
            cat "$cache_file"
            return
        end
    end
    
    # Generate fresh session list
    if command -v mutagen &>/dev/null
        mutagen sync list 2>/dev/null | awk '/Session:/ {print $2}' | tee "$cache_file"
    end
end
