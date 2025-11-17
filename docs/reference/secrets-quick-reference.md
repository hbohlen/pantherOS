# Secrets Quick Reference Card

## Essential Setup (Get Started in 5 Minutes)

### 1. Required Secrets (Must Have)

```bash
# GitHub Token - Get from: https://github.com/settings/tokens
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxx"

# 1Password Service Account (for OpNix)
export OP_SERVICE_ACCOUNT_TOKEN="ops_xxxxxxxxxxxxxxxxxxxxx"
```

### 2. Recommended Secrets (AI Development)

```bash
# Claude AI - Get from: https://console.anthropic.com/settings/keys
export ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxxxxxxxxxxx"

# OpenAI - Get from: https://platform.openai.com/api-keys
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxx"

# PostgreSQL (AgentDB) - Local or remote
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"
```

### 3. Optional Secrets (Extended Features)

```bash
# Web Search - Get from: https://brave.com/search/api/
export BRAVE_API_KEY="BSAxxxxxxxxxxxxxxxxxxx"

# Monitoring - Get from: https://app.datadoghq.com
export DATADOG_API_KEY="xxxxxxxxxxxxxxxxxxxxx"

# VPN - Get from: https://login.tailscale.com
export TAILSCALE_AUTH_KEY="tskey-auth-xxxxxxxxxxxxxxxxxxxxx"
```

---

## Quick Setup Commands

### Option A: Using direnv (Recommended)

```bash
# Create .envrc file
cat > .envrc <<'EOF'
export GITHUB_TOKEN=$(op read "op://Personal/pantherOS/secrets/GITHUB_TOKEN")
export ANTHROPIC_API_KEY=$(op read "op://Personal/pantherOS/secrets/ANTHROPIC_API_KEY")
export OPENAI_API_KEY=$(op read "op://Personal/pantherOS/secrets/OPENAI_API_KEY")
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"
export MCP_CONFIG_PATH=".github/mcp-servers.json"
EOF

# Allow direnv
direnv allow
```

### Option B: Manual Export

```bash
# Set all at once
export GITHUB_TOKEN="your_token"
export ANTHROPIC_API_KEY="your_key"
export OPENAI_API_KEY="your_key"
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"
export MCP_CONFIG_PATH=".github/mcp-servers.json"
```

### Option C: Load from 1Password

```bash
# Prerequisites: op CLI installed and signed in
op signin

# Load secrets
export GITHUB_TOKEN=$(op read "op://Personal/pantherOS/secrets/GITHUB_TOKEN")
export ANTHROPIC_API_KEY=$(op read "op://Personal/pantherOS/secrets/ANTHROPIC_API_KEY")
export OPENAI_API_KEY=$(op read "op://Personal/pantherOS/secrets/OPENAI_API_KEY")
```

---

## Verification Commands

```bash
# Check if secrets are loaded
echo "GitHub Token: ${GITHUB_TOKEN:0:10}..."
echo "Anthropic Key: ${ANTHROPIC_API_KEY:0:10}..."
echo "OpenAI Key: ${OPENAI_API_KEY:0:10}..."

# Test MCP servers
nix develop .#mcp
npx -y @modelcontextprotocol/server-github  # Should not error

# Test 1Password CLI
op whoami
op item get "pantherOS/secrets"
```

---

## Where to Store Secrets

### 1Password Items Structure

```
Personal Vault
└── pantherOS/
    ├── secrets                    # Main secrets item
    │   ├── GITHUB_TOKEN
    │   ├── ANTHROPIC_API_KEY
    │   ├── OPENAI_API_KEY
    │   ├── BRAVE_API_KEY
    │   ├── NPM_TOKEN
    │   └── GITLAB_TOKEN
    ├── tailscale/
    │   └── authKey               # Tailscale auth key
    ├── database/
    │   └── agentdb               # Database credentials
    └── monitoring/
        └── datadog               # Datadog API key
```

### Create 1Password Items

```bash
# Sign in to 1Password
op signin

# Create main secrets item
op item create \
  --category=login \
  --title="pantherOS/secrets" \
  --vault="Personal" \
  GITHUB_TOKEN[password]="your_github_token" \
  ANTHROPIC_API_KEY[password]="your_anthropic_key" \
  OPENAI_API_KEY[password]="your_openai_key" \
  BRAVE_API_KEY[password]="your_brave_key"

# Verify
op item get "pantherOS/secrets" --vault="Personal"
```

---

## By Use Case

### For GitHub Copilot Only

```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxx"
```

### For MCP Servers

```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxx"      # github MCP server
export BRAVE_API_KEY="BSAxxxxxxxxxxxxxxxxxxx"        # brave-search MCP
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"  # postgres MCP
export MCP_CONFIG_PATH=".github/mcp-servers.json"
```

### For AI Development

```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxx"
export ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxxxxxxxxxxx"
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxx"
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"
export MCP_CONFIG_PATH=".github/mcp-servers.json"
```

### For NixOS Deployment

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_xxxxxxxxxxxxxxxxxxxxx"  # OpNix
export TAILSCALE_AUTH_KEY="tskey-auth-xxxxxxxxxxxxxxxxxxxxx"
export DATADOG_API_KEY="xxxxxxxxxxxxxxxxxxxxx"
```

### For Dev Container

```bash
# These are automatically passed from host
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxx"
export ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxxxxxxxxxxx"
```

---

## Token Scopes Reference

### GitHub Token Scopes

When creating token at https://github.com/settings/tokens:

- ✅ `repo` - Full repository access
- ✅ `read:org` - Read organization data
- ✅ `read:user` - Read user profile
- ✅ `workflow` - Update GitHub Actions
- ⚠️ `admin:public_key` - Only if managing SSH keys
- ⚠️ `admin:repo_hook` - Only if managing webhooks

### 1Password Service Account Permissions

- ✅ Read access to `Personal` vault
- ✅ Access to `pantherOS/*` items
- ❌ No write access needed
- ❌ No admin access needed

---

## Common Issues

### "GITHUB_TOKEN not set"

```bash
# Check if set
echo $GITHUB_TOKEN

# If empty, set it
export GITHUB_TOKEN="your_token"

# Make permanent with direnv
echo 'export GITHUB_TOKEN="your_token"' >> .envrc
direnv allow
```

### "op: command not found"

```bash
# 1Password CLI not installed
# Enter Nix dev shell first
nix develop .#mcp

# Or install globally
nix-env -iA nixpkgs._1password
```

### "Authentication failed for PostgreSQL"

```bash
# Check connection string format
export POSTGRES_CONNECTION_STRING="postgresql://username:password@host:port/database"

# For local PostgreSQL
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"

# Test connection
psql $POSTGRES_CONNECTION_STRING -c "SELECT version();"
```

### "MCP server not found"

```bash
# Ensure Node.js is available
nix develop .#mcp

# Test MCP server manually
npx -y @modelcontextprotocol/server-github

# Check MCP config path
echo $MCP_CONFIG_PATH
```

---

## Security Reminders

### ✅ DO

- Store secrets in 1Password
- Use service accounts for automation
- Rotate tokens every 90 days
- Use `.envrc` with direnv (add to `.gitignore`)
- Enable MFA on all accounts

### ❌ DON'T

- Commit secrets to git
- Share secrets in plaintext
- Use personal tokens for systems
- Reuse tokens across projects
- Store secrets in unencrypted files

---

## Next Steps

1. **Set up required secrets** (GITHUB_TOKEN, OP_SERVICE_ACCOUNT_TOKEN)
2. **Configure direnv** (copy `.envrc` template above)
3. **Enter dev environment**: `nix develop .#mcp`
4. **Test MCP servers**: `npx -y @modelcontextprotocol/server-github`
5. **Read full guide**: `.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md`

---

## Help & Documentation

- **Full Guide**: `.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md`
- **MCP Setup**: `.github/MCP-SETUP.md`
- **OpNix Guide**: `OPNIX-SETUP.md`
- **1Password Guide**: `system_config/secrets_management/MASTER_1PASSWORD_GUIDE.md`
- **GitHub Tokens**: https://github.com/settings/tokens
- **1Password Service Accounts**: https://my.1password.com/developer
