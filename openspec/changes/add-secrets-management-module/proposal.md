# Change: Add Structured Secrets Management Module

## Why

While 1Password CLI is integrated, there's no structured module for managing secrets across the NixOS configuration. Current limitations:
- No centralized secrets management pattern
- API keys and credentials scattered across configuration
- No integration with NixOS rebuild process
- Difficult to manage different secrets per host
- No secret rotation or auditing capabilities

A structured secrets management module would provide secure, reproducible secret handling that integrates with the declarative NixOS configuration model.

## What Changes

- Create `modules/security/secrets.nix` module using sops-nix or agenix
- Add encrypted secrets storage in repository
- Integrate secrets into NixOS configuration declaratively
- Support per-host and per-user secrets
- Add 1Password integration for secret sourcing
- Create helper scripts for secret management (encrypt, decrypt, rotate)
- Document secret management workflow

## Impact

### Affected Specs
- Modified capability: `secrets-management` (extend from basic 1Password to full secret management)
- Modified capability: `security` (add security module integration)
- Modified capability: `configuration` (add secrets to system configuration)

### Affected Code
- New module: `modules/security/secrets.nix`
- Modified: `modules/security/default.nix` to include secrets module
- New directory: `secrets/` for encrypted secret files
- Host configurations: Add secret imports in `hosts/*/default.nix`
- flake.nix: Add sops-nix or agenix input

### Benefits
- Secure secret storage in version control
- Declarative secret management
- Per-host secret isolation
- Integration with existing 1Password workflow
- Auditable secret changes through git history
- Automated secret deployment during rebuild

### Considerations
- Initial setup requires key generation per host
- Secrets must be re-encrypted when adding new hosts
- Secret rotation requires manual intervention
- Age keys or GPG keys need secure backup
