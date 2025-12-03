# Fish completions for OpenCode
# Provides command-line completions for the OpenCode AI coding assistant

complete -c opencode -s h -l help -d 'Show help message'
complete -c opencode -s v -l version -d 'Show version information'
complete -c opencode -l config -d 'Specify config file path' -r -F
complete -c opencode -l agents -d 'Use agents mode'
complete -c opencode -l commands -d 'Use commands mode'
complete -c opencode -l skills -d 'Use skills mode'
complete -c opencode -l debug -d 'Enable debug mode'
complete -c opencode -l verbose -d 'Enable verbose output'

# Subcommands
complete -c opencode -n '__fish_use_subcommand' -a 'agent' -d 'Agent management'
complete -c opencode -n '__fish_use_subcommand' -a 'context' -d 'Context management'
complete -c opencode -n '__fish_use_subcommand' -a 'workflow' -d 'Workflow management'
complete -c opencode -n '__fish_use_subcommand' -a 'validate' -d 'Validate configuration'
complete -c opencode -n '__fish_use_subcommand' -a 'optimize' -d 'Optimize code'
complete -c opencode -n '__fish_use_subcommand' -a 'openspec' -d 'OpenSpec integration'
complete -c opencode -n '__fish_use_subcommand' -a 'test' -d 'Run tests'
complete -c opencode -n '__fish_use_subcommand' -a 'build' -d 'Build project'
complete -c opencode -n '__fish_use_subcommand' -a 'clean' -d 'Clean build artifacts'
complete -c opencode -n '__fish_use_subcommand' -a 'commit' -d 'Create commit'
