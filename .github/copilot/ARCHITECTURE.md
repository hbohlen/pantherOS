# GitHub Copilot Coding Agent Architecture

This document describes the architecture and workflow of the GitHub Copilot setup for NixOS development.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Developer Workspace                          │
│                                                                   │
│  ┌─────────────────────┐         ┌─────────────────────┐       │
│  │  GitHub Copilot     │◄────────┤   Local Repository  │       │
│  │  Coding Agent       │         │   (pantherOS)       │       │
│  └──────────┬──────────┘         └─────────────────────┘       │
│             │                                                     │
│             │ Uses                                               │
│             ▼                                                     │
│  ┌──────────────────────────────────────────────────────┐       │
│  │              MCP Servers                              │       │
│  │                                                        │       │
│  │  ┌────────────────┐  ┌────────────────┐             │       │
│  │  │ Sequential     │  │ Brave Search   │             │       │
│  │  │ Thinking       │  │ (Web Search)   │             │       │
│  │  └────────────────┘  └────────────────┘             │       │
│  │                                                        │       │
│  │  ┌────────────────┐  ┌────────────────┐             │       │
│  │  │ Context7       │  │ NixOS MCP      │             │       │
│  │  │ (Code Analysis)│  │ (Pkg/Options)  │             │       │
│  │  └────────────────┘  └────────────────┘             │       │
│  │                                                        │       │
│  │  ┌────────────────┐                                  │       │
│  │  │ DeepWiki       │                                  │       │
│  │  │ (Docs Search)  │                                  │       │
│  │  └────────────────┘                                  │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
└───────────────────────────────┬───────────────────────────────────┘
                                │
                                │ SSH/rsync
                                ▼
                    ┌──────────────────────┐
                    │    VPS Server        │
                    │    (NixOS)           │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ pantherOS      │  │
                    │  │ Repository     │  │
                    │  │ (synced)       │  │
                    │  └────────────────┘  │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ Nix Build      │  │
                    │  │ Environment    │  │
                    │  └────────────────┘  │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ nixos-rebuild  │  │
                    │  │ Operations     │  │
                    │  └────────────────┘  │
                    └──────────────────────┘
```

## Component Details

### 1. GitHub Copilot Coding Agent

**Role**: AI-powered coding assistant with enhanced capabilities

**Capabilities**:
- Code generation and editing
- Configuration analysis
- Problem solving
- Documentation assistance
- Integration with MCP servers

**Configuration**: `.github/copilot/action-setup.yml`

### 2. MCP Servers

#### Sequential Thinking MCP
- **Purpose**: Complex reasoning and planning
- **Use Cases**: 
  - Multi-step migrations
  - Architecture decisions
  - Debugging complex issues
  - Implementation planning
- **Command**: `npx -y @modelcontextprotocol/server-sequential-thinking`

#### Brave Search MCP
- **Purpose**: Web search and real-time information
- **Use Cases**:
  - Finding documentation
  - Package version lookup
  - Research best practices
  - Compatibility checking
- **Command**: `npx -y @modelcontextprotocol/server-brave-search`
- **Requirements**: `BRAVE_API_KEY` secret

#### Context7 MCP
- **Purpose**: Enhanced code understanding
- **Use Cases**:
  - Code impact analysis
  - Semantic search
  - Dependency tracking
  - Related code finding
- **Command**: `npx -y @context7/mcp-server`

#### NixOS MCP
- **Purpose**: NixOS-specific operations
- **Use Cases**:
  - Package search
  - Option lookup
  - Configuration validation
  - Flake operations
- **Command**: `npx -y @nixos/mcp-server`

#### DeepWiki MCP
- **Purpose**: Documentation and wiki search
- **Use Cases**:
  - Finding specific docs
  - Wiki integration
  - Knowledge base access
  - Historical information
- **Command**: `npx -y @deepwiki/mcp-server`

### 3. Local Repository

**Location**: Developer's local machine

**Contents**:
- NixOS configuration files
- Flake definitions
- Host-specific configurations
- Modules and profiles

**Operations**:
- Local editing
- Syntax validation
- Local builds (when possible)
- Git operations

### 4. VPS Server

**Role**: Remote build and test environment

**Purpose**:
- Build NixOS configurations
- Test in production-like environment
- Validate hardware-specific settings
- Safe testing before production deployment

**Operations**:
- Receive configuration updates via rsync
- Build configurations with `nixos-rebuild`
- Apply configurations with `nixos-rebuild switch`
- Rollback if needed

## Workflow Diagrams

### Configuration Change Workflow

```
┌──────────────┐
│ 1. Developer │
│ makes changes│
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│ 2. Copilot assists   │
│ with MCP servers:    │
│ - Research (Brave)   │
│ - Planning (Seq)     │
│ - Packages (NixOS)   │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 3. Test locally      │
│ nix build ...        │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 4. Push to VPS       │
│ rsync → VPS          │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 5. Build on VPS      │
│ nixos-rebuild build  │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 6. Dry-run test      │
│ nixos-rebuild dry    │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 7. Apply if OK       │
│ nixos-rebuild switch │
└──────────────────────┘
```

### MCP Server Integration

```
Developer Query
      │
      ▼
┌─────────────────────────────────────┐
│       Copilot Analyzes Query        │
└───────────────┬─────────────────────┘
                │
                ├──────────────┐
                │              │
         ┌──────▼─────┐   ┌───▼────────┐
         │ Needs web  │   │ Needs code │
         │ research?  │   │ analysis?  │
         └──────┬─────┘   └───┬────────┘
                │             │
         ┌──────▼─────┐   ┌───▼────────┐
         │   Brave    │   │  Context7  │
         │   Search   │   │    MCP     │
         └──────┬─────┘   └───┬────────┘
                │             │
                └──────┬──────┘
                       │
                ┌──────▼─────────┐
                │ Needs NixOS    │
                │ specifics?     │
                └──────┬─────────┘
                       │
                ┌──────▼─────┐
                │  NixOS MCP │
                └──────┬─────┘
                       │
                ┌──────▼──────────┐
                │ Combine results │
                │ and generate    │
                │ response        │
                └─────────────────┘
```

### SSH Access Flow

```
┌─────────────────┐
│ Developer       │
│ Local Machine   │
└────────┬────────┘
         │
         │ 1. SSH Key Auth
         │    (~/.ssh/copilot_vps)
         ▼
┌────────────────────┐
│ VPS SSH Server     │
│ (port 22)          │
└────────┬───────────┘
         │
         │ 2. User authenticated
         │    (nixos user)
         ▼
┌────────────────────┐
│ VPS User Shell     │
│ ~/pantherOS/       │
└────────┬───────────┘
         │
         │ 3. Nix commands
         │    nixos-rebuild ...
         ▼
┌────────────────────┐
│ Nix Build System   │
│ /nix/store/        │
└────────────────────┘
```

## Security Architecture

### Authentication Flow

```
┌──────────────────┐
│ GitHub Secrets   │
│                  │
│ - VPS_SSH_KEY    │
│ - VPS_HOST       │
│ - VPS_USER       │
│ - BRAVE_API_KEY  │
└────────┬─────────┘
         │
         │ Accessed by
         ▼
┌──────────────────┐
│ GitHub Actions   │
│ or Local Setup   │
└────────┬─────────┘
         │
         │ Configured via
         ▼
┌──────────────────┐
│ SSH Client       │
│ ~/.ssh/config    │
└────────┬─────────┘
         │
         │ Connects to
         ▼
┌──────────────────┐
│ VPS SSH Server   │
│ (Key-only auth)  │
└──────────────────┘
```

### Security Layers

1. **SSH Key Authentication**
   - Private key stored in GitHub Secrets
   - Public key on VPS authorized_keys
   - No password authentication

2. **Least Privilege**
   - Dedicated user (not root)
   - Sudo required for system changes
   - Limited permissions

3. **API Keys**
   - Stored in GitHub Secrets
   - Not in version control
   - Environment variable injection

4. **Firewall**
   - SSH port restricted
   - Only necessary ports open
   - Connection limiting

## Data Flow

### Configuration Update Flow

```
Local Files → Git Commit → rsync → VPS Files
                                         │
                                         ▼
                                    Nix Build
                                         │
                                         ▼
                                   Evaluation
                                         │
                                         ▼
                                   Generation
                                         │
                                         ▼
                                    /nix/store
                                         │
                                         ▼
                               System Configuration
```

### MCP Server Data Flow

```
User Query → Copilot → MCP Server → External API/Data
                            │
                            ▼
                       Processing
                            │
                            ▼
                        Results
                            │
                            ▼
                   Copilot Response → User
```

## Deployment Scenarios

### Scenario 1: Local Development

```
Developer ─┐
           ├─► Local Build ─► Test ─► Commit
           │
           └─► Copilot + MCP ─► Code Assistance
```

### Scenario 2: VPS Testing

```
Developer ─► Local Build ─► Push to VPS ─► VPS Build ─► Verify
                                                    │
                                                    ├─► Success → Apply
                                                    └─► Failure → Rollback
```

### Scenario 3: CI/CD Pipeline

```
Git Push ─► GitHub Actions ─► Build Matrix ─┬─► Validate
                                             ├─► Format Check
                                             ├─► Integration Tests
                                             └─► Deploy to VPS (optional)
```

## Monitoring and Logging

### Build Logs

```
Local: nix log <derivation>
VPS:   ssh nixos-vps 'journalctl -xe'
       ssh nixos-vps 'nixos-rebuild switch --show-trace'
```

### System Status

```
Local: nix flake check
VPS:   ssh nixos-vps 'systemctl status'
       ssh nixos-vps 'nix-env --list-generations --profile /nix/var/nix/profiles/system'
```

### MCP Server Status

```
Local: npx -y <mcp-server> --version
       echo $? (exit code check)
```

## Rollback Strategy

### Local Rollback

```
git revert <commit>
OR
git reset --hard <previous-commit>
```

### VPS Rollback

```
ssh nixos-vps 'sudo nixos-rebuild switch --rollback'
OR
ssh nixos-vps 'sudo nixos-rebuild switch --switch-generation <number>'
```

## Performance Considerations

### Build Optimization

- **Cachix**: Cache build artifacts
- **Binary Cache**: Use NixOS binary cache
- **Parallel Builds**: Enable multi-core builds
- **Garbage Collection**: Regular cleanup

### MCP Server Performance

- **Connection Pooling**: Reuse MCP server connections
- **API Rate Limits**: Respect Brave Search limits
- **Caching**: Cache frequently accessed data
- **Timeout Settings**: Configure appropriate timeouts

## Maintenance

### Regular Tasks

1. **Update Dependencies**
   ```bash
   nix flake update
   ```

2. **Garbage Collection**
   ```bash
   sudo nix-collect-garbage -d
   ssh nixos-vps 'sudo nix-collect-garbage -d'
   ```

3. **Security Updates**
   - Rotate SSH keys periodically
   - Update API keys
   - Review access logs

4. **Configuration Audits**
   - Review uncommitted changes
   - Check for deprecated options
   - Validate security settings

## Troubleshooting Architecture

### Problem → Solution Mapping

```
Build Failure
    ├─► Syntax Error → nix flake check --show-trace
    ├─► Missing Package → nix search nixpkgs <package>
    └─► Dependency Issue → nix flake update

Connection Failure
    ├─► SSH → ssh -vvv (verbose output)
    ├─► VPS Down → ping/check status
    └─► Key Issue → chmod 600 ~/.ssh/copilot_vps

MCP Server Issue
    ├─► Not Found → Check Node.js installation
    ├─► API Error → Verify API keys
    └─► Timeout → Check network connectivity
```

## Future Enhancements

### Potential Additions

1. **Additional MCP Servers**
   - GitHub MCP for repository operations
   - Slack MCP for notifications
   - Custom domain-specific MCPs

2. **Enhanced CI/CD**
   - Automated deployment
   - Blue-green deployments
   - Canary releases

3. **Monitoring Integration**
   - Prometheus metrics
   - Grafana dashboards
   - Alert systems

4. **Documentation Generation**
   - Automated changelog
   - Configuration documentation
   - API documentation

## Version History

- **v1.0.0** (2025-12-02): Initial architecture design

## References

- [MCP Protocol Documentation](https://modelcontextprotocol.io/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
