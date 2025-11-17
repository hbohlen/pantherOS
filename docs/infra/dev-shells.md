# Development Shells

> **Category:** Infrastructure  
> **Audience:** Contributors, Developers  
> **Last Updated:** 2025-11-17

pantherOS provides multiple development shells for different workflows and programming languages.

## Table of Contents

- [Quick Start](#quick-start)
- [Available Shells](#available-shells)
- [Shell Details](#shell-details)
- [Using Development Shells](#using-development-shells)

## Quick Start

Enter a development shell:

```bash
# Default shell (general development)
nix develop

# Specific shell
nix develop .#nix      # Nix development
nix develop .#mcp      # AI/MCP development
nix develop .#rust     # Rust development
nix develop .#python   # Python development
```

List all available shells:

```bash
nix flake show | grep devShells
```

## Available Shells

### General Purpose

- **[default](#default-shell)** - General development environment
- **[nix](#nix-shell)** - Nix-specific development
- **[mcp](#mcp-shell)** - AI-assisted development with MCP servers

### Language-Specific

- **[rust](#rust-shell)** - Rust development
- **[node](#node-shell)** - Node.js development
- **[python](#python-shell)** - Python development
- **[go](#go-shell)** - Go development

### Specialized

- **[ai](#ai-shell)** - AI infrastructure development

## Shell Details

### Default Shell

**Purpose:** General development and repository exploration

**Tools included:**
- `git` - Version control
- `neovim` - Text editor
- `fish` - Modern shell
- `starship` - Cross-shell prompt
- `direnv` - Environment management
- `nil` - Nix language server
- `nixpkgs-fmt` - Nix code formatter

**Usage:**
```bash
nix develop

# or explicitly
nix develop .#default
```

**Use cases:**
- Exploring the repository
- Writing documentation
- Making quick configuration changes
- General system administration

### Nix Shell

**Purpose:** NixOS configuration development

**Tools included:**
- `nix` - Nix package manager
- `nil` - Nix language server
- `nixpkgs-fmt` - Code formatter
- `nix-init` - Package initialization
- `nix-eval-lsp` - Evaluation language server
- `git` - Version control

**Usage:**
```bash
nix develop .#nix

# Format Nix files
nixpkgs-fmt *.nix

# Check configuration
nix flake check
```

**Use cases:**
- Developing NixOS configurations
- Creating Nix modules
- Writing Nix expressions
- Package development

### MCP Shell

**Purpose:** AI-assisted development with Model Context Protocol

**Tools included:**
- **Development:** git, neovim, fish, starship, direnv
- **Nix:** nil, nixpkgs-fmt, nix-init
- **Node.js:** nodejs-20, yarn
- **Databases:** postgresql, sqlite
- **Utilities:** jq, curl, wget, ripgrep, fd, bat
- **Containers:** docker, docker-compose

**Environment variables:**
- `MCP_CONFIG_PATH` - Path to MCP servers config (`.github/mcp-servers.json`)

**Usage:**
```bash
nix develop .#mcp

# MCP servers are configured automatically
# See .github/mcp-servers.json for available servers
```

**Use cases:**
- AI-assisted development with GitHub Copilot
- Using MCP servers (GitHub, filesystem, git, etc.)
- AgentDB integration
- Full-stack development with AI tools

**Shell hook:**
Displays available development shells and sets up MCP environment.

### Rust Shell

**Purpose:** Rust development

**Tools included:**
- `rustc` - Rust compiler
- `cargo` - Rust package manager
- `rust-analyzer` - Rust language server
- `rustfmt` - Code formatter
- `clippy` - Linter
- `bacon` - Background compiler
- `cargo-watch` - File watcher
- `git`, `neovim` - Development tools

**Usage:**
```bash
nix develop .#rust

# Check Rust version
rustc --version
cargo --version

# Build and test
cargo build
cargo test

# Format and lint
cargo fmt
cargo clippy
```

**Use cases:**
- Rust application development
- Writing Rust-based system tools
- Contributing to Rust projects

### Node Shell

**Purpose:** Node.js/JavaScript/TypeScript development

**Tools included:**
- `nodejs-18_x` - Node.js 18 LTS
- `nodejs-20_x` - Node.js 20 LTS
- `yarn` - Package manager
- `pnpm` - Fast package manager
- `npm-9_x` - NPM package manager
- `git`, `neovim` - Development tools

**Usage:**
```bash
nix develop .#node

# Check versions
node --version
npm --version
yarn --version

# Install dependencies
npm install
# or
yarn install

# Run scripts
npm run dev
```

**Use cases:**
- Node.js application development
- Frontend development (React, Vue, etc.)
- MCP server development
- JavaScript/TypeScript projects

### Python Shell

**Purpose:** Python development

**Tools included:**
- `python3` - Python interpreter
- `pip` - Package installer
- `virtualenv` - Virtual environment manager
- `venv` - Built-in virtual environments
- `pylint` - Linter
- `black` - Code formatter
- `isort` - Import sorter
- `git`, `neovim` - Development tools

**Usage:**
```bash
nix develop .#python

# Check Python version
python --version
pip --version

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install packages
pip install -r requirements.txt

# Format and lint
black *.py
pylint *.py
isort *.py
```

**Use cases:**
- Python application development
- Data science and ML projects
- System automation scripts
- AI infrastructure development

### Go Shell

**Purpose:** Go development

**Tools included:**
- `go` - Go compiler
- `gopls` - Go language server
- `golangci-lint` - Linter
- `gotools` - Go development tools
- `air` - Live reload for Go
- `git`, `neovim` - Development tools

**Usage:**
```bash
nix develop .#go

# Check Go version
go version

# Initialize module
go mod init example.com/myapp

# Build and run
go build
go run main.go

# Test
go test ./...

# Format and lint
go fmt ./...
golangci-lint run
```

**Use cases:**
- Go application development
- Building system utilities
- Backend service development

### AI Shell

**Purpose:** AI infrastructure and machine learning development

**Tools included:**
- **Python:** python3, pip, virtualenv, numpy, pandas
- **Databases:** postgresql, sqlite, redis
- **Development:** git, neovim, fish, starship
- **Nix:** nil, nixpkgs-fmt
- **Containers:** docker, docker-compose
- **Utilities:** jq, curl, wget

**Environment variables:**
- `MCP_CONFIG_PATH` - MCP servers configuration

**Usage:**
```bash
nix develop .#ai

# Python with ML libraries available
python -c "import numpy; print(numpy.__version__)"

# Database tools available
psql --version
redis-cli --version
```

**Use cases:**
- AI/ML model development
- AgentDB integration work
- Data pipeline development
- MCP server development

## Using Development Shells

### Entering a Shell

**Interactive use:**
```bash
# Enter shell
nix develop .#nix

# You're now in the development shell
# Exit with Ctrl+D or 'exit'
```

**Running commands:**
```bash
# Run single command
nix develop .#nix --command nixpkgs-fmt flake.nix

# Run script
nix develop .#python --command python script.py
```

### Persistent Shells with direnv

**Create `.envrc`:**
```bash
cat > .envrc <<'EOF'
use flake .#nix
EOF

direnv allow
```

Now the shell is automatically activated when entering the directory!

### Combining with Secrets

**Load secrets in shell:**
```bash
# Create .envrc with secrets
cat > .envrc <<'EOF'
use flake .#mcp

export GITHUB_TOKEN=$(op read "op://Personal/pantherOS-secrets/GITHUB_TOKEN")
export ANTHROPIC_API_KEY=$(op read "op://Personal/pantherOS-secrets/ANTHROPIC_API_KEY")
EOF

direnv allow
```

### Multiple Shells

**Switch between shells:**
```bash
# Start with Nix shell
nix develop .#nix

# Exit and enter Python shell
exit
nix develop .#python
```

**Nested shells:**
```bash
# Not recommended, but possible
nix develop .#nix
nix develop .#python  # Now in both
```

### Custom Shell Hooks

Development shells can run custom setup code:

```nix
# In flake.nix
mkShell {
  packages = [ ... ];
  
  shellHook = ''
    echo "Welcome to my shell!"
    export MY_VAR="value"
    
    # Run setup script
    ./setup.sh
  '';
}
```

## Best Practices

### Choose the Right Shell

- **Quick edits** → `default` shell
- **Nix development** → `nix` shell
- **AI assistance** → `mcp` shell
- **Language work** → Language-specific shell

### Use direnv for Automation

```bash
# .envrc
use flake .#nix

# Secrets
export GITHUB_TOKEN=$(op read "...")

# Custom environment
export PROJECT_ROOT=$(pwd)
```

### Keep Shells Focused

- Don't add unnecessary tools
- Use language-specific shells for language work
- Keep `default` minimal for fast loading

### Document Custom Shells

If adding new shells:
- Document in this file
- Explain use cases
- List included tools
- Provide usage examples

## Troubleshooting

### Shell Won't Start

```bash
# Update flake
nix flake update

# Clear cache
nix-collect-garbage -d

# Try with explicit system
nix develop .#nix --system x86_64-linux
```

### Missing Tools

```bash
# Verify tool is in shell
nix develop .#nix --command which nixpkgs-fmt

# If missing, check flake.nix packages list
```

### Slow Shell Startup

```bash
# Build shell closure first
nix build .#devShells.x86_64-linux.nix

# Then enter (faster)
nix develop .#nix
```

## See Also

- **[NixOS Overview](nixos-overview.md)** - NixOS concepts
- **[How-To: Setup Development](../howto/setup-development.md)** - Complete setup guide
- **[Infrastructure Index](index.md)** - All infrastructure docs
- **[Architecture Overview](../architecture/overview.md)** - System architecture
