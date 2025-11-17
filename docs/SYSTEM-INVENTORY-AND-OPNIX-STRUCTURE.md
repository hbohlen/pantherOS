# System Inventory & 1Password/OpNix Structure

**Generated:** 2025-11-17  
**Project:** pantherOS NixOS Configuration  
**Purpose:** Complete inventory of packages, services, configurations, dotfiles, environment variables, and secrets with 1Password naming conventions

---

## Table of Contents

1. [Overview](#overview)
2. [1Password Vault Structure](#1password-vault-structure)
3. [NixOS Packages Inventory](#nixos-packages-inventory)
4. [System Services Inventory](#system-services-inventory)
5. [Configuration Files Inventory](#configuration-files-inventory)
6. [Dotfiles & Settings Files](#dotfiles--settings-files)
7. [Environment Variables](#environment-variables)
8. [Secrets & Credentials](#secrets--credentials)
9. [OpNix Integration Plan](#opnix-integration-plan)
10. [Implementation Roadmap](#implementation-roadmap)

---

## Overview

This document provides a complete inventory of all system components in pantherOS and defines the organizational structure for secrets management using 1Password and OpNix.

### Naming Convention

All 1Password references follow this structure:
```
op://<vault>/<item>/[section]/<field>
```

**Example:**
```
op://pantherOS/secrets/api-keys/github_token
op://pantherOS/ssh-keys/yoga/public_key
op://pantherOS/database/agentdb/connection_string
```

---

## 1Password Vault Structure

### Vault: `pantherOS`

The primary vault for all pantherOS-related secrets, configurations, and credentials.

#### Item Structure

```
pantherOS/
├── secrets                          # Main secrets item
│   ├── [section: api-keys]
│   │   ├── github_token
│   │   ├── anthropic_api_key
│   │   ├── openai_api_key
│   │   ├── brave_api_key
│   │   ├── npm_token
│   │   └── gitlab_token
│   ├── [section: service-accounts]
│   │   └── op_service_account_token
│   └── [section: monitoring]
│       └── datadog_api_key
│
├── ssh-keys/                        # SSH keys per device
│   ├── yoga                         # Lenovo Yoga laptop
│   │   ├── public_key
│   │   ├── private_key
│   │   └── fingerprint
│   ├── zephyrus                     # ASUS Zephyrus laptop
│   │   ├── public_key
│   │   ├── private_key
│   │   └── fingerprint
│   ├── phone                        # Mobile device
│   │   ├── public_key
│   │   ├── private_key
│   │   └── fingerprint
│   └── desktop                      # Desktop workstation
│       ├── public_key
│       ├── private_key
│       └── fingerprint
│
├── database/                        # Database credentials
│   ├── agentdb
│   │   ├── connection_string
│   │   ├── username
│   │   ├── password
│   │   ├── host
│   │   ├── port
│   │   └── database_name
│   └── postgres
│       ├── connection_string
│       ├── admin_password
│       └── user_password
│
├── vpn/                            # VPN configurations
│   ├── tailscale
│   │   ├── auth_key
│   │   ├── oauth_client_id
│   │   └── oauth_client_secret
│   └── wireguard
│       ├── private_key
│       ├── public_key
│       └── preshared_key
│
├── servers/                        # Server-specific configurations
│   ├── ovh-cloud
│   │   ├── api_token
│   │   ├── root_password
│   │   └── recovery_key
│   └── hetzner-cloud
│       ├── api_token
│       ├── root_password
│       └── recovery_key
│
└── development/                    # Development environment secrets
    ├── github-copilot
    │   ├── token
    │   └── oauth_token
    ├── mcp-servers
    │   └── config_backup
    └── dev-container
        └── env_backup
```

---

## NixOS Packages Inventory

### System-Wide Packages

Currently minimized for initial deployment. Full list to be added after deployment.

#### Core Utilities (Planned)
| Package | Purpose | OpNix Path | Status |
|---------|---------|------------|--------|
| `htop` | Process monitoring | N/A | Planned |
| `unzip` | Archive extraction | N/A | Planned |
| `zip` | Archive creation | N/A | Planned |
| `openssh` | SSH client/server | N/A | ✅ Enabled |
| `gcc` | C compiler | N/A | Planned |
| `gnumake` | Build automation | N/A | Planned |
| `pkg-config` | Package configuration | N/A | Planned |

#### Development Tools (Planned)
| Package | Purpose | OpNix Path | Status |
|---------|---------|------------|--------|
| `git` | Version control | N/A | ✅ Installed |
| `neovim` | Text editor | `op://pantherOS/development/neovim/config` | ✅ Installed |
| `nil` | Nix LSP | N/A | ✅ Installed |
| `nixpkgs-fmt` | Nix formatter | N/A | ✅ Installed |

### User Packages (Home Manager)

Currently disabled for initial deployment.

#### Shell & CLI Tools (Planned)
| Package | Purpose | Config Path | OpNix Path | Status |
|---------|---------|-------------|------------|--------|
| `fish` | User shell | `~/.config/fish/` | `op://pantherOS/dotfiles/fish/config` | Planned |
| `starship` | Shell prompt | `~/.config/starship.toml` | `op://pantherOS/dotfiles/starship/config` | Planned |
| `eza` | Modern ls | N/A | N/A | Planned |
| `ripgrep` | Fast grep | N/A | N/A | Planned |
| `zoxide` | Directory jumper | `~/.local/share/zoxide/` | N/A | Planned |
| `direnv` | Environment manager | `~/.direnvrc` | `op://pantherOS/dotfiles/direnv/config` | Planned |
| `nix-direnv` | Nix + direnv | N/A | N/A | Planned |

#### GitHub & Git Tools (Planned)
| Package | Purpose | Config Path | OpNix Path | Status |
|---------|---------|-------------|------------|--------|
| `gh` | GitHub CLI | `~/.config/gh/` | `op://pantherOS/secrets/api-keys/github_token` | Planned |
| `git` | Version control | `~/.gitconfig` | `op://pantherOS/dotfiles/git/config` | Planned |

#### Monitoring & System Tools (Planned)
| Package | Purpose | Config Path | OpNix Path | Status |
|---------|---------|-------------|------------|--------|
| `bottom` | System monitor | `~/.config/bottom/` | N/A | Planned |
| `htop` | Process viewer | `~/.config/htop/` | N/A | Planned |

#### Secrets Management (Planned)
| Package | Purpose | Config Path | OpNix Path | Status |
|---------|---------|-------------|------------|--------|
| `_1password` | 1Password CLI | `~/.config/op/` | `op://pantherOS/secrets/service-accounts/op_service_account_token` | Planned |
| `_1password-gui` | 1Password Desktop | N/A | N/A | Future |

### Development Environment Packages

From `flake.nix` dev shells:

#### Default Shell
```nix
git, neovim, fish, starship, direnv, nil, nixpkgs-fmt
```

#### Nix Shell
```nix
nix, nil, nixpkgs-fmt, nix-init, nix-eval-lsp
```

#### Rust Shell
```nix
rustup, cargo, rust-analyzer, clippy, bindgen, cbindgen
```

#### Node.js Shell
```nix
nodejs-18_x, nodejs-20_x, yarn, pnpm, npm-9_x
```

#### Python Shell
```nix
python3, pip, virtualenv, pylint, black, isort
```

#### Go Shell
```nix
go, gopls, golangci-lint, gotools, air
```

#### MCP Shell
```nix
nodejs-20_x, postgresql, sqlite, docker, docker-compose, jq, curl, wget, ripgrep, fd, bat
```
- **OpNix Path:** `op://pantherOS/development/mcp-servers/config_backup`

#### AI Shell
```nix
python3, numpy, pandas, postgresql, sqlite, redis, nodejs-20_x, yarn, tmux
```
- **OpNix Path:** `op://pantherOS/database/agentdb/connection_string`

---

## System Services Inventory

### Enabled Services

#### SSH Service
| Attribute | Value | OpNix Path |
|-----------|-------|------------|
| Service | `services.openssh.enable` | N/A |
| Port | 22 | N/A |
| PermitRootLogin | no | N/A |
| PasswordAuthentication | false | N/A |
| Authorized Keys | 4 devices | `op://pantherOS/ssh-keys/*/public_key` |

#### NetworkManager
| Attribute | Value | OpNix Path |
|-----------|-------|------------|
| Service | `networking.useDHCP` | N/A |
| Hostname (OVH) | ovh-cloud | N/A |
| Hostname (Hetzner) | hetzner-cloud | N/A |

### Disabled/Planned Services

#### Tailscale VPN (Planned)
| Attribute | Value | OpNix Path |
|-----------|-------|------------|
| Service | `services.tailscale.enable` | `op://pantherOS/vpn/tailscale/auth_key` |
| Status | Not configured | - |

#### Datadog Agent (Planned)
| Attribute | Value | OpNix Path |
|-----------|-------|------------|
| Service | `services.datadog-agent.enable` | `op://pantherOS/secrets/monitoring/datadog_api_key` |
| Status | Not configured | - |

#### Podman (Planned)
| Attribute | Value | OpNix Path |
|-----------|-------|------------|
| Service | `virtualisation.podman.enable` | N/A |
| Status | User in group, service not enabled | - |

#### OpNix (Planned)
| Attribute | Value | OpNix Path |
|-----------|-------|------------|
| Module | `opnix.nixosModules.default` | `op://pantherOS/secrets/service-accounts/op_service_account_token` |
| Status | Imported but not configured | - |

---

## Configuration Files Inventory

### Repository Configuration Files

#### Nix Configuration
| File | Purpose | OpNix Integration | Status |
|------|---------|-------------------|--------|
| `flake.nix` | Main flake definition | N/A | ✅ Exists |
| `flake.lock` | Dependency lock | N/A | ✅ Exists |
| `hosts/servers/ovh-cloud/configuration.nix` | System config | SSH keys from `op://pantherOS/ssh-keys/*/public_key` | ✅ Exists |
| `hosts/servers/ovh-cloud/disko.nix` | Disk layout | N/A | ✅ Exists |
| `hosts/servers/ovh-cloud/home.nix` | User environment | Various dotfiles | Exists, disabled |
| `hosts/servers/hetzner-cloud/configuration.nix` | System config | SSH keys from `op://pantherOS/ssh-keys/*/public_key` | ✅ Exists |
| `hosts/servers/hetzner-cloud/disko.nix` | Disk layout | N/A | ✅ Exists |
| `hosts/servers/hetzner-cloud/home.nix` | User environment | Various dotfiles | Exists, disabled |

#### GitHub Configuration
| File | Purpose | OpNix Integration | Status |
|------|---------|-------------------|--------|
| `.github/copilot-instructions.md` | AI agent context | N/A | ✅ Exists |
| `.github/mcp-servers.json` | MCP server configs | `op://pantherOS/secrets/api-keys/*` | ✅ Exists |
| `.github/devcontainer.json` | Dev container | `op://pantherOS/secrets/api-keys/github_token` | ✅ Exists |
| `.github/SECRETS-*.md` | Documentation | References to 1Password paths | ✅ Exists |

#### Build & Deployment
| File | Purpose | OpNix Integration | Status |
|------|---------|-------------------|--------|
| `deploy.sh` | Deployment script | Server credentials | ✅ Exists |
| `migrate-to-dual-disk.sh` | Disk migration | N/A | ✅ Exists |

---

## Dotfiles & Settings Files

### User Configuration Files (Home Manager)

These files will be managed by Home Manager when enabled.

#### Shell Configuration
| File | Purpose | OpNix Path | Status |
|------|---------|------------|--------|
| `~/.config/fish/config.fish` | Fish shell config | `op://pantherOS/dotfiles/fish/config` | Planned |
| `~/.config/fish/functions/` | Fish functions | `op://pantherOS/dotfiles/fish/functions` | Planned |
| `~/.config/starship.toml` | Starship prompt | `op://pantherOS/dotfiles/starship/config` | Planned |
| `~/.direnvrc` | direnv configuration | `op://pantherOS/dotfiles/direnv/config` | Planned |

#### Git Configuration
| File | Purpose | OpNix Path | Status |
|------|---------|------------|--------|
| `~/.gitconfig` | Git global config | `op://pantherOS/dotfiles/git/config` | Planned |
| `~/.gitignore_global` | Global gitignore | `op://pantherOS/dotfiles/git/ignore` | Planned |
| `~/.config/gh/config.yml` | GitHub CLI config | `op://pantherOS/secrets/api-keys/github_token` | Planned |

#### Editor Configuration
| File | Purpose | OpNix Path | Status |
|------|---------|------------|--------|
| `~/.config/nvim/init.lua` | Neovim config | `op://pantherOS/dotfiles/neovim/config` | Planned |
| `~/.vimrc` | Vim config | `op://pantherOS/dotfiles/vim/config` | Planned |

#### Development Tools
| File | Purpose | OpNix Path | Status |
|------|---------|------------|--------|
| `~/.config/bottom/bottom.toml` | Bottom config | N/A | Planned |
| `~/.config/htop/htoprc` | htop config | N/A | Planned |

#### AI/MCP Configuration
| File | Purpose | OpNix Path | Status |
|------|---------|------------|--------|
| `~/.opencode/mcp/servers.json` | OpenCode MCP | `op://pantherOS/development/mcp-servers/config_backup` | Planned |
| `~/.opencode/agentdb/config.json` | AgentDB config | `op://pantherOS/database/agentdb/connection_string` | Planned |

#### 1Password Configuration
| File | Purpose | OpNix Path | Status |
|------|---------|------------|--------|
| `~/.config/op/config` | 1Password CLI | `op://pantherOS/secrets/service-accounts/op_service_account_token` | Planned |

---

## Environment Variables

### System Environment Variables

Set in NixOS configuration:

| Variable | Value | OpNix Path | Set By | Status |
|----------|-------|------------|--------|--------|
| `TZ` | UTC | N/A | NixOS | ✅ Set |
| `LANG` | en_US.UTF-8 | N/A | NixOS | ✅ Set |
| `LC_ALL` | en_US.UTF-8 | N/A | NixOS | ✅ Set |
| `EDITOR` | nvim | N/A | User | Planned |
| `VISUAL` | nvim | N/A | User | Planned |
| `PAGER` | less | N/A | User | Planned |

### Development Environment Variables

Set by dev shells:

#### Core Development
| Variable | Default | OpNix Path | Set By | Status |
|----------|---------|------------|--------|--------|
| `NIX_CONFIG` | experimental-features = nix-command flakes | N/A | User | Planned |
| `NIXPKGS_ALLOW_UNFREE` | 1 | N/A | User | Planned |
| `DIRENV_LOG_FORMAT` | "" | N/A | User | Planned |

#### MCP Development (mcp shell)
| Variable | Default | OpNix Path | Set By | Status |
|----------|---------|------------|--------|--------|
| `MCP_CONFIG_PATH` | .github/mcp-servers.json | N/A | mcp shell | ✅ Set |
| `OPENCODE_DIR` | ${HOME}/.opencode | N/A | mcp shell | Planned |
| `OPENCODE_MCP_DIR` | ${OPENCODE_DIR}/mcp | N/A | mcp shell | Planned |
| `OPENCODE_PLUGIN_DIR` | ${OPENCODE_DIR}/plugin | N/A | mcp shell | Planned |
| `OPENCODE_SKILLS_DIR` | ${OPENCODE_DIR}/skills | N/A | mcp shell | Planned |

#### AI Development (ai shell)
| Variable | Default | OpNix Path | Set By | Status |
|----------|---------|------------|--------|--------|
| `AGENTDB_INDEX_PATH` | ${OPENCODE_DIR}/agentdb/index | N/A | ai shell | Planned |
| `AGENTDB_MAX_MEMORY` | 512MB | N/A | ai shell | Planned |
| `AGENTDB_QUANTIZATION` | true | N/A | ai shell | Planned |
| `CONTEXT_WINDOW` | 204800 | N/A | User | Planned |

#### AI Model Configuration
| Variable | Default | OpNix Path | Set By | Status |
|----------|---------|------------|--------|--------|
| `ANTHROPIC_MODEL` | claude-3-5-sonnet-20241022 | N/A | User | Planned |
| `OPENAI_MODEL` | gpt-4-turbo-preview | N/A | User | Planned |
| `MAX_TOKENS` | 16384 | N/A | User | Planned |

#### Node.js Environment
| Variable | Default | OpNix Path | Set By | Status |
|----------|---------|------------|--------|--------|
| `NODE_ENV` | development | N/A | User | Planned |
| `NODE_OPTIONS` | --max-old-space-size=4096 | N/A | User | Planned |

#### Build Configuration
| Variable | Default | OpNix Path | Set By | Status |
|----------|---------|------------|--------|--------|
| `BUILD_PARALLELISM` | 8 | N/A | User | Planned |
| `NIX_BUILD_CORES` | 0 (all) | N/A | User | Planned |
| `TEST_TIMEOUT` | 300 | N/A | User | Planned |
| `TEST_PARALLEL` | 4 | N/A | User | Planned |

---

## Secrets & Credentials

### Required Secrets (Priority: HIGH)

| Secret | Purpose | OpNix Path | Status |
|--------|---------|------------|--------|
| `GITHUB_TOKEN` | GitHub API access | `op://pantherOS/secrets/api-keys/github_token` | Required |
| `OP_SERVICE_ACCOUNT_TOKEN` | 1Password automation | `op://pantherOS/secrets/service-accounts/op_service_account_token` | Required |

### Recommended Secrets (Priority: MEDIUM)

| Secret | Purpose | OpNix Path | Status |
|--------|---------|------------|--------|
| `ANTHROPIC_API_KEY` | Claude AI | `op://pantherOS/secrets/api-keys/anthropic_api_key` | Recommended |
| `OPENAI_API_KEY` | OpenAI API | `op://pantherOS/secrets/api-keys/openai_api_key` | Recommended |
| `POSTGRES_CONNECTION_STRING` | AgentDB database | `op://pantherOS/database/agentdb/connection_string` | Recommended |

### Optional Secrets (Priority: LOW)

| Secret | Purpose | OpNix Path | Status |
|--------|---------|------------|--------|
| `BRAVE_API_KEY` | Web search | `op://pantherOS/secrets/api-keys/brave_api_key` | Optional |
| `DATADOG_API_KEY` | Monitoring | `op://pantherOS/secrets/monitoring/datadog_api_key` | Optional |
| `TAILSCALE_AUTH_KEY` | VPN | `op://pantherOS/vpn/tailscale/auth_key` | Optional |
| `NPM_TOKEN` | NPM registry | `op://pantherOS/secrets/api-keys/npm_token` | Optional |
| `GITLAB_TOKEN` | GitLab API | `op://pantherOS/secrets/api-keys/gitlab_token` | Optional |

### SSH Keys

| Key | Device | OpNix Path | Status |
|-----|--------|------------|--------|
| Yoga SSH | Lenovo Yoga laptop | `op://pantherOS/ssh-keys/yoga/public_key` | ✅ Configured |
| Zephyrus SSH | ASUS Zephyrus | `op://pantherOS/ssh-keys/zephyrus/public_key` | ✅ Configured |
| Phone SSH | Mobile device | `op://pantherOS/ssh-keys/phone/public_key` | ✅ Configured |
| Desktop SSH | Desktop workstation | `op://pantherOS/ssh-keys/desktop/public_key` | ✅ Configured |

### Server Credentials

| Server | Credential | OpNix Path | Status |
|--------|------------|------------|--------|
| OVH Cloud | API Token | `op://pantherOS/servers/ovh-cloud/api_token` | Planned |
| OVH Cloud | Root Password | `op://pantherOS/servers/ovh-cloud/root_password` | Planned |
| Hetzner Cloud | API Token | `op://pantherOS/servers/hetzner-cloud/api_token` | Planned |
| Hetzner Cloud | Root Password | `op://pantherOS/servers/hetzner-cloud/root_password` | Planned |

---

## OpNix Integration Plan

### Phase 1: Initial Setup (Current)

**Status:** Not yet implemented

**Tasks:**
1. Enable OpNix module in `flake.nix`
2. Configure service account token
3. Set up vault structure in 1Password
4. Create initial secret items

**Configuration:**
```nix
# In flake.nix
opnix.nixosModules.default {
  services.opnix = {
    enable = true;
    serviceAccountToken = "op://pantherOS/secrets/service-accounts/op_service_account_token";
    vault = "pantherOS";
  };
}
```

### Phase 2: SSH Key Management

**Tasks:**
1. Move SSH public keys to 1Password
2. Configure OpNix to retrieve keys
3. Update `configuration.nix` to use OpNix references

**Example:**
```nix
# Current (hardcoded)
openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3Nza..."
];

# Future (OpNix)
openssh.authorizedKeys.keys = [
  (builtins.readFile (opnix.getSecret "op://pantherOS/ssh-keys/yoga/public_key"))
];
```

### Phase 3: Service Secrets

**Tasks:**
1. Configure Tailscale with OpNix
2. Configure Datadog with OpNix
3. Configure any database credentials

**Example:**
```nix
services.tailscale = {
  enable = true;
  authKeyFile = opnix.getSecretFile "op://pantherOS/vpn/tailscale/auth_key";
};

services.datadog-agent = {
  enable = true;
  api_key = opnix.getSecret "op://pantherOS/secrets/monitoring/datadog_api_key";
};
```

### Phase 4: Environment Variables

**Tasks:**
1. Configure development environment secrets
2. Set up MCP server credentials
3. Configure AI API keys

**Example:**
```nix
home.sessionVariables = {
  GITHUB_TOKEN = opnix.getSecret "op://pantherOS/secrets/api-keys/github_token";
  ANTHROPIC_API_KEY = opnix.getSecret "op://pantherOS/secrets/api-keys/anthropic_api_key";
  OPENAI_API_KEY = opnix.getSecret "op://pantherOS/secrets/api-keys/openai_api_key";
};
```

### Phase 5: Dotfiles Integration

**Tasks:**
1. Store dotfile templates in 1Password
2. Configure Home Manager to use OpNix
3. Sync dotfiles across systems

**Example:**
```nix
home.file.".gitconfig".text = opnix.getSecret "op://pantherOS/dotfiles/git/config";
home.file.".config/starship.toml".text = opnix.getSecret "op://pantherOS/dotfiles/starship/config";
```

---

## Implementation Roadmap

### Immediate (After Initial Deployment)

1. **Enable Home Manager**
   - Uncomment in `flake.nix`
   - Deploy user packages
   - Configure basic dotfiles

2. **Enable System Packages**
   - Uncomment packages in `configuration.nix`
   - Deploy and verify

### Short Term (1-2 weeks)

1. **Set Up 1Password Vault Structure**
   - Create `pantherOS` vault
   - Create all item templates
   - Populate existing secrets

2. **Enable OpNix Module**
   - Configure service account
   - Enable OpNix in flake
   - Test secret retrieval

3. **Migrate SSH Keys**
   - Move to 1Password
   - Update configuration
   - Verify access

### Medium Term (1-2 months)

1. **Service Integration**
   - Enable Tailscale with OpNix
   - Enable Datadog with OpNix
   - Configure monitoring

2. **Development Environment**
   - Migrate MCP server credentials
   - Configure AI API keys
   - Set up AgentDB

3. **Dotfiles Management**
   - Create dotfile templates
   - Store in 1Password
   - Deploy via Home Manager

### Long Term (3+ months)

1. **Full Automation**
   - CI/CD with OpNix
   - Automated secret rotation
   - Multi-host deployment

2. **Desktop Environment**
   - Configure workstation hosts
   - Sync settings via OpNix
   - Deploy Dank Linux setup

3. **Advanced Features**
   - Modular architecture
   - Hardware-specific configs
   - Custom security modules

---

## Verification Checklist

### 1Password Setup
- [ ] Create `pantherOS` vault
- [ ] Create all secret items with correct structure
- [ ] Verify item paths match documented structure
- [ ] Set up service account with appropriate permissions
- [ ] Test secret retrieval with `op` CLI

### OpNix Configuration
- [ ] Enable OpNix module in flake
- [ ] Configure service account token
- [ ] Test secret retrieval in NixOS
- [ ] Verify no secrets in git history
- [ ] Document all OpNix paths

### System Components
- [ ] Inventory all packages
- [ ] Document all services
- [ ] Map all configuration files
- [ ] List all dotfiles
- [ ] Track all environment variables

### Integration Testing
- [ ] Test SSH key retrieval
- [ ] Test service secret injection
- [ ] Test environment variable setup
- [ ] Test dotfile deployment
- [ ] Verify secret rotation procedures

---

## References

- [OpNix Documentation](https://github.com/brizzbuzz/opnix)
- [1Password CLI Reference](https://developer.1password.com/docs/cli/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Options Search](https://search.nixos.org/options)
- [pantherOS Secrets Documentation](.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md)

---

**Last Updated:** 2025-11-17  
**Status:** Initial draft - awaiting 1Password vault setup  
**Next Steps:** Create 1Password vault structure and populate with existing secrets
