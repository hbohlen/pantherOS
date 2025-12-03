# Fish completions for Git
# Enhanced completions for common Git operations

# Git subcommands with descriptions
complete -c git -n '__fish_use_subcommand' -a 'add' -d 'Add files to staging'
complete -c git -n '__fish_use_subcommand' -a 'commit' -d 'Commit changes'
complete -c git -n '__fish_use_subcommand' -a 'push' -d 'Push commits to remote'
complete -c git -n '__fish_use_subcommand' -a 'pull' -d 'Pull changes from remote'
complete -c git -n '__fish_use_subcommand' -a 'fetch' -d 'Fetch changes from remote'
complete -c git -n '__fish_use_subcommand' -a 'status' -d 'Show working tree status'
complete -c git -n '__fish_use_subcommand' -a 'log' -d 'Show commit logs'
complete -c git -n '__fish_use_subcommand' -a 'diff' -d 'Show changes'
complete -c git -n '__fish_use_subcommand' -a 'branch' -d 'List, create, or delete branches'
complete -c git -n '__fish_use_subcommand' -a 'checkout' -d 'Switch branches or restore files'
complete -c git -n '__fish_use_subcommand' -a 'switch' -d 'Switch branches'
complete -c git -n '__fish_use_subcommand' -a 'restore' -d 'Restore working tree files'
complete -c git -n '__fish_use_subcommand' -a 'merge' -d 'Join development histories'
complete -c git -n '__fish_use_subcommand' -a 'rebase' -d 'Reapply commits on another base'
complete -c git -n '__fish_use_subcommand' -a 'reset' -d 'Reset current HEAD'
complete -c git -n '__fish_use_subcommand' -a 'stash' -d 'Stash changes'
complete -c git -n '__fish_use_subcommand' -a 'tag' -d 'Create, list, delete tags'
complete -c git -n '__fish_use_subcommand' -a 'remote' -d 'Manage remotes'
complete -c git -n '__fish_use_subcommand' -a 'clone' -d 'Clone repository'
complete -c git -n '__fish_use_subcommand' -a 'init' -d 'Initialize repository'

# Complete with branches (cached)
complete -c git -n '__fish_seen_subcommand_from checkout switch merge rebase' -xa '(__fish_git_branches)'

# Complete with remotes (cached)
complete -c git -n '__fish_seen_subcommand_from push pull fetch' -xa '(__fish_git_remotes)'

# Function to list git branches (cached)
function __fish_git_branches
    set -l cache_file "$FISH_COMPLETION_CACHE_DIR/git-branches-(pwd | string replace -a / -)"
    set -l cache_timeout $FISH_COMPLETION_CACHE_TIMEOUT
    
    if test -n "$cache_file" -a -f "$cache_file"
        set -l cache_age (math (date +%s) - (stat -c %Y "$cache_file" 2>/dev/null || echo 0))
        if test $cache_age -lt $cache_timeout
            cat "$cache_file"
            return
        end
    end
    
    # Generate fresh branch list
    if git rev-parse --git-dir &>/dev/null
        git branch --format='%(refname:short)' | tee "$cache_file"
    end
end

# Function to list git remotes (cached)
function __fish_git_remotes
    set -l cache_file "$FISH_COMPLETION_CACHE_DIR/git-remotes-(pwd | string replace -a / -)"
    set -l cache_timeout $FISH_COMPLETION_CACHE_TIMEOUT
    
    if test -n "$cache_file" -a -f "$cache_file"
        set -l cache_age (math (date +%s) - (stat -c %Y "$cache_file" 2>/dev/null || echo 0))
        if test $cache_age -lt $cache_timeout
            cat "$cache_file"
            return
        end
    end
    
    # Generate fresh remote list
    if git rev-parse --git-dir &>/dev/null
        git remote | tee "$cache_file"
    end
end
