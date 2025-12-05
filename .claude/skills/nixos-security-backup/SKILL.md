---
name: NixOS Security Backup
description: Implement security measures including 1Password for secrets management and backup strategies with attic for system and data backup. When configuring secrets management, backup systems, or security tools.
---
# NixOS Security Backup

## When to use this skill:

- Setting up 1Password CLI and GUI applications
- Configuring secrets management and credential storage
- Using 1Password for SSH key management
- Setting up attic for NixOS backup system
- Configuring backup patterns and retention policies
- Automating regular backups with systemd timers
- Storing backups to local or remote locations
- Managing encryption for sensitive data
- Setting up secrets in environment variables
- Configuring polkit policies for 1Password GUI
- Creating recovery and restoration procedures

## Best Practices
- programs.onepassword-gui.enable = true; polkitPolicyOwners = [ &quot;hbohlen&quot; ];
- services.atticd.enable = true; modules/backup/default.nix patterns.
