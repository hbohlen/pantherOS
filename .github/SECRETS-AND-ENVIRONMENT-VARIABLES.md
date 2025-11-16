# Secrets and Environment Variables - Complete Configuration Guide

This document provides a comprehensive list of all secrets and environment variables required for the pantherOS project, including MCP servers, AI agents, development containers, GitHub Copilot, and system integrations.

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [Required Secrets](#required-secrets)
3. [Optional Secrets](#optional-secrets)
4. [Environment Variables](#environment-variables)
5. [Setup Instructions](#setup-instructions)
6. [Integration-Specific Configuration](#integration-specific-configuration)
7. [Security Best Practices](#security-best-practices)

---

## Quick Reference

### ✅ Required (Core Functionality)

| Variable | Purpose | Where Used | How to Get |
|----------|---------|------------|------------|
| `GITHUB_TOKEN` | GitHub API access | MCP server, Copilot, CI/CD | [github.com/settings/tokens](https://github.com/settings/tokens) |
| `OP_SERVICE_ACCOUNT_TOKEN` | 1Password automation | OpNix, secrets management | 1Password service account |

### ⚡ Recommended (Enhanced Features)

| Variable | Purpose | Where Used | How to Get |
|----------|---------|------------|------------|
| `POSTGRES_CONNECTION_STRING` | Database for AgentDB | MCP server, AI infrastructure | Local/remote PostgreSQL |
| `ANTHROPIC_API_KEY` | Claude AI access | AI agents, development | [console.anthropic.com](https://console.anthropic.com) |
| `OPENAI_API_KEY` | OpenAI API access | AI agents, development | [platform.openai.com](https://platform.openai.com) |

### 🎯 Optional (Extended Capabilities)

| Variable | Purpose | Where Used | How to Get |
|----------|---------|------------|------------|
| `BRAVE_API_KEY` | Web search capability | MCP brave-search server | [brave.com/search/api](https://brave.com/search/api) |
| `DATADOG_API_KEY` | Monitoring and metrics | Datadog agent | [app.datadoghq.com](https://app.datadoghq.com) |
| `TAILSCALE_AUTH_KEY` | VPN networking | Tailscale service | [login.tailscale.com](https://login.tailscale.com) |

---

## Required Secrets

### 1. GitHub Token (`GITHUB_TOKEN`)

**Required for:**
- GitHub MCP server
- GitHub Copilot authentication
- Repository operations (issues, PRs, code search)
- CI/CD workflows
- Dev Container authentication

**Scopes needed:**
```
repo           # Full repository access
read:org       # Read organization data
read:user      # Read user profile
workflow       # Update GitHub Action workflows
```

**Setup:**
```bash
# Generate token at: https://github.com/settings/tokens
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Or use GitHub CLI
gh auth login
export GITHUB_TOKEN=$(gh auth token)
```

**Storage in 1Password:**
- Item: `pantherOS/secrets`
- Field: `GITHUB_TOKEN`
- Type: Custom field

---

### 2. 1Password Service Account Token (`OP_SERVICE_ACCOUNT_TOKEN`)

**Required for:**
- OpNix secrets management
- Automated secret retrieval
- CI/CD pipelines
- System-level secret access

**Setup:**
```bash
# Create service account in 1Password
# Get token from: https://my.1password.com/developer

export OP_SERVICE_ACCOUNT_TOKEN="ops_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**Permissions needed:**
- Read access to `pantherOS` vault
- Access to secret items

**Storage:**
- Store securely outside version control
- Use environment-specific credentials
- Never commit to repository

---

## Optional Secrets

### 3. Anthropic API Key (`ANTHROPIC_API_KEY`)

**Used for:**
- Claude AI models
- AI-assisted development
- Code generation and review
- Documentation analysis

**Setup:**
```bash
# Get from: https://console.anthropic.com/settings/keys
export ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**Storage in 1Password:**
- Item: `pantherOS/secrets`
- Field: `ANTHROPIC_API_KEY`

---

### 4. OpenAI API Key (`OPENAI_API_KEY`)

**Used for:**
- GPT models
- Embeddings generation
- Alternative AI provider

**Setup:**
```bash
# Get from: https://platform.openai.com/api-keys
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**Storage in 1Password:**
- Item: `pantherOS/secrets`
- Field: `OPENAI_API_KEY`

---

### 5. Brave Search API Key (`BRAVE_API_KEY`)

**Used for:**
- MCP brave-search server
- Web search for NixOS documentation
- Package lookup and troubleshooting

**Setup:**
```bash
# Get from: https://brave.com/search/api/
export BRAVE_API_KEY="BSAxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**Storage in 1Password:**
- Item: `pantherOS/secrets`
- Field: `BRAVE_API_KEY`

---

### 6. PostgreSQL Connection String (`POSTGRES_CONNECTION_STRING`)

**Used for:**
- AgentDB vector database
- MCP postgres server
- AI memory and pattern storage

**Format:**
```bash
export POSTGRES_CONNECTION_STRING="postgresql://username:password@hostname:5432/database"

# Example for local development:
export POSTGRES_CONNECTION_STRING="postgresql://postgres:postgres@localhost:5432/agentdb"

# Example for production:
export POSTGRES_CONNECTION_STRING="postgresql://agentdb_user:secure_password@db.example.com:5432/agentdb"
```

**Setup:**
```bash
# Create database
createdb agentdb

# Set connection string
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"
```

**Storage in 1Password:**
- Item: `pantherOS/database/agentdb`
- Field: `connection_string`

---

### 7. Datadog API Key (`DATADOG_API_KEY`)

**Used for:**
- System monitoring
- Performance metrics
- Log aggregation

**Setup:**
```bash
# Get from: https://app.datadoghq.com/organization-settings/api-keys
export DATADOG_API_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**Storage in 1Password:**
- Item: `pantherOS/monitoring/datadog`
- Field: `api_key`

---

### 8. Tailscale Auth Key (`TAILSCALE_AUTH_KEY`)

**Used for:**
- VPN networking
- Secure host-to-host communication
- Remote access

**Setup:**
```bash
# Generate at: https://login.tailscale.com/admin/settings/keys
export TAILSCALE_AUTH_KEY="tskey-auth-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**Storage in 1Password:**
- Item: `pantherOS/tailscale/authKey`
- Field: `authKey`

**Note:** Already configured in OpNix setup

---

### 9. NPM Token (`NPM_TOKEN`)

**Used for:**
- Publishing packages
- Private registry access
- CI/CD npm operations

**Setup:**
```bash
# Generate at: https://www.npmjs.com/settings/~/tokens
export NPM_TOKEN="npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**Storage in 1Password:**
- Item: `pantherOS/secrets`
- Field: `NPM_TOKEN`

---

### 10. GitLab Token (`GITLAB_TOKEN`)

**Used for:**
- GitLab repository operations
- CI/CD pipelines
- Mirror synchronization

**Setup:**
```bash
# Generate at: https://gitlab.com/-/profile/personal_access_tokens
export GITLAB_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxxx"
```

**Storage in 1Password:**
- Item: `pantherOS/secrets`
- Field: `GITLAB_TOKEN`

---

## Environment Variables

### Development Environment

```bash
# MCP Configuration
export MCP_CONFIG_PATH=".github/mcp-servers.json"

# Node.js Configuration
export NODE_ENV="development"
export NODE_OPTIONS="--max-old-space-size=4096"

# Nix Configuration
export NIX_CONFIG="experimental-features = nix-command flakes"
export NIXPKGS_ALLOW_UNFREE=1

# Direnv Configuration
export DIRENV_LOG_FORMAT=""
```

### AI Development

```bash
# OpenCode Configuration
export OPENCODE_DIR="${HOME}/.opencode"
export OPENCODE_MCP_DIR="${OPENCODE_DIR}/mcp"
export OPENCODE_PLUGIN_DIR="${OPENCODE_DIR}/plugin"
export OPENCODE_SKILLS_DIR="${OPENCODE_DIR}/skills"

# AgentDB Configuration
export AGENTDB_INDEX_PATH="${OPENCODE_DIR}/agentdb/index"
export AGENTDB_MAX_MEMORY="512MB"
export AGENTDB_QUANTIZATION="true"

# Model Configuration
export ANTHROPIC_MODEL="claude-3-5-sonnet-20241022"
export OPENAI_MODEL="gpt-4-turbo-preview"
export MAX_TOKENS="16384"
export CONTEXT_WINDOW="204800"
```

### System Configuration

```bash
# Timezone
export TZ="UTC"

# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Pager
export PAGER="less"
export LESS="-R"
```

### Build and Test

```bash
# Build Configuration
export BUILD_PARALLELISM="8"
export NIX_BUILD_CORES="0"  # Use all cores

# Test Configuration
export TEST_TIMEOUT="300"
export TEST_PARALLEL="4"
```

---

## Setup Instructions

### Method 1: Using 1Password CLI (Recommended)

1. **Install 1Password CLI:**
   ```bash
   # Already included in pantherOS
   op --version
   ```

2. **Sign in to 1Password:**
   ```bash
   op signin
   ```

3. **Create secret items:**
   ```bash
   # Create pantherOS/secrets item
   op item create \
     --category=login \
     --title="pantherOS/secrets" \
     --vault="Personal" \
     GITHUB_TOKEN[password]="your_token" \
     ANTHROPIC_API_KEY[password]="your_key" \
     OPENAI_API_KEY[password]="your_key"
   ```

4. **Verify secrets:**
   ```bash
   op item get "pantherOS/secrets" --vault="Personal"
   ```

### Method 2: Using direnv (Development)

1. **Create `.envrc` file:**
   ```bash
   cat > .envrc <<'EOF'
   # Load secrets from 1Password
   export GITHUB_TOKEN=$(op read "op://Personal/pantherOS/secrets/GITHUB_TOKEN")
   export ANTHROPIC_API_KEY=$(op read "op://Personal/pantherOS/secrets/ANTHROPIC_API_KEY")
   export OPENAI_API_KEY=$(op read "op://Personal/pantherOS/secrets/OPENAI_API_KEY")
   export BRAVE_API_KEY=$(op read "op://Personal/pantherOS/secrets/BRAVE_API_KEY")
   
   # PostgreSQL
   export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"
   
   # MCP Configuration
   export MCP_CONFIG_PATH=".github/mcp-servers.json"
   
   # Development settings
   export NODE_ENV="development"
   export NIXPKGS_ALLOW_UNFREE=1
   EOF
   ```

2. **Allow direnv:**
   ```bash
   direnv allow
   ```

### Method 3: Using Environment Files

1. **Create `.env` file:**
   ```bash
   cat > .env <<'EOF'
   # Required
   GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxx
   
   # AI Development
   ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxx
   OPENAI_API_KEY=sk-xxxxxxxxxxxxx
   
   # MCP Servers
   BRAVE_API_KEY=BSAxxxxxxxxxxx
   POSTGRES_CONNECTION_STRING=postgresql://localhost:5432/agentdb
   
   # System Configuration
   MCP_CONFIG_PATH=.github/mcp-servers.json
   EOF
   ```

2. **Load environment:**
   ```bash
   source .env
   # or
   export $(cat .env | xargs)
   ```

3. **Add to `.gitignore`:**
   ```bash
   echo ".env" >> .gitignore
   ```

---

## Integration-Specific Configuration

### GitHub Copilot

**Required:**
- `GITHUB_TOKEN` with `copilot` scope
- GitHub Copilot subscription

**Configuration:**
```bash
# VS Code settings.json
{
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "plaintext": false,
    "markdown": true
  }
}
```

### Dev Container

**Auto-configured in `.github/devcontainer.json`:**
- GitHub authentication via GitHub CLI
- Nix cache access
- Docker-in-Docker support

**Additional environment:**
```json
{
  "remoteEnv": {
    "GITHUB_TOKEN": "${localEnv:GITHUB_TOKEN}",
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  }
}
```

### MCP Servers

**Configured in `.github/mcp-servers.json`:**

All MCP servers automatically use environment variables:
- `${GITHUB_TOKEN}` → GitHub MCP server
- `${BRAVE_API_KEY}` → Brave Search MCP server
- `${POSTGRES_CONNECTION_STRING}` → PostgreSQL MCP server

**Test configuration:**
```bash
# Verify MCP servers can access secrets
nix develop .#mcp

# Test GitHub MCP server
npx -y @modelcontextprotocol/server-github

# Test Postgres MCP server
npx -y @modelcontextprotocol/server-postgres
```

### OpNix / NixOS

**1Password items required:**

```
pantherOS/secrets              # API keys and tokens
pantherOS/tailscale/authKey    # Tailscale authentication
pantherOS/database/agentdb     # Database credentials
pantherOS/monitoring/datadog   # Monitoring keys
```

**NixOS configuration:**
```nix
# Access via OpNix
services.tailscale.authKeyFile = 
  config.opnix.secrets.opnix-1password."op://pantherOS/tailscale/authKey".path;

# Environment variables via home-manager
home.sessionVariables = {
  ANTHROPIC_API_KEY = 
    config.opnix.secrets.opnix-1password."op://pantherOS/secrets/ANTHROPIC_API_KEY";
};
```

### OpenCode / AI Development

**Directory structure:**
```
~/.opencode/
├── mcp/
│   ├── servers.json           # Copy from .github/mcp-servers.json
│   └── agentdb-server.js      # AgentDB MCP server
├── plugin/
│   └── agentdb/               # AgentDB plugin
└── skills/                    # Enhanced skills
```

**Configuration:**
```bash
# Set up OpenCode directory
mkdir -p ~/.opencode/{mcp,plugin,skills}

# Copy MCP configuration
cp .github/mcp-servers.json ~/.opencode/mcp/servers.json

# Edit with your environment variables
$EDITOR ~/.opencode/mcp/servers.json
```

---

## Security Best Practices

### ✅ DO

1. **Use 1Password for secrets storage**
   - Central secret management
   - Audit logs and access controls
   - Secure sharing capabilities

2. **Use service accounts for automation**
   - Separate tokens for CI/CD
   - Limited scope permissions
   - Easy rotation

3. **Rotate secrets regularly**
   - GitHub tokens: Every 90 days
   - API keys: When compromised
   - Database passwords: Every 180 days

4. **Use environment-specific secrets**
   - Different tokens for dev/staging/prod
   - Separate service accounts per environment

5. **Enable MFA on all accounts**
   - GitHub account
   - 1Password account
   - Cloud provider accounts

### ❌ DON'T

1. **Never commit secrets to git**
   - Use `.gitignore` for `.env` files
   - Scan commits before pushing
   - Use git-secrets or similar tools

2. **Never share secrets in plaintext**
   - Use 1Password sharing
   - Encrypt files if necessary
   - Use secure channels only

3. **Never use personal tokens for systems**
   - Create service accounts
   - Use dedicated bot accounts
   - Separate personal and system access

4. **Never reuse tokens across projects**
   - One token per project
   - Scope appropriately
   - Track usage separately

### Secret Rotation Schedule

| Secret Type | Rotation Frequency | Trigger Events |
|-------------|-------------------|----------------|
| GitHub tokens | 90 days | Compromise, team changes |
| API keys | 180 days | Compromise, provider updates |
| Database passwords | 180 days | Compromise, major upgrades |
| SSH keys | Yearly | Compromise, hardware changes |
| Service accounts | 90 days | Compromise, scope changes |

### Monitoring and Auditing

```bash
# Check 1Password activity
op events list --event-type="item.usage"

# Review GitHub token usage
gh auth status

# Audit environment variables
env | grep -E "(TOKEN|KEY|SECRET|PASSWORD)" | wc -l
```

---

## Troubleshooting

### Secret Not Available

```bash
# Verify 1Password CLI is signed in
op whoami

# Check secret exists
op item get "pantherOS/secrets" --vault="Personal"

# Test secret retrieval
op read "op://Personal/pantherOS/secrets/GITHUB_TOKEN"
```

### MCP Server Authentication Failure

```bash
# Verify environment variable is set
echo $GITHUB_TOKEN

# Test MCP server manually
GITHUB_TOKEN="your_token" npx -y @modelcontextprotocol/server-github

# Check MCP configuration
cat .github/mcp-servers.json | jq '.mcpServers.github'
```

### OpNix Secret Not Found

```bash
# Rebuild NixOS configuration
sudo nixos-rebuild switch --flake .

# Check OpNix secrets
nix eval .#nixosConfigurations.ovh-cloud.config.opnix.secrets --json
```

---

## Quick Setup Script

```bash
#!/usr/bin/env bash
# setup-secrets.sh - Quick setup for pantherOS secrets

set -e

echo "🔐 pantherOS Secrets Setup"
echo ""

# Check 1Password CLI
if ! command -v op &> /dev/null; then
    echo "❌ 1Password CLI not found. Install it first."
    exit 1
fi

# Sign in to 1Password
echo "📝 Signing in to 1Password..."
op signin

# Verify GitHub token
echo "🔍 Checking GitHub token..."
if ! op item get "pantherOS/secrets" --vault="Personal" --fields GITHUB_TOKEN &> /dev/null; then
    echo "⚠️  GITHUB_TOKEN not found in 1Password"
    read -p "Enter GitHub token: " github_token
    op item edit "pantherOS/secrets" GITHUB_TOKEN[password]="$github_token"
fi

# Create .envrc for direnv
echo "📄 Creating .envrc..."
cat > .envrc <<'EOF'
# Load secrets from 1Password
export GITHUB_TOKEN=$(op read "op://Personal/pantherOS/secrets/GITHUB_TOKEN")
export ANTHROPIC_API_KEY=$(op read "op://Personal/pantherOS/secrets/ANTHROPIC_API_KEY" 2>/dev/null || echo "")
export OPENAI_API_KEY=$(op read "op://Personal/pantherOS/secrets/OPENAI_API_KEY" 2>/dev/null || echo "")
export BRAVE_API_KEY=$(op read "op://Personal/pantherOS/secrets/BRAVE_API_KEY" 2>/dev/null || echo "")

# MCP Configuration
export MCP_CONFIG_PATH=".github/mcp-servers.json"
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"

# Development
export NODE_ENV="development"
export NIXPKGS_ALLOW_UNFREE=1
EOF

# Allow direnv
if command -v direnv &> /dev/null; then
    direnv allow
    echo "✅ direnv configured"
fi

echo ""
echo "✅ Secrets setup complete!"
echo ""
echo "Next steps:"
echo "  1. Run 'direnv allow' to load environment variables"
echo "  2. Run 'nix develop .#mcp' to enter MCP development environment"
echo "  3. See .github/SECRETS-AND-ENVIRONMENT-VARIABLES.md for details"
```

---

## Summary

**Total Secrets: 10**
- **Required: 2** (GITHUB_TOKEN, OP_SERVICE_ACCOUNT_TOKEN)
- **Recommended: 3** (POSTGRES_CONNECTION_STRING, ANTHROPIC_API_KEY, OPENAI_API_KEY)
- **Optional: 5** (BRAVE_API_KEY, DATADOG_API_KEY, TAILSCALE_AUTH_KEY, NPM_TOKEN, GITLAB_TOKEN)

**Environment Variables: 20+**
- Development: MCP_CONFIG_PATH, NODE_ENV, NIXPKGS_ALLOW_UNFREE
- AI Development: OPENCODE_DIR, AGENTDB_*, MODEL settings
- System: TZ, LANG, EDITOR, PAGER
- Build/Test: BUILD_PARALLELISM, TEST_TIMEOUT

**Storage:**
- Primary: 1Password vault (`pantherOS/secrets`)
- Development: `.envrc` with direnv (not committed)
- Production: OpNix integration via NixOS configuration

**Documentation:**
- MCP Servers: `.github/mcp-servers.json`
- Setup Guide: `.github/MCP-SETUP.md`
- OpNix Guide: `OPNIX-SETUP.md`
- 1Password Guide: `system_config/secrets_management/MASTER_1PASSWORD_GUIDE.md`
