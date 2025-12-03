# Fish completions for systemd commands
# Enhanced completions for systemctl and related systemd tools

# systemctl completions
complete -c systemctl -n '__fish_use_subcommand' -a 'start' -d 'Start service'
complete -c systemctl -n '__fish_use_subcommand' -a 'stop' -d 'Stop service'
complete -c systemctl -n '__fish_use_subcommand' -a 'restart' -d 'Restart service'
complete -c systemctl -n '__fish_use_subcommand' -a 'reload' -d 'Reload service'
complete -c systemctl -n '__fish_use_subcommand' -a 'status' -d 'Show service status'
complete -c systemctl -n '__fish_use_subcommand' -a 'enable' -d 'Enable service'
complete -c systemctl -n '__fish_use_subcommand' -a 'disable' -d 'Disable service'
complete -c systemctl -n '__fish_use_subcommand' -a 'list-units' -d 'List units'
complete -c systemctl -n '__fish_use_subcommand' -a 'list-unit-files' -d 'List unit files'
complete -c systemctl -n '__fish_use_subcommand' -a 'daemon-reload' -d 'Reload systemd configuration'

# Complete with available services (cached)
complete -c systemctl -n '__fish_seen_subcommand_from start stop restart reload status enable disable' -xa '(__fish_systemd_services)'

# Function to list systemd services (cached)
function __fish_systemd_services
    set -l cache_file "$FISH_COMPLETION_CACHE_DIR/systemd-services"
    set -l cache_timeout $FISH_COMPLETION_CACHE_TIMEOUT
    
    if test -n "$cache_file" -a -f "$cache_file"
        set -l cache_age (math (date +%s) - (stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0))
        if test $cache_age -lt $cache_timeout
            cat "$cache_file"
            return
        end
    end
    
    # Generate fresh service list
    if command -v systemctl &>/dev/null
        systemctl list-unit-files --type=service --no-legend | awk '{print $1}' | tee "$cache_file"
    end
end

# journalctl completions
complete -c journalctl -s u -l unit -d 'Show logs for unit' -xa '(__fish_systemd_services)'
complete -c journalctl -s f -l follow -d 'Follow log output'
complete -c journalctl -s n -l lines -d 'Number of lines to show' -r
complete -c journalctl -s b -l boot -d 'Show logs from specific boot'
complete -c journalctl -s p -l priority -d 'Filter by priority' -xa 'emerg alert crit err warning notice info debug'
