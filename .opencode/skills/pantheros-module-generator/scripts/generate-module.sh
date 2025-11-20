#!/usr/bin/env bash
# Module Generator for pantherOS
# Automates Phase 2 module scaffolding
# Usage: ./generate-module.sh <type> <category> <name>

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Arguments
MODULE_TYPE="${1:-}"  # nixos or home-manager
CATEGORY="${2:-}"     # core, services, security, hardware, applications, development, shell, desktop
MODULE_NAME="${3:-}"  # my-service, my-app, etc.

# Validation
if [[ -z "$MODULE_TYPE" || -z "$CATEGORY" || -z "$MODULE_NAME" ]]; then
    echo -e "${RED}Error: Missing required arguments${NC}" >&2
    echo ""
    echo "Usage: $0 <type> <category> <name>"
    echo ""
    echo "Type:"
    echo "  nixos           - System-level modules (NixOS)"
    echo "  home-manager    - User-level modules (home-manager)"
    echo ""
    echo "Categories for nixos:"
    echo "  core            - Essential system services (boot, network, etc.)"
    echo "  services        - Network services (nginx, databases, etc.)"
    echo "  security        - Security modules (firewall, apparmor, etc.)"
    echo "  hardware        - Hardware-specific configs (GPU, audio, etc.)"
    echo ""
    echo "Categories for home-manager:"
    echo "  shell           - Shell and terminal tools (fish, aliases, etc.)"
    echo "  applications    - User applications (zathura, etc.)"
    echo "  development     - Dev tools and languages (node, python, etc.)"
    echo "  desktop         - Desktop environment (niri, wallpapers, etc.)"
    echo ""
    echo "Example:"
    echo "  $0 nixos services nginx"
    echo "  $0 home-manager applications zathura"
    exit 1
fi

# Validation: module type
if [[ "$MODULE_TYPE" != "nixos" && "$MODULE_TYPE" != "home-manager" ]]; then
    echo -e "${RED}Error: Invalid type '$MODULE_TYPE'${NC}" >&2
    echo "Must be 'nixos' or 'home-manager'"
    exit 1
fi

# Validation: category
VALID_CATEGORIES=""
if [[ "$MODULE_TYPE" == "nixos" ]]; then
    VALID_CATEGORIES="core services security hardware"
elif [[ "$MODULE_TYPE" == "home-manager" ]]; then
    VALID_CATEGORIES="shell applications development desktop"
fi

if [[ ! " $VALID_CATEGORIES " =~ " $CATEGORY " ]]; then
    echo -e "${RED}Error: Invalid category '$CATEGORY'${NC}" >&2
    echo "Valid categories for $MODULE_TYPE:"
    echo "  $VALID_CATEGORIES"
    exit 1
fi

# Convert module name to Nix identifier format
NIX_IDENTIFIER=$(echo "$MODULE_NAME" | sed 's/[-_]/-/g' | sed 's/[^a-zA-Z0-9\-]//g' | tr '[:upper:]' '[:lower:]')

# Base paths
MODULE_DIR="modules/$MODULE_TYPE/$CATEGORY"
DOCS_DIR="docs/modules/$MODULE_TYPE/$CATEGORY"
MODULE_FILE="$MODULE_DIR/$NIX_IDENTIFIER.nix"
DOC_FILE="$DOCS_DIR/$NIX_IDENTIFIER.md"

echo -e "${BLUE}=== PantherOS Module Generator ===${NC}"
echo -e "Type: ${GREEN}$MODULE_TYPE${NC}"
echo -e "Category: ${GREEN}$CATEGORY${NC}"
echo -e "Name: ${GREEN}$MODULE_NAME${NC}"
echo -e "Output File: ${BLUE}$MODULE_FILE${NC}"
echo ""

# Create directories
mkdir -p "$MODULE_DIR"
mkdir -p "$DOCS_DIR"

echo -e "${YELLOW}Generating module...${NC}"

# Generate module file
cat > "$MODULE_FILE" << EOF
{ config, lib, ... }:

with lib;

let
  cfg = config.services.$NIX_IDENTIFIER;
in
{
  # Module options
  options.services.$NIX_IDENTIFIER = {
    enable = mkEnableOption "$MODULE_NAME module";

    package = mkOption {
      type = types.package;
      default = pkgs.$NIX_IDENTIFIER;
      defaultText = literalExpression "pkgs.$NIX_IDENTIFIER";
      description = ''
        Package to use for $MODULE_NAME.
      '';
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          port = 8080;
          enableFeature = true;
        }
      '';
      description = ''
        Configuration for $MODULE_NAME.
      '';
    };
  };

  # Module implementation
  config = mkIf cfg.enable {
    # Install package
    environment.systemPackages = [
      cfg.package
    ];

    # Service configuration (if needed)
    systemd.services.$NIX_IDENTIFIER = {
      description = "$MODULE_NAME Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "\${cfg.package}/bin/$NIX_IDENTIFIER \${builtins.toJSON cfg.settings}";
        Restart = "on-failure";
      };
    };

    # Add configuration file (if needed)
    environment.etc."$NIX_IDENTIFIER/config".source =
      mkDefault (pkgs.writeText "$NIX_IDENTIFIER-config"
        (builtins.toJSON cfg.settings));

    # Networking (if needed)
    # networking.firewall.allowedPorts = [ cfg.settings.port ];
  };

  # Module imports
  imports = [
    # Add module imports here
  ];
}
EOF

echo -e "${GREEN}✓ Created $MODULE_FILE${NC}"

# Generate documentation
cat > "$DOC_FILE" << EOF
# $MODULE_NAME Module

## Overview

This module manages $MODULE_NAME for pantherOS.

## Usage

### Basic Usage

\`\`\`nix
{
  imports = [
    ./modules/$MODULE_TYPE/$CATEGORY/$NIX_IDENTIFIER.nix
  ];

  services.$NIX_IDENTIFIER.enable = true;
}
\`\`\`

### Configuration

\`\`\`nix
services.$NIX_IDENTIFIER = {
  enable = true;

  settings = {
    # Custom configuration options
    # Example: port = 8080;
  };
};
\`\`\`

## Module Options

### \`services.$NIX_IDENTIFIER.enable\`

Whether to enable the $MODULE_NAME module.

**Type:** boolean

**Default:** \`false\`

### \`services.$NIX_IDENTIFIER.package\`

Package to use for $MODULE_NAME.

**Type:** package

**Default:** \`pkgs.$NIX_IDENTIFIER\`

### \`services.$NIX_IDENTIFIER.settings\`

Configuration for $MODULE_NAME.

**Type:** attribute set

**Default:** \`{}\`

**Example:**

\`\`\`nix
{
  port = 8080;
  enableFeature = true;
}
\`\`\`

## Integration

### Dependencies

- \`nixos.network\` - Network configuration

### Used By

This module is used by:
- \`profiles/desktop\` - Desktop-specific configuration
- \`profiles/server\` - Server-specific configuration

## Implementation Details

### Files

- **Module:** \`modules/$MODULE_TYPE/$CATEGORY/$NIX_IDENTIFIER.nix\`
- **Documentation:** \`docs/modules/$MODULE_TYPE/$CATEGORY/$NIX_IDENTIFIER.md\`

### Service

If this module provides a systemd service:
- Service name: \`$NIX_IDENTIFIER.service\`
- Log location: \`journalctl -u $NIX_IDENTIFIER.service\`
- Config file: \`/etc/$NIX_IDENTIFIER/config\`

## Testing

### Build Test

\`\`\`bash
nixos-rebuild build .#yoga
\`\`\`

### Dry Run

\`\`\`bash
nixos-rebuild dry-activate --flake .#yoga
\`\`\`

## Troubleshooting

### Service Won't Start

Check service status:
\`\`\`bash
systemctl status $NIX_IDENTIFIER.service
journalctl -u $NIX_IDENTIFIER.service -n 50
\`\`\`

### Configuration Not Applied

1. Verify module is imported
2. Check configuration syntax
3. Test build: \`nixos-rebuild build\`

### Package Not Found

Ensure package is available in nixpkgs or add custom package:
\`\`\`nix
services.$NIX_IDENTIFIER.package = my-custom-package;
\`\`\`

## Related Modules

- \`modules/$MODULE_TYPE/$CATEGORY/dependency-module.nix\`
- \`profiles/desktop\` - Desktop integration
- \`profiles/server\` - Server integration

## Examples

### Complete Configuration

\`\`\`nix
# In configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./modules/$MODULE_TYPE/$CATEGORY/$NIX_IDENTIFIER.nix
  ];

  services.$NIX_IDENTIFIER = {
    enable = true;

    settings = {
      port = 8080;
      enableFeature = true;
      customPath = "/etc/$NIX_IDENTIFIER";
    };
  };

  # Additional configuration
  networking.firewall.allowedPorts = [ 8080 ];
}
\`\`\`

### Integration with Profile

\`\`\`nix
# In profiles/desktop.nix
{
  # ... other modules ...

  imports = [
    ./modules/$MODULE_TYPE/$CATEGORY/$NIX_IDENTIFIER.nix
  ];

  # Desktop-specific configuration
  services.$NIX_IDENTIFIER.enable = true;

  environment.systemPackages = with pkgs; [
    additional-$NIX_IDENTIFIER-tools
  ];
}
\`\`\`
EOF

echo -e "${GREEN}✓ Created $DOC_FILE${NC}"

# Create example usage file
EXAMPLE_FILE="$MODULE_DIR/examples.nix"
cat > "$EXAMPLE_FILE" << EOF
# Example usage of $NIX_IDENTIFIER module

{ config, pkgs, ... }:

{
  imports = [
    ./$NIX_IDENTIFIER.nix
  ];

  services.$NIX_IDENTIFIER = {
    enable = true;

    settings = {
      # Basic settings
      # Example: port = 8080;
    };
  };

  # Additional configuration examples

  # Allow through firewall (if service uses network)
  # networking.firewall.allowedPorts = [ 8080 ];

  # Add environment variables
  # environment.sessionVariables = {
  #   MODULE_NAME_CONFIG = "/etc/$NIX_IDENTIFIER/config";
  # };

  # Install additional tools
  # environment.systemPackages = with pkgs; [
  #   additional-tool
  # ];
}
EOF

echo -e "${GREEN}✓ Created $EXAMPLE_FILE${NC}"

# Create validation script
VALIDATE_FILE="$MODULE_DIR/validate.sh"
cat > "$VALIDATE_FILE" << 'EOF'
#!/usr/bin/env bash
# Validate module structure

set -euo pipefail

MODULE_FILE="$1"

if [[ -z "$MODULE_FILE" ]]; then
    echo "Usage: $0 <module-file.nix>"
    exit 1
fi

echo "Validating module: $MODULE_FILE"

# Check syntax
echo "✓ Checking syntax..."
nix-instantiate --eval "$MODULE_FILE" > /dev/null

# Check options
echo "✓ Checking options..."
nix-instantiate --eval "$MODULE_FILE" --arg config '{
  services.__MODULE_NAME__ = {
    enable = true;
    settings = {};
  };
}' > /dev/null

# Check module structure
echo "✓ Checking module structure..."

# Verify required attributes exist
nix-instantiate --eval --json "$MODULE_FILE" | grep -q "options" || {
    echo "✗ Module missing 'options' attribute"
    exit 1
}

nix-instantiate --eval --json "$MODULE_FILE" | grep -q "config" || {
    echo "✗ Module missing 'config' attribute"
    exit 1
}

echo ""
echo "✓ Module validation passed!"
EOF

chmod +x "$VALIDATE_FILE"
echo -e "${GREEN}✓ Created $VALIDATE_FILE${NC}"

# Create module index entry
INDEX_FILE="$DOCS_DIR/README.md"
cat >> "$INDEX_FILE" << EOF

## $NIX_IDENTIFIER

$MODULE_NAME module for pantherOS.

- **Module:** [\`modules/$MODULE_TYPE/$CATEGORY/$NIX_IDENTIFIER.nix\`](../modules/$MODULE_TYPE/$CATEGORY/$NIX_IDENTIFIER.nix)
- **Documentation:** [\`$NIX_IDENTIFIER.md\`](./$NIX_IDENTIFIER.md)
- **Status:** Generated $(date +%Y-%m-%d)

EOF

# Update or create index if empty
if [[ ! -s "$INDEX_FILE" ]] || [[ $(wc -l < "$INDEX_FILE") -eq 0 ]]; then
    cat > "$INDEX_FILE" << 'EOFINDEX'
# $MODULE_TYPE/$CATEGORY Modules

This directory contains $MODULE_TYPE modules for the $CATEGORY category.

## Modules

EOFINDEX
    cat >> "$INDEX_FILE" << EOF

## $NIX_IDENTIFIER

$MODULE_NAME module for pantherOS.

- **Module:** [\`../../modules/$MODULE_TYPE/$CATEGORY/$NIX_IDENTIFIER.nix\`](../modules/$MODULE_TYPE/$CATEGORY/$NIX_IDENTIFIER.nix)
- **Documentation:** [\`$NIX_IDENTIFIER.md\`](./$NIX_IDENTIFIER.md)
- **Status:** Generated $(date +%Y-%m-%d)

EOFINDEX
fi

echo -e "${GREEN}✓ Updated $INDEX_FILE${NC}"

# Summary
echo ""
echo -e "${GREEN}=== Module Generation Complete ===${NC}"
echo ""
echo "Created files:"
echo "  - ${BLUE}$MODULE_FILE${NC}"
echo "  - ${BLUE}$DOC_FILE${NC}"
echo "  - ${BLUE}$EXAMPLE_FILE${NC}"
echo "  - ${BLUE}$VALIDATE_FILE${NC}"
echo "  - ${BLUE}$INDEX_FILE${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit $MODULE_FILE to implement your module"
echo "  2. Review and customize $DOC_FILE"
echo "  3. Test the module: nixos-rebuild build .#<hostname>"
echo "  4. Validate: ./validate.sh $MODULE_FILE"
echo "  5. Add to profile or host configuration"
echo ""
echo -e "${BLUE}Example integration:${NC}"
echo "  In configuration.nix:"
echo "    imports = ["
echo "      ./$MODULE_FILE"
echo "    ];"
echo ""
echo "    services.$NIX_IDENTIFIER.enable = true;"
echo ""
