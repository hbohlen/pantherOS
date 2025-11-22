# Contributing to pantherOS

Thank you for your interest in contributing to pantherOS! This document provides guidelines and best practices for contributing to this NixOS configuration repository.

## 🎯 Quick Start

1. **Read the architecture:** Start with [ARCHITECTURE.md](ARCHITECTURE.md)
2. **Set up your environment:** Run `just dev` to enter the development shell
3. **Understand the structure:** Familiarize yourself with the module organization
4. **Make small changes:** Start with minor improvements before major refactors

## 📋 Before You Start

### Prerequisites

- NixOS or Nix package manager installed
- Basic understanding of Nix language
- Git for version control
- (Optional) `just` for task automation

### Reading Material

- [ARCHITECTURE.md](ARCHITECTURE.md) - Repository structure and design
- [docs/CODE_REVIEW_REPORT.md](docs/CODE_REVIEW_REPORT.md) - Known issues and improvement plan
- [docs/guides/module-development.md](docs/guides/module-development.md) - Module development guide
- [NixOS Manual](https://nixos.org/manual/nixos/stable/) - Official NixOS documentation

## 🔧 Development Workflow

### 1. Set Up Development Environment

```bash
# Clone the repository
git clone https://github.com/hbohlen/pantherOS.git
cd pantherOS

# Enter development shell
nix develop
# or
just dev
```

### 2. Make Your Changes

#### Adding a New Module

1. **Choose the right category:**
   - `modules/nixos/core/` - Base system functionality
   - `modules/nixos/services/` - Service configurations
   - `modules/nixos/security/` - Security hardening
   - `modules/nixos/filesystems/` - Storage management
   - `modules/nixos/hardware/` - Hardware-specific settings

2. **Use the module template:**

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.<category>.<module-name>;
in
{
  options.pantherOS.<category>.<module-name> = {
    enable = mkEnableOption "<clear description of what this module does>";
    
    # Add well-documented options
    exampleOption = mkOption {
      type = types.str;
      default = "default-value";
      example = "example-value";
      description = ''
        Clear description of what this option does.
        
        Common use cases:
        - Use case 1
        - Use case 2
      '';
    };
  };

  config = mkIf cfg.enable {
    # Your configuration here
    
    # Add assertions for validation
    assertions = [
      {
        assertion = cfg.exampleOption != "";
        message = "pantherOS.<category>.<module-name>.exampleOption cannot be empty";
      }
    ];
  };
  
  # Optional metadata
  meta = {
    maintainers = [ "hbohlen" ];
    doc = ./README.md;
  };
}
```

3. **Add documentation:**
   - Inline comments for complex logic
   - Option descriptions with examples
   - README.md in the module directory (if complex)

#### Modifying Existing Modules

1. **Understand current behavior:**
   ```bash
   # Check where the module is used
   grep -r "pantherOS.<module-path>" hosts/
   
   # Build to see current configuration
   just build <hostname>
   ```

2. **Make minimal changes:**
   - Change as few lines as possible
   - Preserve existing functionality
   - Add, don't replace (unless fixing bugs)

3. **Maintain backwards compatibility:**
   - Use `mkDefault` for new defaults
   - Don't remove options without deprecation
   - Add migration notes if breaking changes are necessary

#### Adding a New Host

See [ARCHITECTURE.md#adding-a-new-host](ARCHITECTURE.md#adding-a-new-host) for detailed steps.

### 3. Validate Your Changes

```bash
# Check flake syntax
just check

# Validate module syntax
just check-modules

# Check shell scripts
just check-scripts

# Run all validations
just validate

# Format Nix files
just fmt
```

### 4. Test Your Changes

```bash
# Build the affected host
just build <hostname>

# Build all hosts to ensure no breakage
just build-all

# Test on local machine (if applicable)
just test <hostname>

# Test deployment (on test machine first!)
just deploy <hostname>
```

### 5. Document Your Changes

- **Update relevant documentation** in `docs/`
- **Add comments** for non-obvious code
- **Update ARCHITECTURE.md** if structure changes
- **Create migration guide** if breaking changes

### 6. Commit Your Changes

```bash
# Stage your changes
git add <files>

# Write a clear commit message
git commit -m "category: brief description

Detailed explanation of what changed and why.

- Change 1
- Change 2

Related to: #issue-number (if applicable)"
```

#### Commit Message Format

```
<category>: <brief description>

<detailed explanation>

<list of changes>

<references>
```

**Categories:**
- `feat:` - New feature or module
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code restructuring without behavior change
- `test:` - Test additions or modifications
- `chore:` - Maintenance tasks
- `security:` - Security improvements

**Examples:**

```
feat: add fail2ban integration for SSH hardening

Implements fail2ban service to protect against brute force attacks.
Integrates with existing SSH security module.

- Add modules/nixos/services/fail2ban.nix
- Update SSH security module to enable fail2ban
- Add tests for fail2ban integration

Addresses issue #42
```

```
fix: correct Tailscale firewall port configuration

The Tailscale module wasn't properly opening UDP port 41641,
causing connectivity issues on some networks.

- Fix port number in firewall configuration
- Add assertion to validate port configuration

Fixes #37
```

### 7. Create a Pull Request

1. **Push your branch:**
   ```bash
   git push origin <branch-name>
   ```

2. **Create PR on GitHub** with:
   - Clear title following commit message format
   - Description of changes and motivation
   - Testing performed
   - Screenshots (if UI changes)
   - References to related issues

3. **Respond to reviews:**
   - Address feedback promptly
   - Make requested changes
   - Update documentation as needed

## 🧪 Testing Guidelines

### What to Test

1. **Syntax validation** - `just validate`
2. **Build all hosts** - `just build-all`
3. **Deployment** (if possible) - `just deploy <test-host>`
4. **Service functionality** - Verify services start and work correctly
5. **Security implications** - Review for security issues

### Test Checklist

- [ ] Flake checks pass (`just check`)
- [ ] All hosts build successfully (`just build-all`)
- [ ] Module validation passes (`just check-modules`)
- [ ] Shell scripts pass shellcheck (`just check-scripts`)
- [ ] Code is formatted (`just fmt`)
- [ ] Documentation is updated
- [ ] No secrets committed (check with git diff)
- [ ] Changes tested on at least one host
- [ ] No regressions in existing functionality

## 🔒 Security Guidelines

### Never Commit Secrets

- **No passwords, tokens, or API keys in code**
- Use 1Password, sops-nix, or agenix for secrets
- Review diffs before committing: `git diff --cached`
- Use `.gitignore` to prevent accidental commits

### Security Review

Before committing security-related changes:

1. **Review firewall rules** - Are they restrictive enough?
2. **Check SSH configuration** - Is it hardened properly?
3. **Validate permissions** - Are file permissions correct?
4. **Test with minimal privileges** - Don't require root unnecessarily
5. **Document security implications** - Explain the security model

### Reporting Security Issues

If you find a security vulnerability:

1. **Do not create a public issue**
2. **Email the maintainer** with details
3. **Wait for acknowledgment** before disclosing
4. **Coordinate fix and disclosure**

## 📝 Code Style

### Nix Code Style

```nix
# Use lib.mkIf for conditional configuration
config = mkIf cfg.enable {
  # ...
};

# Use lib.mkDefault for overridable defaults
services.example.port = mkDefault 8080;

# Use lib.mkForce only when necessary
services.example.enable = mkForce true;

# Group related options
options.pantherOS.example = {
  enable = mkEnableOption "example service";
  
  package = mkOption {
    type = types.package;
    default = pkgs.example;
    description = "Example package";
  };
  
  settings = mkOption {
    type = types.attrs;
    default = {};
    description = "Example settings";
  };
};

# Add helpful assertions
assertions = [
  {
    assertion = cfg.port > 1024;
    message = "Port must be > 1024 for non-root services";
  }
];
```

### Shell Script Style

```bash
#!/usr/bin/env bash

# Always use strict mode
set -euo pipefail

# Add description at the top
# This script does X and Y

# Use descriptive variable names
HOSTNAME=$(hostname)
OUTPUT_DIR="output-${HOSTNAME}"

# Use functions for complex logic
check_prerequisites() {
  if ! command -v example &> /dev/null; then
    echo "Error: example command not found"
    exit 1
  fi
}

# Call functions
check_prerequisites
```

### Documentation Style

- Use **Markdown** for all documentation
- Include **code examples** where helpful
- Add **links** to related documentation
- Keep **line length** reasonable (80-100 chars)
- Use **clear headings** for navigation

## 🎨 Best Practices

### Module Design

1. **Single Responsibility** - Each module should do one thing well
2. **Clear Options** - Provide well-documented, intuitive options
3. **Sensible Defaults** - Make common cases work out of the box
4. **Composability** - Modules should work well together
5. **Testability** - Make it easy to test module functionality

### Configuration Management

1. **Don't Repeat Yourself (DRY)** - Extract common patterns to modules
2. **Host-Specific Only** - Keep host configs minimal, use modules for logic
3. **Profile-Based** - Use profiles for common host types
4. **Documented Decisions** - Explain non-obvious choices in comments

### Documentation

1. **Keep Updated** - Update docs with code changes
2. **Examples First** - Show examples before theory
3. **Clear Structure** - Use consistent organization
4. **AI-Friendly** - Write for human and AI readers

## 🐛 Troubleshooting

### Build Failures

```bash
# Get detailed error trace
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel --show-trace

# Check module syntax
just check-modules

# Validate flake
nix flake check --show-trace
```

### Common Issues

1. **Infinite recursion** - Check for circular module dependencies
2. **Type errors** - Verify option types match values
3. **Missing imports** - Ensure all required modules are imported
4. **Merge conflicts** - Carefully resolve NixOS module merges

## 📚 Resources

### NixOS Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)

### Project Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md)
- [docs/guides/](docs/guides/)
- [docs/CODE_REVIEW_REPORT.md](docs/CODE_REVIEW_REPORT.md)

### Community

- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Reddit](https://www.reddit.com/r/NixOS/)
- [NixOS Matrix](https://matrix.to/#/#community:nixos.org)

## 🤖 For AI Agents

When contributing as an AI agent:

1. **Read thoroughly:**
   - ARCHITECTURE.md
   - docs/CODE_REVIEW_REPORT.md
   - Module being modified

2. **Make minimal changes:**
   - Change only what's necessary
   - Preserve existing patterns
   - Don't refactor unnecessarily

3. **Validate extensively:**
   - Run all checks (`just validate`)
   - Build all hosts (`just build-all`)
   - Test changes if possible

4. **Document clearly:**
   - Explain changes in commit messages
   - Update relevant documentation
   - Add comments for complex logic

5. **Follow the plan:**
   - Refer to CODE_REVIEW_REPORT.md
   - Follow the refactor plan order
   - Check off completed items

## 📧 Contact

For questions or clarifications:

1. Check existing documentation
2. Search closed issues
3. Create a new issue with your question
4. Tag with `question` label

---

**Thank you for contributing to pantherOS!** 🎉

Your contributions help make this project better for everyone.
