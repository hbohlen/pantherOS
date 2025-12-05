# Fish completions for backup scripts
# Completions for common backup operations in NixOS

# Generic backup completion
complete -c backup -n '__fish_use_subcommand' -a 'create' -d 'Create new backup'
complete -c backup -n '__fish_use_subcommand' -a 'restore' -d 'Restore from backup'
complete -c backup -n '__fish_use_subcommand' -a 'list' -d 'List available backups'
complete -c backup -n '__fish_use_subcommand' -a 'verify' -d 'Verify backup integrity'
complete -c backup -n '__fish_use_subcommand' -a 'prune' -d 'Prune old backups'

# restic completions (common backup tool in NixOS)
complete -c restic -n '__fish_use_subcommand' -a 'backup' -d 'Create backup'
complete -c restic -n '__fish_use_subcommand' -a 'restore' -d 'Restore backup'
complete -c restic -n '__fish_use_subcommand' -a 'snapshots' -d 'List snapshots'
complete -c restic -n '__fish_use_subcommand' -a 'check' -d 'Check repository'
complete -c restic -n '__fish_use_subcommand' -a 'prune' -d 'Prune repository'
complete -c restic -n '__fish_use_subcommand' -a 'forget' -d 'Remove snapshots'
complete -c restic -s r -l repo -d 'Repository location' -r -F

# borg completions (another common backup tool)
complete -c borg -n '__fish_use_subcommand' -a 'create' -d 'Create backup archive'
complete -c borg -n '__fish_use_subcommand' -a 'extract' -d 'Extract archive'
complete -c borg -n '__fish_use_subcommand' -a 'list' -d 'List archives'
complete -c borg -n '__fish_use_subcommand' -a 'delete' -d 'Delete archive'
complete -c borg -n '__fish_use_subcommand' -a 'prune' -d 'Prune repository'
complete -c borg -n '__fish_use_subcommand' -a 'info' -d 'Show archive info'
