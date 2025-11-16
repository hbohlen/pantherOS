# Secrets and Environment Variables - Complete Inventory

**Generated:** 2025-11-16  
**Project:** pantherOS NixOS Configuration System  
**Purpose:** Complete inventory of all secrets and environment variables in the project

---

## 📊 Summary Statistics

| Category | Count | Status |
|----------|-------|--------|
| **Secrets** | 10 | Documented |
| **Environment Variables** | 28 | Documented |
| **MCP Servers** | 11 | Configured |
| **Dev Shells** | 8 | Available |
| **1Password Items** | 4 | Required |

---

## 🔐 Secrets Inventory (10 Total)

### Priority: REQUIRED (2)

| # | Secret Name | Purpose | Where Used | Source |
|---|------------|---------|------------|--------|
| 1 | `GITHUB_TOKEN` | GitHub API access, Copilot authentication | MCP github server, Copilot, CI/CD, Dev Container | [github.com/settings/tokens](https://github.com/settings/tokens) |
| 2 | `OP_SERVICE_ACCOUNT_TOKEN` | 1Password automation for OpNix | OpNix secrets management, CI/CD pipelines | 1Password service account |

### Priority: RECOMMENDED (3)

| # | Secret Name | Purpose | Where Used | Source |
|---|------------|---------|------------|--------|
| 3 | `POSTGRES_CONNECTION_STRING` | AgentDB vector database connection | MCP postgres server, AI infrastructure | Local/remote PostgreSQL |
| 4 | `ANTHROPIC_API_KEY` | Claude AI access | AI agents, development, code generation | [console.anthropic.com](https://console.anthropic.com) |
| 5 | `OPENAI_API_KEY` | OpenAI/GPT API access | AI agents, embeddings, development | [platform.openai.com](https://platform.openai.com) |

### Priority: OPTIONAL (5)

| # | Secret Name | Purpose | Where Used | Source |
|---|------------|---------|------------|--------|
| 6 | `BRAVE_API_KEY` | Web search capability | MCP brave-search server | [brave.com/search/api](https://brave.com/search/api) |
| 7 | `DATADOG_API_KEY` | System monitoring and metrics | Datadog agent, monitoring | [app.datadoghq.com](https://app.datadoghq.com) |
| 8 | `TAILSCALE_AUTH_KEY` | VPN networking | Tailscale service, OpNix | [login.tailscale.com](https://login.tailscale.com) |
| 9 | `NPM_TOKEN` | NPM package operations | Publishing, private registry | [npmjs.com/settings/tokens](https://www.npmjs.com/settings/~/tokens) |
| 10 | `GITLAB_TOKEN` | GitLab repository operations | CI/CD, mirrors | [gitlab.com/tokens](https://gitlab.com/-/profile/personal_access_tokens) |

---

## 🌐 Environment Variables Inventory (28 Total)

### Development Environment (6)

| # | Variable | Default/Example | Purpose | Set By |
|---|----------|-----------------|---------|--------|
| 1 | `MCP_CONFIG_PATH` | `.github/mcp-servers.json` | MCP server configuration path | mcp dev shell |
| 2 | `NODE_ENV` | `development` | Node.js environment mode | User/shell |
| 3 | `NODE_OPTIONS` | `--max-old-space-size=4096` | Node.js runtime options | User/shell |
| 4 | `NIX_CONFIG` | `experimental-features = nix-command flakes` | Nix configuration | User/system |
| 5 | `NIXPKGS_ALLOW_UNFREE` | `1` | Allow unfree packages | User/shell |
| 6 | `DIRENV_LOG_FORMAT` | `""` | Direnv log format | User/shell |

### AI Development Environment (8)

| # | Variable | Default/Example | Purpose | Set By |
|---|----------|-----------------|---------|--------|
| 7 | `OPENCODE_DIR` | `${HOME}/.opencode` | OpenCode root directory | mcp dev shell |
| 8 | `OPENCODE_MCP_DIR` | `${OPENCODE_DIR}/mcp` | MCP servers directory | mcp dev shell |
| 9 | `OPENCODE_PLUGIN_DIR` | `${OPENCODE_DIR}/plugin` | Plugins directory | mcp dev shell |
| 10 | `OPENCODE_SKILLS_DIR` | `${OPENCODE_DIR}/skills` | Skills directory | mcp dev shell |
| 11 | `AGENTDB_INDEX_PATH` | `${OPENCODE_DIR}/agentdb/index` | AgentDB index location | ai dev shell |
| 12 | `AGENTDB_MAX_MEMORY` | `512MB` | AgentDB memory limit | ai dev shell |
| 13 | `AGENTDB_QUANTIZATION` | `true` | Enable quantization | ai dev shell |
| 14 | `CONTEXT_WINDOW` | `204800` | Max context window tokens | User/config |

### AI Model Configuration (3)

| # | Variable | Default/Example | Purpose | Set By |
|---|----------|-----------------|---------|--------|
| 15 | `ANTHROPIC_MODEL` | `claude-3-5-sonnet-20241022` | Default Anthropic model | User/config |
| 16 | `OPENAI_MODEL` | `gpt-4-turbo-preview` | Default OpenAI model | User/config |
| 17 | `MAX_TOKENS` | `16384` | Max output tokens | User/config |

### System Configuration (5)

| # | Variable | Default/Example | Purpose | Set By |
|---|----------|-----------------|---------|--------|
| 18 | `TZ` | `UTC` | System timezone | NixOS/user |
| 19 | `LANG` | `en_US.UTF-8` | System language | NixOS/user |
| 20 | `LC_ALL` | `en_US.UTF-8` | Locale settings | NixOS/user |
| 21 | `EDITOR` | `nvim` | Default text editor | User/shell |
| 22 | `VISUAL` | `nvim` | Visual editor | User/shell |

### System Tools (2)

| # | Variable | Default/Example | Purpose | Set By |
|---|----------|-----------------|---------|--------|
| 23 | `PAGER` | `less` | Default pager | User/shell |
| 24 | `LESS` | `-R` | Less options | User/shell |

### Build and Test Configuration (4)

| # | Variable | Default/Example | Purpose | Set By |
|---|----------|-----------------|---------|--------|
| 25 | `BUILD_PARALLELISM` | `8` | Parallel build jobs | User/config |
| 26 | `NIX_BUILD_CORES` | `0` (all cores) | Nix build cores | User/config |
| 27 | `TEST_TIMEOUT` | `300` | Test timeout seconds | User/config |
| 28 | `TEST_PARALLEL` | `4` | Parallel test jobs | User/config |

---

## 📂 1Password Vault Structure

### Required Items (4)

| # | Item Path | Type | Fields | Purpose |
|---|-----------|------|--------|---------|
| 1 | `pantherOS/secrets` | Login | GITHUB_TOKEN, ANTHROPIC_API_KEY, OPENAI_API_KEY, BRAVE_API_KEY, NPM_TOKEN, GITLAB_TOKEN | Main secrets storage |
| 2 | `pantherOS/tailscale/authKey` | Custom | authKey | Tailscale VPN authentication |
| 3 | `pantherOS/database/agentdb` | Custom | connection_string | AgentDB database credentials |
| 4 | `pantherOS/monitoring/datadog` | Custom | api_key | Datadog monitoring |

### SSH Keys (Pre-existing)

| # | Item Path | Type | Purpose |
|---|-----------|------|---------|
| 1 | `pantherOS/yogaSSH/public key` | SSH Key | Yoga laptop SSH |
| 2 | `pantherOS/zephyrusSSH/public key` | SSH Key | Zephyrus laptop SSH |
| 3 | `pantherOS/phoneSSH/public key` | SSH Key | Phone SSH |
| 4 | `pantherOS/desktopSSH/public key` | SSH Key | Desktop SSH |

---

## 🔧 MCP Servers Inventory (11 Total)

### Essential Servers (4)

| # | Server | Env Vars Required | Purpose | Status |
|---|--------|-------------------|---------|--------|
| 1 | `github` | `GITHUB_TOKEN` | Repository operations, issues, PRs | Configured |
| 2 | `filesystem` | None | Local file access | Configured |
| 3 | `git` | None | Git operations | Configured |
| 4 | `brave-search` | `BRAVE_API_KEY` (optional) | Web search | Configured |

### NixOS-Specific Servers (2)

| # | Server | Env Vars Required | Purpose | Status |
|---|--------|-------------------|---------|--------|
| 5 | `nix-search` | None | Package search | Configured |
| 6 | `fetch` | None | HTTP requests | Configured |

### AI Infrastructure Servers (3)

| # | Server | Env Vars Required | Purpose | Status |
|---|--------|-------------------|---------|--------|
| 7 | `postgres` | `POSTGRES_CONNECTION_STRING` | Database operations | Configured |
| 8 | `memory` | None | Knowledge graph | Configured |
| 9 | `sequential-thinking` | None | Enhanced reasoning | Configured |

### Testing Servers (2)

| # | Server | Env Vars Required | Purpose | Status |
|---|--------|-------------------|---------|--------|
| 10 | `puppeteer` | None | Browser automation | Configured |
| 11 | `docker` | None | Container management | Configured |

---

## 🛠️ Development Shells Inventory (8 Total)

| # | Shell | Command | Packages | Purpose |
|---|-------|---------|----------|---------|
| 1 | `default` | `nix develop` | git, neovim, fish, starship, direnv, nil, nixpkgs-fmt | General development |
| 2 | `nix` | `nix develop .#nix` | nix, nil, nixpkgs-fmt, nix-init, nix-eval-lsp | Nix development |
| 3 | `rust` | `nix develop .#rust` | rustup, cargo, rust-analyzer, clippy | Rust development |
| 4 | `node` | `nix develop .#node` | nodejs-18_x, nodejs-20_x, yarn, pnpm, npm | Node.js development |
| 5 | `python` | `nix develop .#python` | python3, pip, virtualenv, pylint, black | Python development |
| 6 | `go` | `nix develop .#go` | go, gopls, golangci-lint, gotools, air | Go development |
| 7 | `mcp` | `nix develop .#mcp` | nodejs-20_x, postgresql, sqlite, docker, jq, ripgrep | MCP/AI development |
| 8 | `ai` | `nix develop .#ai` | python3, numpy, pandas, postgresql, redis, tmux | AI infrastructure |

---

## 🎯 Usage Matrix

### By Use Case

| Use Case | Required Secrets | Required Env Vars | Dev Shell | MCP Servers |
|----------|------------------|-------------------|-----------|-------------|
| **GitHub Copilot Only** | GITHUB_TOKEN | - | default | - |
| **Basic MCP Development** | GITHUB_TOKEN | MCP_CONFIG_PATH | mcp | github, filesystem, git |
| **Full MCP Development** | GITHUB_TOKEN, BRAVE_API_KEY, POSTGRES_CONNECTION_STRING | MCP_CONFIG_PATH | mcp | All 11 servers |
| **AI Development** | GITHUB_TOKEN, ANTHROPIC_API_KEY, OPENAI_API_KEY, POSTGRES_CONNECTION_STRING | MCP_CONFIG_PATH, OPENCODE_DIR, AGENTDB_* | ai | postgres, memory, sequential-thinking |
| **NixOS Deployment** | OP_SERVICE_ACCOUNT_TOKEN, TAILSCALE_AUTH_KEY, DATADOG_API_KEY | - | default | - |
| **Dev Container** | GITHUB_TOKEN, ANTHROPIC_API_KEY | - | (containerized) | github, filesystem |

### By Integration

| Integration | Secrets | Env Vars | Configuration Files |
|-------------|---------|----------|---------------------|
| **GitHub Copilot** | GITHUB_TOKEN | - | IDE settings |
| **MCP Servers** | GITHUB_TOKEN, BRAVE_API_KEY, POSTGRES_CONNECTION_STRING | MCP_CONFIG_PATH | `.github/mcp-servers.json` |
| **Dev Container** | GITHUB_TOKEN, ANTHROPIC_API_KEY | - | `.github/devcontainer.json` |
| **OpNix/NixOS** | OP_SERVICE_ACCOUNT_TOKEN, TAILSCALE_AUTH_KEY | - | `flake.nix`, `configuration.nix` |
| **OpenCode** | ANTHROPIC_API_KEY, OPENAI_API_KEY | OPENCODE_DIR, OPENCODE_*_DIR | `~/.opencode/mcp/servers.json` |
| **AgentDB** | POSTGRES_CONNECTION_STRING | AGENTDB_INDEX_PATH, AGENTDB_MAX_MEMORY | AgentDB config |

---

## 📍 Configuration File Locations

### Repository Files

| # | File | Purpose | Size |
|---|------|---------|------|
| 1 | `.github/copilot-instructions.md` | Copilot repository context | 8.9 KB |
| 2 | `.github/mcp-servers.json` | MCP server configurations | 3.8 KB |
| 3 | `.github/devcontainer.json` | Dev Container configuration | 1.7 KB |
| 4 | `.github/MCP-SETUP.md` | MCP setup guide | 7.4 KB |
| 5 | `.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md` | Complete secrets guide | 18 KB |
| 6 | `.github/SECRETS-QUICK-REFERENCE.md` | Quick reference card | 7.4 KB |
| 7 | `flake.nix` | Nix flake with dev shells | 4.3 KB |
| 8 | `OPNIX-SETUP.md` | OpNix setup guide | 3.5 KB |

### User Configuration Files (Created at Runtime)

| # | File | Purpose | Auto-Created |
|---|------|---------|--------------|
| 1 | `.envrc` | direnv environment variables | No (user creates) |
| 2 | `.env` | Manual environment file | No (user creates) |
| 3 | `~/.opencode/mcp/servers.json` | OpenCode MCP config | Yes (mcp shell) |
| 4 | `~/.opencode/agentdb/index` | AgentDB index | Yes (ai shell) |

---

## 🔄 Setup Status Checklist

### Phase 1: Core Setup ✅

- [x] GitHub Copilot instructions created
- [x] MCP servers configured (11 total)
- [x] Dev Container configuration
- [x] Enhanced development shells (mcp, ai)
- [x] Secrets documentation (complete guide)
- [x] Secrets documentation (quick reference)
- [x] Environment variables documented

### Phase 2: Secrets Configuration (User Action Required) ⏳

- [ ] Generate GitHub token with required scopes
- [ ] Create 1Password service account token
- [ ] Set up 1Password vault items structure
- [ ] Configure AI API keys (Anthropic, OpenAI)
- [ ] Set up PostgreSQL database for AgentDB
- [ ] Configure optional secrets (Brave, Datadog, Tailscale)

### Phase 3: Environment Setup (User Action Required) ⏳

- [ ] Create `.envrc` file with direnv
- [ ] Configure MCP environment variables
- [ ] Test MCP server connections
- [ ] Set up OpenCode directory structure
- [ ] Configure AgentDB database

### Phase 4: Integration Testing (User Action Required) ⏳

- [ ] Test GitHub Copilot with GITHUB_TOKEN
- [ ] Test MCP servers (github, filesystem, git)
- [ ] Test AI development environment
- [ ] Test Dev Container
- [ ] Verify OpNix secrets integration

---

## 🔍 Verification Commands

### Check Secrets

```bash
# Verify secrets are set
echo "GitHub Token: ${GITHUB_TOKEN:0:10}..."
echo "Anthropic Key: ${ANTHROPIC_API_KEY:0:10}..."
echo "OpenAI Key: ${OPENAI_API_KEY:0:10}..."
echo "Postgres: ${POSTGRES_CONNECTION_STRING:0:20}..."

# Check 1Password items
op item get "pantherOS/secrets" --vault="Personal"
op item get "pantherOS/tailscale/authKey" --vault="Personal"
```

### Check Environment Variables

```bash
# List all pantherOS-related env vars
env | grep -E "(GITHUB|ANTHROPIC|OPENAI|POSTGRES|MCP|OPENCODE|AGENTDB)" | sort

# Check MCP configuration
cat $MCP_CONFIG_PATH | jq '.mcpServers | keys'
```

### Test MCP Servers

```bash
# Enter MCP development shell
nix develop .#mcp

# Test GitHub MCP server
npx -y @modelcontextprotocol/server-github

# Test Postgres MCP server
npx -y @modelcontextprotocol/server-postgres
```

### Verify Development Shells

```bash
# List available dev shells
nix flake show | grep devShells

# Test each shell
nix develop .#default --command echo "✓ default shell works"
nix develop .#mcp --command echo "✓ mcp shell works"
nix develop .#ai --command echo "✓ ai shell works"
```

---

## 📊 Security Compliance

### Rotation Schedule

| Secret Type | Current Count | Rotation Frequency | Next Review |
|-------------|---------------|-------------------|-------------|
| GitHub tokens | 1 | 90 days | User-defined |
| API keys | 4 | 180 days | User-defined |
| Database passwords | 1 | 180 days | User-defined |
| SSH keys | 4 | 365 days | User-defined |
| Service accounts | 1 | 90 days | User-defined |

### Security Checklist

- [x] Secrets documented with priority levels
- [x] 1Password integration configured
- [x] Environment variables scoped appropriately
- [x] No secrets in version control
- [x] `.gitignore` includes `.env` files
- [x] Token scopes documented
- [x] MFA recommendations included
- [x] Rotation schedules defined
- [x] Audit procedures documented

---

## 📚 Documentation Cross-Reference

| Topic | Primary Document | Supporting Documents |
|-------|------------------|---------------------|
| **Quick Setup** | `.github/SECRETS-QUICK-REFERENCE.md` | `.github/MCP-SETUP.md` |
| **Complete Guide** | `.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md` | All other docs |
| **MCP Servers** | `.github/mcp-servers.json`, `.github/MCP-SETUP.md` | Copilot instructions |
| **1Password** | `OPNIX-SETUP.md` | `system_config/secrets_management/` |
| **Dev Shells** | `flake.nix` | Copilot instructions, MCP setup |
| **Repository Context** | `.github/copilot-instructions.md` | All configuration docs |

---

## 🎯 Summary

**Total Items Inventoried:** 61
- 10 Secrets (2 required, 3 recommended, 5 optional)
- 28 Environment Variables
- 11 MCP Servers
- 8 Development Shells
- 4 1Password Vault Items

**Documentation Coverage:** Complete
- Setup guides: 3 files (18KB total)
- Configuration files: 4 files
- Integration guides: Included for all tools

**Status:** Ready for user configuration
- All infrastructure configured ✅
- All documentation complete ✅
- User action required for secrets setup ⏳

---

**Last Updated:** 2025-11-16  
**Commit:** 6c1d1b6  
**Generated By:** GitHub Copilot Coding Agent
