# Fish completions for podman-compose
# Completions for Podman Compose (Docker Compose alternative)

complete -c podman-compose -n '__fish_use_subcommand' -a 'up' -d 'Create and start containers'
complete -c podman-compose -n '__fish_use_subcommand' -a 'down' -d 'Stop and remove containers'
complete -c podman-compose -n '__fish_use_subcommand' -a 'start' -d 'Start services'
complete -c podman-compose -n '__fish_use_subcommand' -a 'stop' -d 'Stop services'
complete -c podman-compose -n '__fish_use_subcommand' -a 'restart' -d 'Restart services'
complete -c podman-compose -n '__fish_use_subcommand' -a 'ps' -d 'List containers'
complete -c podman-compose -n '__fish_use_subcommand' -a 'logs' -d 'View container logs'
complete -c podman-compose -n '__fish_use_subcommand' -a 'exec' -d 'Execute command in container'
complete -c podman-compose -n '__fish_use_subcommand' -a 'build' -d 'Build services'
complete -c podman-compose -n '__fish_use_subcommand' -a 'pull' -d 'Pull service images'
complete -c podman-compose -n '__fish_use_subcommand' -a 'push' -d 'Push service images'
complete -c podman-compose -n '__fish_use_subcommand' -a 'config' -d 'Validate compose file'
complete -c podman-compose -n '__fish_use_subcommand' -a 'version' -d 'Show version'

# Common options
complete -c podman-compose -s f -l file -d 'Specify compose file' -r -F
complete -c podman-compose -s p -l project-name -d 'Specify project name' -r
complete -c podman-compose -s d -l detach -d 'Run in background'
complete -c podman-compose -l no-cache -d 'Do not use cache when building'
complete -c podman-compose -l build -d 'Build images before starting'
complete -c podman-compose -l force-recreate -d 'Recreate containers'
complete -c podman-compose -l no-deps -d "Don't start linked services"
