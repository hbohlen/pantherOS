# OpenSpec Proposal 002: Development Environment - Phase 2

**Status**: 📋 Proposed  
**Created**: 2025-11-22  
**Authors**: MiniMax Agent, Copilot Workspace Agent  
**Phase**: Research Tasks Phase 2  
**Related**: pantherOS_executable_research_plan.md, TASK-008 through TASK-014

## Summary

Implementation of seven development environment modules for pantherOS, providing declarative configuration for IDEs (VS Code, Neovim, JetBrains) and language toolchains (Rust, Python, Go, Node.js) to create a complete, reproducible development workstation.

## Motivation

### Problem Statement

pantherOS currently lacks dedicated development environment modules, forcing developers to:
- Manually configure IDEs and editors
- Set up language toolchains inconsistently
- Manage development dependencies ad-hoc
- Recreate development environments on new machines
- Maintain separate configuration for each language

### Impact

Without development environment modules:
- Inconsistent development experience across machines
- Time-consuming setup for new developers
- Difficulty onboarding team members
- No declarative development environment management
- Fragmented tooling configuration

### Goals

1. Provide IDE configuration modules (VS Code, Neovim, JetBrains)
2. Create language-specific toolchain modules
3. Enable reproducible development environments
4. Support multiple programming languages
5. Integrate with existing pantherOS ecosystem

## Proposal

### Module Architecture

**Layer**: `modules/development/*`  
**Namespace**: `pantherOS.development.*`  
**Integration**: Compatible with hardware and networking modules

### Planned Modules

#### 1. VS Code Configuration Module (TASK-008)
**File**: `code_snippets/system_config/nixos/vscode-config.nix.md`  
**Target Lines**: 500-600

**Features**:
- Extension management (declarative installation)
- Settings synchronization
- Language server protocol (LSP) configuration
- Debugging support
- Theme and UI customization
- Keybinding configuration
- Workspace templates

**Configuration Options**:
```nix
pantherOS.development.vscode = {
  enable = true;
  extensions = [ ... ];
  settings = { ... };
  keybindings = [ ... ];
};
```

#### 2. Neovim Configuration Module (TASK-009)
**File**: `code_snippets/system_config/nixos/neovim-config.nix.md`  
**Target Lines**: 500-600

**Features**:
- Plugin manager integration (lazy.nvim/packer)
- LSP configuration for multiple languages
- Syntax highlighting and tree-sitter
- Theme integration (DankMaterialShell compatibility)
- Code completion and snippets
- Git integration
- Terminal integration

**Configuration Options**:
```nix
pantherOS.development.neovim = {
  enable = true;
  plugins = [ ... ];
  lsp.enable = true;
  theme = "dank-material";
};
```

#### 3. JetBrains IDE Module (TASK-010)
**File**: `code_snippets/system_config/nixos/jetbrains-config.nix.md`  
**Target Lines**: 450-550

**Features**:
- JetBrains Toolbox installation
- IDE configuration (IntelliJ IDEA, PyCharm, GoLand, WebStorm)
- Plugin management
- JVM settings optimization
- Project templates
- Theme integration
- License management

**Configuration Options**:
```nix
pantherOS.development.jetbrains = {
  enable = true;
  ides = [ "idea" "pycharm" "goland" ];
  jvmOpts = "-Xmx4g";
};
```

#### 4. Rust Development Module (TASK-011)
**File**: `code_snippets/system_config/nixos/rust-toolchain.nix.md`  
**Target Lines**: 500-600

**Features**:
- Rustup toolchain management
- Multiple Rust versions support
- Cargo configuration and caching
- rust-analyzer LSP
- Development tools (clippy, rustfmt)
- Cross-compilation support
- Cargo workspaces

**Configuration Options**:
```nix
pantherOS.development.rust = {
  enable = true;
  channel = "stable"; # stable, beta, nightly
  targets = [ "x86_64-unknown-linux-gnu" ];
  tools = [ "clippy" "rustfmt" "rust-analyzer" ];
};
```

#### 5. Python Development Module (TASK-012)
**File**: `code_snippets/system_config/nixos/python-toolchain.nix.md`  
**Target Lines**: 500-600

**Features**:
- Python version management (3.10, 3.11, 3.12)
- Virtual environment support
- Poetry, pipenv, pip-tools integration
- Development tools (black, flake8, mypy, pytest)
- Jupyter notebook support
- Data science libraries
- Web frameworks (Django, Flask, FastAPI)

**Configuration Options**:
```nix
pantherOS.development.python = {
  enable = true;
  versions = [ "3.11" "3.12" ];
  tools = [ "black" "mypy" "pytest" ];
  jupyter.enable = true;
};
```

#### 6. Go Development Module (TASK-013)
**File**: `code_snippets/system_config/nixos/go-toolchain.nix.md`  
**Target Lines**: 450-550

**Features**:
- Go version management
- GOPATH and module configuration
- gopls language server
- Development tools (goimports, golint, delve)
- Cross-compilation support
- Container and cloud development tools

**Configuration Options**:
```nix
pantherOS.development.go = {
  enable = true;
  version = "1.21";
  tools = [ "gopls" "delve" ];
  goPath = "~/go";
};
```

#### 7. Node.js Development Module (TASK-014)
**File**: `code_snippets/system_config/nixos/nodejs-toolchain.nix.md`  
**Target Lines**: 500-600

**Features**:
- Node.js version management (16, 18, 20)
- Package manager support (npm, pnpm, yarn)
- TypeScript support
- Frontend build tools (Vite, Webpack, Rollup)
- Testing frameworks (Jest, Vitest)
- Development server and debugging
- ESLint and Prettier integration

**Configuration Options**:
```nix
pantherOS.development.nodejs = {
  enable = true;
  versions = [ "18" "20" ];
  packageManager = "pnpm";
  typescript.enable = true;
};
```

## Implementation Plan

### Phase 2.1: IDE Modules (Week 1)
- TASK-008: VS Code Configuration
- TASK-009: Neovim Configuration
- TASK-010: JetBrains IDE Configuration

### Phase 2.2: Language Toolchains (Week 2)
- TASK-011: Rust Development
- TASK-012: Python Development
- TASK-013: Go Development
- TASK-014: Node.js Development

### Development Process

1. **Research**: Study language toolchain best practices
2. **Design**: Create module structure and options
3. **Implement**: Develop NixOS modules with comprehensive features
4. **Document**: Add examples, troubleshooting, integration guides
5. **Test**: Validate on development workstations
6. **Integrate**: Ensure compatibility with Phase 1 modules

## Success Criteria

### Functional Requirements
- [ ] All 7 development modules implement complete functionality
- [ ] IDE configurations are declarative and reproducible
- [ ] Language toolchains support multiple versions
- [ ] Development tools are properly integrated
- [ ] Cross-module integration works seamlessly

### Quality Metrics
- [ ] Average module size: 500-600 lines
- [ ] Configuration options: 20-30 per module
- [ ] Usage examples: 8-12 per module
- [ ] Language coverage: Support for 4 major languages

### User Experience
- [ ] Quick setup for new developers (<30 minutes)
- [ ] Declarative configuration for all tools
- [ ] Clear documentation and examples
- [ ] Integrated development workflow

## Dependencies

### Prerequisites
- Phase 1: Hardware modules (display, input, thermal)
- NixOS 23.11+
- pantherOS base system

### Module Dependencies
- IDE modules → Language toolchains (for LSP integration)
- All modules → Display management (for GUI applications)
- VS Code/JetBrains → Font configuration

### External Dependencies
- Language runtimes and compilers
- IDE distributions
- Language servers and development tools

## Integration Examples

### Full-Stack Development Workstation
```nix
{
  # IDEs
  pantherOS.development = {
    vscode.enable = true;
    neovim.enable = true;
  };
  
  # Language toolchains
  pantherOS.development = {
    rust.enable = true;
    python.enable = true;
    nodejs.enable = true;
  };
  
  # Hardware optimization
  pantherOS.hardware = {
    display.scaling.factor = "1.5";
    thermal.profile = "performance";
  };
}
```

### Backend Developer Setup
```nix
{
  pantherOS.development = {
    vscode.enable = true;
    python = {
      enable = true;
      tools = [ "black" "mypy" "pytest" ];
    };
    go = {
      enable = true;
      tools = [ "gopls" "delve" ];
    };
  };
}
```

## Alternatives Considered

### 1. Manual Tool Installation
**Rejected**: Not reproducible, inconsistent across machines

### 2. Docker-Based Development
**Rejected**: Additional overhead, not NixOS-native

### 3. Language-Agnostic Module
**Rejected**: Too complex, harder to maintain

## Future Work

### Short-term
- Container development module (Phase 3)
- Git configuration module (Phase 3)
- Additional language support (Java, C++, Haskell)

### Medium-term
- Remote development support
- Cloud development integration
- AI-assisted coding tools

### Long-term
- Automatic project detection and configuration
- Team configuration sharing
- Development environment templates

## Timeline

**Start Date**: 2025-11-23  
**Target Completion**: 2025-12-06 (2 weeks)

### Milestones
- Week 1: IDE modules complete
- Week 2: Language toolchains complete
- Review and validation: 2-3 days

## References

- pantherOS Executable Research Plan
- NixOS Language Support Documentation
- IDE Configuration Best Practices
- Language Toolchain Documentation

## Approval Status

**Proposed**: 2025-11-22  
**Approved**: Pending  
**Implementation Start**: After Phase 1 validation

---

**Previous**: [001-hardware-modules-phase-1.md](./001-hardware-modules-phase-1.md)  
**Next**: [003-advanced-integration-phase-3.md](./003-advanced-integration-phase-3.md)
