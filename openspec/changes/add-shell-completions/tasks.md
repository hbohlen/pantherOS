# Implementation Tasks: Shell Completions

## 1. Completion Infrastructure
- [ ] 1.1 Create `modules/shell/completions/default.nix` module
- [ ] 1.2 Set up Fish completions directory structure
- [ ] 1.3 Configure Fish to load custom completions
- [ ] 1.4 Add completion caching configuration
- [ ] 1.5 Create completion testing framework

## 2. OpenCode/OpenAgent Completions
- [ ] 2.1 Create completions for `opencode` command
- [ ] 2.2 Add completions for OpenAgent subcommands (agent, workflow, etc.)
- [ ] 2.3 Add completions for OpenSpec commands (openspec-proposal, openspec-apply, etc.)
- [ ] 2.4 Include dynamic completion for available agents and skills
- [ ] 2.5 Add completion for OpenCode configuration options

## 3. System Management Completions
- [ ] 3.1 Create completions for NixOS commands (nixos-rebuild, nix-build, nix-shell)
- [ ] 3.2 Add completions for custom backup scripts
- [ ] 3.3 Add completions for monitoring commands
- [ ] 3.4 Add completions for network management commands
- [ ] 3.5 Create systemd service completions (start, stop, restart with service names)

## 4. Container Management Completions
- [ ] 4.1 Add Podman command completions
- [ ] 4.2 Add dynamic container name completion
- [ ] 4.3 Add image name completion
- [ ] 4.4 Add volume and network completions
- [ ] 4.5 Add podman-compose completions

## 5. Development Tool Completions
- [ ] 5.1 Integrate git completions
- [ ] 5.2 Add Zellij session completions
- [ ] 5.3 Add Mutagen session completions
- [ ] 5.4 Add direnv completions
- [ ] 5.5 Add project-specific tool completions

## 6. Dynamic Completions
- [ ] 6.1 Create completion generator for systemd services
- [ ] 6.2 Create completion generator for running containers
- [ ] 6.3 Create completion generator for available hosts
- [ ] 6.4 Create completion generator for mounted filesystems
- [ ] 6.5 Create completion generator for network interfaces
- [ ] 6.6 Add caching for expensive dynamic completions

## 7. Alias Completions
- [ ] 7.1 Generate completions for all Fish aliases
- [ ] 7.2 Map alias completions to underlying command completions
- [ ] 7.3 Add descriptions for aliases in completion menu
- [ ] 7.4 Test completion behavior with alias expansion

## 8. Documentation and Testing
- [ ] 8.1 Document how to add new completions
- [ ] 8.2 Create completion development guide
- [ ] 8.3 Test all completions in Fish shell
- [ ] 8.4 Verify completion performance (no lag)
- [ ] 8.5 Document completion caching strategy
