# Phase 2: Module Development Tasks

**Phase 2 Goal:** Create comprehensive, modular NixOS and home-manager configurations

## High Priority Tasks

### Modularization Strategy Research
**Priority:** High
**Status:** TODO

Research best practices for NixOS and home-manager module organization.

**Research Areas:**
- System module structure and grouping
- Home-manager module best practices
- Single-concern module design
- Nested modular structure approaches
- Directory layout standards and conventions

**Deliverables:**
- Documented modularization strategy
- Module organization decisions
- Naming conventions guide

### System Module Development
**Priority:** High
**Status:** TODO
**Dependencies:** Modularization strategy research complete

Translate system configuration into defined NixOS modules.

**Module Categories:**
- [ ] Core system modules
- [ ] Service modules
- [ ] Security modules
- [ ] Hardware-specific modules

**Requirements:**
- Each module must have single concern
- Proper imports with relative paths
- Options defined with `mkEnableOption` or similar
- Documentation in `docs/modules/nixos/`

### Home-Manager Module Development
**Priority:** High
**Status:** TODO
**Dependencies:** Modularization strategy research complete

Create modular home-manager modules for applications and configurations.

**Module Categories:**
- [ ] Shell (fish, Ghostty)
- [ ] Applications (1Password, Zed, browsers)
- [ ] Development tools (AI CLI tools, LSPs, formatters)
- [ ] Desktop environment (Niri, DankMaterialShell)

**Requirements:**
- Complete modular structure
- Application configuration files managed
- Dotfiles properly organized
- Documentation in `docs/modules/home-manager/`

### Directory Structure Implementation
**Priority:** Medium
**Status:** TODO
**Dependencies:** Module development planning complete

Implement the documented directory structure:

```
/
├── flake.nix
├── lib/
├── overlays/
├── pkgs/
├── profiles/
├── modules/
├── hosts/
│   ├── yoga/
│   ├── zephyrus/
│   └── servers/
└── home/
```

**Deliverables:**
- Finalized directory structure
- Documentation of structure decisions
- Migration of existing configs if needed

## Medium Priority Tasks

### Flake Configuration
**Priority:** Medium
**Status:** TODO
**Dependencies:** Modules defined

Populate `flake.nix` with:
- [ ] All necessary inputs
- [ ] Nixpkgs overlays
- [ ] Module outputs
- [ ] DevShell configuration

### DevShell Configuration
**Priority:** Medium
**Status:** TODO

Configure fully-featured development shell:
- [ ] Auto-activation in `~/dev` directory
- [ ] Complete package set for all languages
- [ ] LSP servers configured
- [ ] Formatters installed

### Language Support
**Priority:** Medium
**Status:** TODO

Configure language environments:
- [ ] Node.js/JavaScript/TypeScript
- [ ] ReactJS
- [ ] Python
- [ ] Go
- [ ] Rust
- [ ] Nix

**Requirements for each:**
- Package manager compatibility
- LSP configuration
- Formatter integration
- AI coding agent compatibility

## Low Priority Tasks

### Private Nix Cache
**Priority:** Low
**Status:** TODO

Research and implement private Nix cache using Backblaze B2 and attic.

**Deliverables:**
- Cache configuration
- Documentation
- Integration with CI/CD if applicable

## Success Criteria for Phase 2

- [ ] Modularization strategy documented
- [ ] All NixOS modules created and documented
- [ ] All home-manager modules created and documented
- [ ] Directory structure matches design
- [ ] Flake configuration complete
- [ ] DevShell fully configured
- [ ] Language support verified

## Next Phase

Once Phase 2 is complete, proceed to [Phase 3: Host Configuration](./phase3-host-configuration.md)
