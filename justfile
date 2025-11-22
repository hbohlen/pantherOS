# pantherOS Justfile
# Common tasks for working with the NixOS configuration

# List all available commands
default:
  @just --list

# Build a specific host configuration
build HOST:
  nixos-rebuild build --flake .#{{HOST}}

# Build all host configurations
build-all:
  @echo "Building all hosts..."
  @for host in yoga zephyrus hetzner-vps ovh-vps; do \
    echo "Building $$host..."; \
    just build $$host || exit 1; \
  done
  @echo "✓ All hosts built successfully"

# Test a host configuration (activates without adding to boot menu)
test HOST:
  nixos-rebuild test --flake .#{{HOST}} --fast

# Deploy to a host (local)
deploy HOST:
  sudo nixos-rebuild switch --flake .#{{HOST}}

# Deploy to a remote host
deploy-remote HOST IP:
  nixos-rebuild switch --flake .#{{HOST}} \
    --target-host root@{{IP}} \
    --build-host localhost

# Check flake for errors
check:
  nix flake check

# Update flake inputs
update:
  nix flake update

# Update a specific flake input
update-input INPUT:
  nix flake lock --update-input {{INPUT}}

# Format all Nix files
fmt:
  find . -name '*.nix' -type f -not -path './.*' -exec nixfmt {} +

# Check formatting without making changes
fmt-check:
  find . -name '*.nix' -type f -not -path './.*' -exec nixfmt --check {} +

# Validate shell scripts
check-scripts:
  @echo "Checking shell scripts with shellcheck..."
  @find . -name '*.sh' -type f -not -path './.*' -exec shellcheck {} +
  @echo "✓ All scripts passed shellcheck"

# Validate module syntax
check-modules:
  @echo "Validating NixOS modules..."
  @cd modules/nixos && bash validate-modules.sh
  @echo "✓ Module validation complete"

# Run all validation checks
validate: check check-scripts check-modules
  @echo "✓ All validation checks passed"

# Clean build artifacts
clean:
  rm -rf result result-*
  @echo "✓ Build artifacts cleaned"

# Run hardware discovery script
discover:
  sudo bash scripts/hardware-discovery.sh

# Show flake metadata
info:
  nix flake metadata

# Show flake outputs
show:
  nix flake show

# Enter development shell
dev:
  nix develop

# Show system configuration for a host
show-config HOST:
  nixos-rebuild build --flake .#{{HOST}} --dry-run

# Show package versions for a host
show-packages HOST:
  nix eval .#nixosConfigurations.{{HOST}}.config.environment.systemPackages --apply 'pkgs: builtins.concatStringsSep "\n" (map (p: p.name) pkgs)'

# Generate documentation
docs:
  @echo "Documentation is in docs/ directory"
  @echo "Main entry points:"
  @echo "  - README.md"
  @echo "  - docs/guides/getting-started.md"
  @echo "  - docs/guides/architecture.md"
  @echo "  - docs/CODE_REVIEW_REPORT.md"

# Show AI agent context
ai-context:
  @echo "=== pantherOS Repository Context ==="
  @echo ""
  @echo "## Structure"
  @cat README.md | head -50
  @echo ""
  @echo "## Recent Changes"
  @git log --oneline --graph -10
  @echo ""
  @echo "## Code Review Report"
  @echo "See: docs/CODE_REVIEW_REPORT.md"

# Verify deployment prerequisites for Hetzner
verify-hetzner:
  bash verify-deployment.sh

# Deploy to Hetzner Cloud
deploy-hetzner:
  bash deploy-hetzner.sh

# Show help for common tasks
help:
  @echo "pantherOS - Common Tasks"
  @echo ""
  @echo "Building:"
  @echo "  just build <host>       - Build a specific host"
  @echo "  just build-all          - Build all hosts"
  @echo ""
  @echo "Deploying:"
  @echo "  just deploy <host>      - Deploy locally"
  @echo "  just deploy-remote <host> <ip> - Deploy to remote host"
  @echo ""
  @echo "Validation:"
  @echo "  just check              - Check flake"
  @echo "  just validate           - Run all validation checks"
  @echo "  just fmt                - Format Nix files"
  @echo ""
  @echo "Development:"
  @echo "  just dev                - Enter dev shell"
  @echo "  just update             - Update flake inputs"
  @echo ""
  @echo "For full list: just --list"
