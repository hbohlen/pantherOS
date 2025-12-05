# Fish completions for OpenAgent
# Provides command-line completions for OpenAgent commands

complete -c openagent -s h -l help -d 'Show help message'
complete -c openagent -s v -l version -d 'Show version information'
complete -c openagent -l config -d 'Specify config file path' -r -F
complete -c openagent -l debug -d 'Enable debug mode'
complete -c openagent -l dcp -d 'Enable DCP plugin'

# Subcommands
complete -c openagent -n '__fish_use_subcommand' -a 'start' -d 'Start an agent'
complete -c openagent -n '__fish_use_subcommand' -a 'stop' -d 'Stop an agent'
complete -c openagent -n '__fish_use_subcommand' -a 'status' -d 'Check agent status'
complete -c openagent -n '__fish_use_subcommand' -a 'list' -d 'List available agents'
complete -c openagent -n '__fish_use_subcommand' -a 'session' -d 'Manage sessions'
