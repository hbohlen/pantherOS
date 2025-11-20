# Project Context

## Purpose
Deploy a production-grade OpenCode server with persistent AI memory system on Hetzner Cloud infrastructure. The system uses FalkorDB + Graphiti for temporal knowledge graphs, enabling OpenCode agents to learn from past interactions and maintain context across sessions. Provides secure remote access via Tailscale, public dashboard via Cloudflare, and complete observability via Datadog.

**Goals:**
- Zero-configuration memory: Automatically capture and recall context
- Multi-device access: Connect from laptop, desktop, anywhere via Tailscale
- Production reliability: Backups, monitoring, declarative infrastructure
- Token efficiency: Use SDK/plugins instead of MCP to minimize context window usage
- ADHD-friendly: Automated workflows, clear structure, persistent state

## Tech Stack

### Infrastructure
- **OS**: NixOS 25.05 (declarative configuration, atomic upgrades, impermanence)
- **Cloud**: Hetzner CPX52 (16 vCPU, 32GB RAM, 480GB NVMe)
- **Filesystem**: Btrfs with subvolumes (snapshots, compression, nodatacow for databases)
- **Containers**: Podman with pods (shared networking, systemd integration)
- **Secrets**: OpNix with 1Password service accounts (no GPG/age keys)

### Application Layer
- **AI Coding Agent**: OpenCode (serve mode for remote attach)
- **Memory System**: Graphiti (temporal knowledge graphs) + FalkorDB (graph database)
- **Cache**: Valkey 7.2 (Redis-compatible, 100% open source)
- **Reverse Proxy**: Caddy with Cloudflare DNS plugin (auto HTTPS, Tailscale auth)
- **Observability**: Datadog (LLM observability, APM, logs, metrics)

### Storage & Backup
- **Object Storage**: Backblaze B2 (S3-compatible, 1/5th AWS pricing)
- **Backup Tool**: rclone (encrypted, incremental)
- **Snapshot Strategy**: Btrfs snapshots every 6 hours, 30-day retention

### Programming Languages
- **Configuration**: Nix (declarative infrastructure as code)
- **Backend**: Python 3 (Graphiti integration, async operations)
- **Plugin**: TypeScript (OpenCode plugin with event hooks)
- **Dashboard**: Python FastAPI + HTMX + Tailwind CSS
- **Scripts**: Bash (operations, backups, health checks)

### Networking
- **VPN**: Tailscale (zero-trust, WireGuard-based)
- **DNS**: Cloudflare (proxy + DNS-01 ACME challenges)
- **Domain**: hbohlen.systems

## Project Conventions

### Code Style

**Nix:**
- Indentation: 2 spaces
- Line length: 100 characters max
- Attribute sets: Alphabetically sorted
- Imports: Group by category (system, user, hardware)
- Comments: Explain "why", not "what"
- Use `lib.mkIf` and `lib.mkMerge` for conditional config

**Python:**
- PEP 8 compliance via black formatter
- Type hints required for all functions
- Async/await for I/O operations (Graphiti, Redis, B2)
- Docstrings: Google style
- Error handling: Explicit try-except, never bare except

**TypeScript:**
- ESLint + Prettier
- Strict mode enabled
- Async functions return Promise<T>
- Use const over let, never var
- Destructuring for object parameters

**Bash:**
- ShellCheck compliant
- Set: -euo pipefail (fail on error, undefined vars, pipe failures)
- Use long flags for readability (--verbose not -v)
- Quote all variables: "${var}"

### Architecture Patterns

**Impermanence:**
- Root filesystem wiped on every boot
- Persistent data explicitly declared in /persist
- Old roots kept for 30 days for rollback
- Benefits: Clean state, no cruft accumulation

**Container Pod Architecture:**
- Single Podman pod with shared localhost networking
- Containers communicate via localhost (no IP management)
- Systemd manages pod lifecycle (not docker-compose)
- Secrets injected via systemd EnvironmentFile

**Event-Driven Memory:**
- OpenCode plugin hooks into lifecycle events (file:write, chat:start, error, completion)
- Automatic episode creation on events
- No manual memory management required
- Cache-first query strategy (Valkey → Graphiti)

**Declarative Infrastructure:**
- All config in Git (NixOS flakes)
- No manual server configuration
- Reproducible builds (same config = same system)
- Rollback via nix-env generations or Btrfs snapshots

### Testing Strategy

**NixOS Configuration:**
- Test build: `nix flake check`
- VM test: `nixos-rebuild build-vm --flake .#hetzner-vps`
- Dry run: `nixos-rebuild dry-activate`
- Actual deploy: `nixos-rebuild switch --flake .#hetzner-vps`

**Container Images:**
- Build test: `podman build -t opencode-server:test .`
- Run test: `podman run --rm opencode-server:test opencode --version`
- Health check validation in systemd service

**Python Code:**
- Unit tests: pytest (memory_manager.py functions)
- Mock external services (FalkorDB, Valkey, B2)
- Integration test: full memory store → query → export flow

**OpenCode Plugin:**
- Manual test: Start OpenCode, trigger events, verify memory updates
- Log inspection: Check plugin loads and responds to events

**Acceptance Criteria:**
- All services start successfully after rebuild
- Health checks pass
- OpenCode attach connects from remote machine
- Memory queries return relevant context
- Backups complete successfully
- Dashboard accessible via Tailscale

### Git Workflow

**Branching Strategy:**
- `main`: Stable, deployed to production
- `develop`: Integration branch for features
- `feature/<name>`: Individual features
- `fix/<name>`: Bug fixes

**Commit Conventions:**
- Format: `type(scope): subject`
- Types: feat, fix, docs, style, refactor, test, chore
- Examples:
  - `feat(disko): add btrfs subvolume layout`
  - `fix(caddy): correct tailscale ip filtering`
  - `docs(readme): add installation instructions`

**OpenSpec Integration:**
- Proposals in `openspec/proposals/`
- Changes in `openspec/changes/`
- Tasks in `tasks.md` (updated by OpenSpec)
- Archive completed work in `openspec/archive/`

**Deployment:**
- Push to main triggers documentation update
- SSH to server, git pull, nixos-rebuild switch
- Create snapshot before major changes

## Domain Context

### NixOS Ecosystem
- **Flakes**: Experimental feature for reproducible, composable configurations
- **Home Manager**: User environment management (not used in server config)
- **Disko**: Declarative disk partitioning (critical for initial install)
- **Impermanence**: Module for ephemeral root filesystem
- **nixpkgs**: ~80,000 packages, updated continuously

### Memory System Architecture
- **Graphiti**: Temporal knowledge graph (tracks entity changes over time)
- **Episodes**: Units of information added to memory (user actions, errors, completions)
- **Entities**: Extracted concepts (files, functions, people, preferences)
- **Relationships**: Connections between entities with temporal validity
- **Search**: Vector similarity + graph traversal for context retrieval

### OpenCode Behavior
- **Server mode**: `opencode serve` runs persistent server
- **Client mode**: `opencode --attach <url>` connects to remote server
- **Plugins**: TypeScript modules with event hooks
- **Tools**: Custom functions LLM can call
- **MCP**: Model Context Protocol (avoid due to token overhead)

### Tailscale Security Model
- **Tailnet**: Private VPN network (100.64.0.0/10 CGNAT range)
- **ACLs**: Define which machines can access which services
- **MagicDNS**: Automatic DNS for machine names
- **No exposed ports**: All access via VPN tunnel

### Btrfs Features
- **COW**: Copy-on-write (snapshots are instant, space-efficient)
- **Compression**: Transparent zstd compression (30-40% space savings)
- **Subvolumes**: Separate filesystems within partition (like LVM but better)
- **Snapshots**: Read-only point-in-time copies (fast rollback)
- **nodatacow**: Disable COW for databases (better performance)

## Important Constraints

### Technical Constraints
- **RAM Allocation**: Reserve 8GB for containers, 16GB for system, 8GB for cache
- **Disk I/O**: NVMe provides ~4GB/s, but limit container writes to extend SSD life
- **Network**: Hetzner provides 20TB traffic/month, sufficient for B2 backups
- **Boot Time**: Impermanence adds ~5-10s to boot (root subvolume rotation)

### Operational Constraints
- **Secrets**: Never commit secrets to Git (use OpNix + 1Password)
- **State**: Only /persist survives reboots (document all persistent paths)
- **Networking**: Services on localhost only (except Caddy reverse proxy)
- **Updates**: NixOS updates may break config (test in VM first)

### Security Constraints
- **SSH**: Key-only authentication, no password login
- **Firewall**: Default deny, explicit allow per service
- **Tailscale**: All management interfaces require VPN connection
- **TLS**: Caddy enforces HTTPS with automatic cert renewal
- **Container Isolation**: Podman rootless where possible

### Budget Constraints
- **Hetzner CPX52**: ~$50/month
- **Backblaze B2**: $0.005/GB/month storage (est. $5-10/month)
- **Cloudflare**: Free tier (proxy + DNS)
- **Datadog**: Trial or free tier (100GB logs, 5 hosts)
- **1Password**: $7.99/month (personal) or $19.95/month (team)
- **Total**: ~$75-100/month

## External Dependencies

### Cloud Services
- **Hetzner Cloud API**: Server provisioning, ISO mounting
  - API token required for automation
  - Rate limit: 3600 requests/hour
  
- **Cloudflare API**: DNS management, proxy configuration
  - Zone:DNS:Edit permission required
  - Rate limit: 1200 requests/5min

- **Backblaze B2**: Object storage for backups
  - Endpoint: s3.us-west-004.backblazeb2.com
  - S3-compatible API
  - 10GB free, then $0.005/GB/month

- **Datadog**: Observability platform
  - Agent runs in container
  - APM, logs, metrics, LLM observability
  - API key from account settings

### SaaS Dependencies
- **1Password**: Secret management
  - Service account token (read-only)
  - Vault: "Infrastructure Secrets"
  - Item format: op://vault/item/field

- **OpenAI API**: LLM for Graphiti embeddings
  - Model: text-embedding-3-small
  - Cost: $0.0001/1K tokens
  - Rate limit: 3000 requests/min

- **Tailscale**: VPN networking
  - Auth key for device enrollment
  - ACLs managed in Tailscale admin console
  - Free for personal use (up to 100 devices)

### Package Dependencies
- **Nix Flake Inputs**:
  - nixpkgs: github:NixOS/nixpkgs/nixos-25.05
  - disko: github:nix-community/disko
  - opnix: github:brizzbuzz/opnix
  - impermanence: github:nix-community/impermanence

- **Python Packages**:
  - graphiti-core[falkordb] ~0.3.0
  - falkordb ~1.0.0
  - redis ~5.0.0
  - ddtrace ~2.0.0
  - b2sdk ~2.0.0

- **NPM Packages**:
  - opencode (global install)
  - @opencode-ai/plugin ~1.0.0
  - redis ~4.6.0

- **Container Images**:
  - node:20-slim (base for OpenCode)
  - valkey/valkey:7.2
  - falkordb/falkordb:latest
  - datadog/agent:latest

### System Integration Points
- **Podman Socket**: /var/run/podman/podman.sock (Datadog monitoring)
- **Systemd Units**: All services managed via systemd (journald logs)
- **Kernel Features**: FUSE for Btrfs, WireGuard for Tailscale
- **DNS Resolution**: systemd-resolved with Tailscale MagicDNS
