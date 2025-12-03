# Fish completions for Podman
# Completions for Podman container management

# Main podman subcommands
complete -c podman -n '__fish_use_subcommand' -a 'run' -d 'Run a container'
complete -c podman -n '__fish_use_subcommand' -a 'ps' -d 'List containers'
complete -c podman -n '__fish_use_subcommand' -a 'images' -d 'List images'
complete -c podman -n '__fish_use_subcommand' -a 'pull' -d 'Pull an image'
complete -c podman -n '__fish_use_subcommand' -a 'push' -d 'Push an image'
complete -c podman -n '__fish_use_subcommand' -a 'build' -d 'Build an image'
complete -c podman -n '__fish_use_subcommand' -a 'exec' -d 'Execute command in container'
complete -c podman -n '__fish_use_subcommand' -a 'logs' -d 'Fetch container logs'
complete -c podman -n '__fish_use_subcommand' -a 'start' -d 'Start containers'
complete -c podman -n '__fish_use_subcommand' -a 'stop' -d 'Stop containers'
complete -c podman -n '__fish_use_subcommand' -a 'restart' -d 'Restart containers'
complete -c podman -n '__fish_use_subcommand' -a 'rm' -d 'Remove containers'
complete -c podman -n '__fish_use_subcommand' -a 'rmi' -d 'Remove images'
complete -c podman -n '__fish_use_subcommand' -a 'inspect' -d 'Display detailed info'
complete -c podman -n '__fish_use_subcommand' -a 'volume' -d 'Manage volumes'
complete -c podman -n '__fish_use_subcommand' -a 'network' -d 'Manage networks'
complete -c podman -n '__fish_use_subcommand' -a 'pod' -d 'Manage pods'

# Complete with running containers (cached)
complete -c podman -n '__fish_seen_subcommand_from stop restart logs exec' -xa '(__fish_podman_containers running)'

# Complete with all containers (cached)
complete -c podman -n '__fish_seen_subcommand_from start rm inspect' -xa '(__fish_podman_containers all)'

# Complete with images (cached)
complete -c podman -n '__fish_seen_subcommand_from run rmi tag' -xa '(__fish_podman_images)'

# Function to list containers (cached)
function __fish_podman_containers
    set -l state $argv[1]
    set -l cache_file "$FISH_COMPLETION_CACHE_DIR/podman-containers-$state"
    set -l cache_timeout $FISH_COMPLETION_CACHE_TIMEOUT
    
    if test -n "$cache_file" -a -f "$cache_file"
        set -l cache_age (math (date +%s) - (stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0))
        if test $cache_age -lt $cache_timeout
            cat "$cache_file"
            return
        end
    end
    
    # Generate fresh container list
    if command -v podman &>/dev/null
        if test "$state" = "running"
            podman ps --format "{{.Names}}" | tee "$cache_file"
        else
            podman ps -a --format "{{.Names}}" | tee "$cache_file"
        end
    end
end

# Function to list images (cached)
function __fish_podman_images
    set -l cache_file "$FISH_COMPLETION_CACHE_DIR/podman-images"
    set -l cache_timeout $FISH_COMPLETION_CACHE_TIMEOUT
    
    if test -n "$cache_file" -a -f "$cache_file"
        set -l cache_age (math (date +%s) - (stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0))
        if test $cache_age -lt $cache_timeout
            cat "$cache_file"
            return
        end
    end
    
    # Generate fresh image list
    if command -v podman &>/dev/null
        podman images --format "{{.Repository}}:{{.Tag}}" | tee "$cache_file"
    end
end
