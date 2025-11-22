# Research Tasks

**Purpose:** Research items that inform implementation decisions

## Security Research

### 1Password Service Account Research
**Priority:** High
**Status:** TODO

Research 1Password service account usage in solo, personal developer architecture.

**Research Areas:**
- Service account best practices
- Naming conventions for personal use
- Vault structure recommendations
- Separation of service account and personal vault
- `pantherOS` service account optimization

**Deliverables:**
- Recommendations document
- Current usage analysis
- Improvement suggestions

### Secrets Inventory and Management
**Priority:** High
**Status:** TODO

Determine secrets and environment variables used throughout infrastructure.

**Tasks:**
- [ ] Inventory all current secrets
- [ ] Identify environment variables needed
- [ ] Document `op:<vault>/<item>/[section]/<field>` references
- [ ] Create restructuring plan if needed
- [ ] Update all configurations to match final structure
- [ ] Ensure OpNix paths are updated

### Tailscale Capabilities Research
**Priority:** High
**Status:** TODO

Research Tailscale features for solo developer infrastructure.

**Research Focus:**
- Role/ACL setups
- Tag configuration
- Device management
- Access control
- Integration with containers
- Security best practices
- Solo developer use cases

**Deliverables:**
- Feature recommendations
- Implementation plan
- Security considerations

## Tool Research

### Ghostty Research
**Priority:** Medium
**Status:** TODO

Research Ghostty terminal for NixOS.

**Areas to Research:**
- Installation on NixOS
- Package name and availability
- Configuration options
- Compatibility issues
- Troubleshooting common problems
- Integration with fish shell

**Deliverables:**
- Installation guide
- Configuration recommendations
- Compatibility notes

### Package Research and Selection
**Priority:** Medium
**Status:** TODO

Analyze developer workflow and research recommended packages.

**Categories:**
- Workflow analysis (tools currently used)
- Recommended packages: `zoxide`, `exa`, `ripgrep`, `fzf`, `tmux`, `zellij`
- Package-specific research (use cases, features, benefits)
- Final selection and justification
- Integration strategies

**Deliverables:**
- Workflow analysis document
- Package recommendations with rationale
- Integration plan

### nix-ai-tools Integration Research
**Priority:** Medium
**Status:** TODO

Research integration of AI coding tools via nix-ai-tools.

**Tools to Research:**
- opencode (`github:numtide/nix-ai-tools#opencode`)
- qwen-code (`github:numtide/nix-ai-tools#qwen-code`)
- claude-code (`github:numtide/nix-ai-tools#claude-code`)
- claude-code-acp
- codex-acp
- gemini-cli
- catnip

**Research Areas:**
- Installation and configuration
- NixOS compatibility
- Integration with existing tools
- Configuration management via home-manager

## Configuration Research

### Modularization Strategy
**Priority:** High
**Status:** TODO

Research best practices for module organization.

**Focus Areas:**
- NixOS system module best practices
- Home-manager module organization
- Single-concern principle application
- Nested module structures
- Import patterns and relative paths
- Module testing strategies

### Directory Layout Research
**Priority:** Medium
**Status:** TODO

Research directory layouts and standards.

**Research:**
- NixOS project directory standards
- Naming conventions
- Subdirectory organization
- Module placement guidelines
- Host configuration organization
- Home-manager configuration structure

**Deliverables:**
- Standardized directory layout
- Naming conventions guide
- Rationale document

## Application Research

### Dank Linux Integration
**Priority:** Medium
**Status:** TODO

Research Dank Linux ecosystem integration.

**Components:**
- DankMaterialShell
- DankGreeter
- DankGop
- DankSearch

**Research Focus:**
- NixOS compatibility
- Configuration approaches
- Integration with Niri
- Dependencies and requirements

### Language Environment Research
**Priority:** Medium
**Status:** TODO

Research optimal configuration for programming languages.

**Languages:**
- Node.js (npm handling in NixOS)
- JavaScript/TypeScript
- ReactJS
- Python
- Go
- Rust
- Nix

**For Each Language:**
- Package manager compatibility
- LSP server options
- Formatter recommendations
- AI coding tool integration
- Nix development environment setup

## System Configuration Research

### Authentication Research
**Priority:** High
**Status:** TODO

Research authentication configuration.

**Areas:**
- Polkit selection (mate-polkit preference)
- PAM configuration
- 1Password integration with polkit
- Biometric unlock setup
- Password prompt handling
- Compatibility across all tools

### Nix Cache Research
**Priority:** Low
**Status:** TODO

Research private Nix cache implementation.

**Technologies:**
- Backblaze B2 storage
- Attic cache server
- Cache configuration
- Security considerations
- Performance benefits
- Cost analysis

**Deliverables:**
- Implementation plan
- Configuration guide
- Cost/benefit analysis

## Success Criteria

- [ ] All research tasks documented
- [ ] Recommendations provided for each area
- [ ] Implementation plans created where applicable
- [ ] Documentation integrated into relevant guides
- [ ] Research findings inform development phases

## Notes

Research tasks should inform Phases 1-3. Complete research before implementation where possible.
