## 1. Implementation

- [ ] Create directory structure for home manager modules (programs/, shells/, services/, etc.)
- [ ] Create default.nix files in each subdirectory to aggregate imports
- [ ] Migrate existing configuration from home/hbohlen/default.nix to modular structure
- [ ] Update flake.nix to reference new modular home configuration
- [ ] Test home manager configuration builds correctly after changes
- [ ] Verify all existing functionality is preserved in new structure

## 2. Module Creation

- [ ] Create programs/ directory with individual module files (git.nix, browsers.nix, etc.)
- [ ] Create shells/ directory with shell-related modules (bash.nix, zsh.nix, etc.)
- [ ] Create services/ directory with user services (gpg-agent.nix, ssh-agent.nix, etc.)
- [ ] Create editors/ directory with editor configurations (nvim.nix, helix.nix, etc.)
- [ ] Create development/ directory with dev tools and configurations
- [ ] Create configs/ directory for additional configuration files

## 3. Migration

- [ ] Extract git configuration to programs/git.nix
- [ ] Extract shell configuration to shells/default.nix and related files
- [ ] Extract editor configurations to editors/ directory
- [ ] Extract user services to services/ directory
- [ ] Extract development tools to development/ directory
- [ ] Verify all configurations work as expected after extraction

## 4. Validation

- [ ] Test home manager configuration generation with `home-manager build`
- [ ] Verify all home configurations work for different hosts
- [ ] Ensure proper import paths in flake.nix reference new structure
- [ ] Validate that all modules follow proper Home Manager patterns
- [ ] Check that option types and descriptions are properly defined
- [ ] Confirm all functionality from original config is preserved

## 5. Documentation

- [ ] Document the new home manager module structure in docs/
- [ ] Add examples of how to add new home modules
- [ ] Update project primer to include home manager module patterns
- [ ] Create guidelines for organizing home configurations
- [ ] Add cross-references between NixOS and Home Manager module patterns