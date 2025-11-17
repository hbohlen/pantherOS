# pantherOS Constitution

## Core Principles

### I. Declarative Configuration

All system configuration MUST be declared using Nix expressions:
- No imperative system modifications outside of Nix configuration
- All packages, services, and system state declared in `.nix` files
- Configuration is version-controlled and reproducible
- Changes are applied through `nixos-rebuild` or equivalent tools

**Rationale**: Declarative configuration ensures reproducibility, enables rollbacks, and makes system state predictable and auditable.

### II. Modular Architecture

The system MUST follow a three-layer modular architecture:
- **Layer 1: Core Modules** - Base functionality (base/, apps/, services/, hardware/, security/, networking/)
- **Layer 2: Profiles** - Reusable configurations (workstation/, server/, common/)
- **Layer 3: Host Configurations** - Specific machine configurations

Each module MUST:
- Have a clear, single responsibility
- Be composable with other modules
- Document its options and dependencies
- Use explicit attribute sets over `with` statements

**Rationale**: Modularity enables code reuse, simplifies testing, and allows flexible system composition.

### III. Reproducibility

All deployments MUST be reproducible:
- Flake lock file (`flake.lock`) is committed and maintained
- No impure dependencies or fetches without fixed hashes
- Build outputs are deterministic where possible
- Development environments are defined declaratively

**Rationale**: Reproducibility ensures consistent builds across machines and enables reliable rollbacks.

### IV. Security by Default

Security MUST be considered in all configurations:
- Minimal attack surface - only enable required services
- Secure defaults - services configured with security best practices
- Secret management through OpNix/1Password integration
- Regular security updates through nixpkgs channel management
- No secrets committed to version control

**Rationale**: Security is not optional. Default-secure configurations prevent vulnerabilities.

### V. Testing Before Deployment

Changes MUST be validated before deployment:
- Build configurations locally: `nix build .#nixosConfigurations.<host>`
- Test in VM when possible: `nixos-rebuild build-vm`
- Verify no closure size regressions without justification
- Check for breaking changes in critical services

**Rationale**: Testing prevents deployment failures and system downtime.

### VI. Documentation Standards

All features and configurations MUST be documented:
- Maintain comprehensive markdown documentation
- Include architecture diagrams using Mermaid where appropriate
- Document breaking changes and migration paths
- Keep master topic maps up to date
- Use inline comments for complex Nix logic

**Rationale**: Documentation enables knowledge sharing and reduces maintenance burden.

## Technology Constraints

### Required Technologies

- **NixOS**: Primary operating system and configuration framework
- **Nix Flakes**: Modern dependency and configuration management
- **home-manager**: User environment management (where enabled)
- **nixos-hardware**: Hardware-specific optimizations

### Development Tools

- **Nix**: Package manager and configuration language (required)
- **nil**: Nix language server (recommended for development)
- **nixpkgs-fmt**: Code formatter for Nix files (required for contributions)
- **Git**: Version control (required)

### Code Style

- Use `nixpkgs-fmt` for formatting Nix files
- Follow the Nix manual style guide
- Prefer explicit attribute sets over `with` statements
- Use meaningful variable names
- Add comments for complex logic

## Development Workflow

### Feature Development Process

1. **Specification Phase**
   - Use `/speckit.specify` to define feature requirements
   - Focus on "what" and "why", not implementation details
   - Document acceptance criteria clearly

2. **Planning Phase**
   - Use `/speckit.plan` to create technical implementation
   - Specify which modules will be affected
   - Identify dependencies and integration points
   - Consider closure size implications

3. **Implementation Phase**
   - Use `/speckit.tasks` to break down work
   - Follow modular architecture principles
   - Test incrementally with `nix build`
   - Update documentation as you go

4. **Validation Phase**
   - Build all affected host configurations
   - Test in VM when possible
   - Verify no unintended side effects
   - Check closure size hasn't grown unexpectedly

### Branch Naming

- Feature branches: `NNN-feature-short-name` (e.g., `001-gnome-desktop`)
- Hotfix branches: `hotfix/description`
- Documentation branches: `docs/description`

### Commit Messages

- Use conventional commit format when appropriate
- Be descriptive: explain "why", not just "what"
- Reference issues or specifications where relevant

## Quality Gates

### Pre-Deployment Checks

All changes MUST pass these checks before deployment:

- [ ] Configuration builds successfully: `nix build .#nixosConfigurations.<host>`
- [ ] No syntax errors in Nix files
- [ ] Code formatted with `nixpkgs-fmt`
- [ ] Documentation updated for user-facing changes
- [ ] Secrets properly managed (not committed)
- [ ] Closure size impact assessed and justified

### Post-Deployment Validation

After deployment, verify:

- [ ] System boots successfully
- [ ] Critical services start and function
- [ ] No unexpected side effects
- [ ] Rollback procedure tested (where applicable)

## Governance

### Constitutional Authority

This constitution supersedes all other development practices and guidelines. When conflicts arise between this constitution and other documentation, this constitution takes precedence.

### Amendment Process

Modifications to this constitution require:
- Explicit documentation of the rationale for change
- Review and approval by project maintainers
- Assessment of impact on existing configurations
- Update to all affected documentation

### Enforcement

- All pull requests MUST verify compliance with constitutional principles
- Deviations from principles MUST be explicitly justified
- Complexity MUST be justified with clear rationale
- Regular audits ensure ongoing compliance

### Exceptions

Exceptions to constitutional principles may be granted when:
- Clear technical necessity exists
- Alternative approaches have been exhausted
- Exception is documented with rationale
- Exception includes plan for future compliance

**Version**: 1.0.0 | **Ratified**: 2025-11-16 | **Last Amended**: 2025-11-16
