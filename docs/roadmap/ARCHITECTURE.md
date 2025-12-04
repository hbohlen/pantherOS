# PantherOS System Architecture

> **Last Updated:** 2025-12-04  
> **Status:** Living Document  
> **Purpose:** Comprehensive architectural overview of the PantherOS project

## Table of Contents

1. [System Overview](#system-overview)
2. [Component Architecture](#component-architecture)
3. [Data Flow](#data-flow)
4. [Infrastructure Layout](#infrastructure-layout)
5. [Security Architecture](#security-architecture)
6. [Development Workflow](#development-workflow)

---

## System Overview

PantherOS is a multi-host NixOS configuration system managing both server and personal device infrastructure through declarative configuration.

```mermaid
C4Context
    title System Context Diagram - PantherOS

    Person(admin, "System Administrator", "Manages infrastructure")
    Person(dev, "Developer", "Uses personal devices")
    
    System(pantheros, "PantherOS", "NixOS Configuration System")
    
    System_Ext(github, "GitHub", "Source control and CI/CD")
    System_Ext(onepass, "1Password", "Secrets management")
    System_Ext(cloudflare, "Cloudflare", "DNS and CDN")
    System_Ext(b2, "Backblaze B2", "Object storage")
    System_Ext(tailscale, "Tailscale", "VPN mesh network")
    
    Rel(admin, pantheros, "Configures", "Git")
    Rel(dev, pantheros, "Uses", "SSH/Desktop")
    Rel(pantheros, github, "Builds/Deploys", "CI/CD")
    Rel(pantheros, onepass, "Retrieves secrets", "OpNix")
    Rel(pantheros, cloudflare, "DNS resolution")
    Rel(pantheros, b2, "Stores cache", "S3 API")
    Rel(pantheros, tailscale, "Mesh networking")
```

### Key Characteristics

- **Declarative**: All configuration in Nix language
- **Reproducible**: Identical builds from same inputs
- **Multi-Host**: Manages 5 hosts (3 servers + 2 laptops)
- **Automated**: CI/CD for testing and deployment
- **Secure**: Centralized secrets management

---

## Component Architecture

### Layer Architecture

```mermaid
graph TB
    subgraph "Configuration Layer"
        Flake[flake.nix<br/>Orchestration]
        Specs[OpenSpec<br/>Requirements]
        Modules[Reusable Modules]
    end
    
    subgraph "Host Layer"
        direction LR
        Hetzner[Hetzner VPS]
        OVH[OVH VPS]
        Contabo[Contabo VPS]
        Zephyrus[Zephyrus Laptop]
        Yoga[Yoga Laptop]
    end
    
    subgraph "Service Layer"
        Secrets[Secrets: OpNix + 1Password]
        Network[Network: Tailscale Mesh]
        Cache[Cache: Attic + Cachix]
        CICD[CI/CD: GitLab/GitHub Actions]
    end
    
    subgraph "Infrastructure Layer"
        DNS[DNS: Cloudflare]
        Storage[Storage: Backblaze B2]
        Container[Containers: Podman]
    end
    
    Flake --> Modules
    Specs --> Flake
    Modules --> Hetzner
    Modules --> OVH
    Modules --> Contabo
    Modules --> Zephyrus
    Modules --> Yoga
    
    Hetzner --> Secrets
    OVH --> Secrets
    Contabo --> Secrets
    Zephyrus --> Secrets
    Yoga --> Secrets
    
    Hetzner --> Network
    OVH --> Network
    Contabo --> Network
    Zephyrus --> Network
    Yoga --> Network
    
    CICD --> Cache
    Cache --> Storage
    CICD --> DNS
```

### Module Structure

```mermaid
graph LR
    subgraph "Core Modules"
        Users[User Management]
        Env[Environment Variables]
        Pkgs[System Packages]
    end
    
    subgraph "Service Modules"
        SSH[SSH Hardening]
        Net[Networking]
        Secrets[Secrets Management]
        Containers[Container Runtime]
    end
    
    subgraph "Desktop Modules"
        Shell[Fish Shell]
        Editor[Neovim/Zed]
        Terminal[Ghostty]
        WM[DankMaterialShell]
    end
    
    subgraph "Development Modules"
        DevEnv[Dev Environment]
        Git[Git Config]
        AI[AI Tools]
    end
    
    Users --> Shell
    Env --> DevEnv
    SSH --> Net
    Net --> Secrets
    Shell --> Terminal
    Terminal --> WM
```

---

## Data Flow

### Configuration Build Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as Git Repository
    participant CI as CI/CD Pipeline
    participant Cache as Attic Cache
    participant Host as Target Host
    
    Dev->>Git: Push changes
    Git->>CI: Trigger build
    CI->>CI: nix flake check
    CI->>CI: nix build configurations
    CI->>Cache: Push build artifacts
    CI->>CI: Run tests
    
    alt Tests Pass
        CI->>Host: nixos-rebuild switch
        Host->>Cache: Pull cached artifacts
        Host->>Host: Activate new generation
        Host-->>CI: Deployment success
        CI-->>Dev: Notification
    else Tests Fail
        CI-->>Dev: Build failed
    end
```

### Secrets Management Flow

```mermaid
sequenceDiagram
    participant Host as NixOS Host
    participant OpNix as OpNix Service
    participant OnePass as 1Password
    participant Service as System Service
    
    Host->>Host: Boot/Activation
    Host->>OpNix: Start opnix.service
    OpNix->>OnePass: Authenticate with token
    OnePass-->>OpNix: Session established
    
    loop For each secret
        OpNix->>OnePass: Read secret reference
        OnePass-->>OpNix: Return secret value
        OpNix->>Host: Write to /run/secrets/
    end
    
    OpNix-->>Host: Secrets ready
    Host->>Service: Start dependent services
    Service->>Host: Read from /run/secrets/
```

### Development Workflow

```mermaid
flowchart TB
    Start[Developer Makes Change]
    
    Start --> Branch[Create Feature Branch]
    Branch --> Code[Edit Nix Configs]
    Code --> Local[Test Locally]
    
    Local --> Build{Build OK?}
    Build -->|No| Code
    Build -->|Yes| Commit[Commit Changes]
    
    Commit --> Push[Push to GitHub]
    Push --> CI[CI Pipeline Runs]
    
    CI --> CIBuild[Build All Hosts]
    CIBuild --> CITest[Run Tests]
    CITest --> CICache[Push to Cache]
    
    CICache --> PRCheck{PR Checks Pass?}
    PRCheck -->|No| Code
    PRCheck -->|Yes| Review[Code Review]
    
    Review --> Approved{Approved?}
    Approved -->|No| Code
    Approved -->|Yes| Merge[Merge to Main]
    
    Merge --> Deploy[Manual Deploy Trigger]
    Deploy --> Prod[Deploy to Production]
    Prod --> Done[Complete]
```

---

## Infrastructure Layout

### Network Topology

```mermaid
graph TB
    subgraph "Internet"
        Users[End Users]
        CF[Cloudflare DNS/CDN]
    end
    
    subgraph "Tailscale Mesh VPN"
        subgraph "Server Infrastructure"
            Hetzner[Hetzner VPS<br/>167.235.xxx.xxx<br/>Production]
            OVH[OVH VPS<br/>xxx.xxx.xxx.xxx<br/>Staging]
            Contabo[Contabo VPS<br/>xxx.xxx.xxx.xxx<br/>Staging]
        end
        
        subgraph "Personal Devices"
            Zephyrus[ASUS Zephyrus<br/>Development]
            Yoga[Lenovo Yoga<br/>Development]
        end
        
        subgraph "Shared Services"
            Cache[Attic Cache<br/>cache.hbohlen.systems]
        end
    end
    
    Users --> CF
    CF --> Hetzner
    
    Hetzner <-.-> Tailscale
    OVH <-.-> Tailscale
    Contabo <-.-> Tailscale
    Zephyrus <-.-> Tailscale
    Yoga <-.-> Tailscale
    
    Hetzner --> Cache
    OVH --> Cache
    Contabo --> Cache
    
    Cache -.-> B2[(Backblaze B2)]
    
    Tailscale[Tailscale Control Plane]
    
    style Hetzner fill:#90EE90
    style OVH fill:#FFD700
    style Contabo fill:#FFD700
    style Zephyrus fill:#87CEEB
    style Yoga fill:#87CEEB
```

### Host Specifications

#### Hetzner VPS (Production)
- **Role**: Primary production server
- **Location**: Germany
- **CPU**: 2 vCPU
- **RAM**: 4GB
- **Storage**: 40GB SSD
- **Network**: 20TB traffic
- **Services**: 
  - SSH (port 22)
  - Attic cache server
  - PostgreSQL
  - Caddy reverse proxy
  - Tailscale

#### OVH VPS (Staging)
- **Role**: Staging/testing server
- **Location**: France
- **CPU**: 2 vCPU
- **RAM**: 4GB
- **Storage**: 40GB SSD
- **Services**: Mirror of production

#### Contabo VPS (Staging)
- **Role**: Secondary staging server
- **Location**: Germany
- **CPU**: 4 vCPU
- **RAM**: 8GB
- **Storage**: 200GB SSD
- **Services**: To be defined

#### ASUS ROG Zephyrus (Development)
- **Role**: Primary development laptop
- **CPU**: AMD Ryzen (TBD)
- **RAM**: 16GB+
- **Storage**: 2TB NVMe (Crucial P310 Plus) + default SSD
- **GPU**: NVIDIA (likely)
- **Desktop**: DankMaterialShell + Niri
- **Filesystem**: BTRFS with subvolumes

#### Lenovo Yoga (Development)
- **Role**: Secondary development laptop
- **CPU**: AMD Ryzen AI 7 350 (8 cores/16 threads)
- **RAM**: 16GB
- **Storage**: 2 disks detected
- **Network**: 2 interfaces
- **Desktop**: DankMaterialShell + Niri
- **Filesystem**: BTRFS with subvolumes

---

## Security Architecture

### Defense in Depth

```mermaid
graph TB
    subgraph "Layer 1: Network Security"
        Firewall[Firewall Rules<br/>SSH + Tailscale Only]
        Tailscale[Encrypted Mesh<br/>Zero Trust Network]
        SSH[SSH Hardening<br/>Key-Only Auth]
    end
    
    subgraph "Layer 2: Access Control"
        Auth[1Password OpNix<br/>Centralized Secrets]
        Tokens[Service Tokens<br/>Scoped Permissions]
        Sudo[Sudo Configuration<br/>Minimal Privileges]
    end
    
    subgraph "Layer 3: System Security"
        Updates[Regular Updates<br/>nixos-unstable]
        Containers[Container Isolation<br/>Podman Rootless]
        Files[File Permissions<br/>Principle of Least Privilege]
    end
    
    subgraph "Layer 4: Application Security"
        HTTPS[HTTPS Everywhere<br/>Let's Encrypt]
        SecHeaders[Security Headers<br/>HSTS, CSP]
        Validation[Input Validation<br/>Sanitization]
    end
    
    Internet[Internet] --> Firewall
    Firewall --> Tailscale
    Tailscale --> SSH
    SSH --> Auth
    Auth --> Tokens
    Tokens --> Sudo
    Sudo --> Updates
    Updates --> Containers
    Containers --> Files
    Files --> HTTPS
    HTTPS --> SecHeaders
    SecHeaders --> Validation
```

### Secrets Management

```mermaid
graph LR
    subgraph "1Password Vault"
        Vault[pantherOS Vault]
        Vault --> SSHKeys[SSH Keys]
        Vault --> APITokens[API Tokens]
        Vault --> ServiceCreds[Service Credentials]
    end
    
    subgraph "OpNix Service"
        OpNix[OpNix Daemon]
        OpNix --> SecretRefs[Secret References in Nix]
    end
    
    subgraph "Runtime Secrets"
        RunSecrets[/run/secrets/]
        RunSecrets --> TailscaleKey[tailscale-auth-key]
        RunSecrets --> AtticToken[attic-token]
        RunSecrets --> B2Creds[b2-credentials]
    end
    
    Vault --> OpNix
    OpNix --> RunSecrets
    
    Services[System Services] --> RunSecrets
```

### SSH Hardening

- **Authentication**: Public key only, no passwords
- **Root Login**: Disabled for direct access
- **Port**: Standard 22 (behind firewall)
- **Ciphers**: Modern algorithms only
- **Failed Attempts**: Rate limiting enabled
- **Tailscale**: Preferred access method

---

## Development Workflow

### Local Development

```mermaid
flowchart LR
    subgraph "Developer Machine"
        Editor[Zed/Neovim<br/>Code Editor]
        Terminal[Ghostty<br/>Terminal]
        Shell[Fish Shell<br/>+ Tools]
    end
    
    subgraph "Development Tools"
        Nix[Nix CLI<br/>Build System]
        Git[Git<br/>Version Control]
        AI[OpenCode AI<br/>AI Assistant]
    end
    
    subgraph "Testing"
        FlakeCheck[nix flake check<br/>Validation]
        Build[nix build<br/>Test Build]
        VM[nixos-rebuild build-vm<br/>VM Testing]
    end
    
    Editor --> Git
    Terminal --> Shell
    Shell --> Nix
    Shell --> Git
    Shell --> AI
    
    Git --> FlakeCheck
    Nix --> Build
    Build --> VM
```

### CI/CD Pipeline Architecture

```mermaid
graph TB
    subgraph "Source Control"
        GH[GitHub Repository]
    end
    
    subgraph "CI Platform"
        GL[GitLab CI]
        Container[NixOS CI Container]
    end
    
    subgraph "Build Infrastructure"
        Builder[Nix Builder]
        Cache[Attic Cache]
        Registry[Container Registry]
    end
    
    subgraph "Deployment Targets"
        Prod[Production Servers]
        Stage[Staging Servers]
    end
    
    GH --> GL
    GL --> Container
    Container --> Builder
    Builder <--> Cache
    Container --> Registry
    
    Builder --> Stage
    Stage --> Prod
    
    Cache <--> B2[(Backblaze B2<br/>Object Storage)]
```

### Release Process

```mermaid
stateDiagram-v2
    [*] --> Development
    Development --> Testing: Feature Complete
    Testing --> Staging: Tests Pass
    Staging --> Review: Staging Validated
    Review --> Production: Approved
    Production --> [*]: Deployed
    
    Testing --> Development: Tests Fail
    Staging --> Development: Issues Found
    Review --> Development: Changes Requested
    Production --> Development: Hotfix Needed
    
    note right of Development
        Feature branches
        Local testing
        OpenSpec proposals
    end note
    
    note right of Testing
        CI/CD builds
        Automated tests
        Flake validation
    end note
    
    note right of Staging
        Deploy to OVH/Contabo
        Integration testing
        Performance validation
    end note
    
    note right of Review
        Code review
        Security review
        Documentation check
    end note
    
    note right of Production
        Hetzner VPS
        Health monitoring
        Rollback capability
    end note
```

---

## Technology Stack

### Core Technologies

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **OS** | NixOS | Declarative Linux distribution |
| **Package Manager** | Nix | Reproducible package management |
| **Config Language** | Nix Language | System configuration DSL |
| **User Config** | Home Manager | Declarative user environment |
| **Secrets** | OpNix + 1Password | Centralized secrets management |

### Infrastructure Technologies

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **VPN** | Tailscale | Mesh VPN network |
| **DNS** | Cloudflare | DNS and CDN |
| **Cache** | Attic | Binary artifact cache |
| **Storage** | Backblaze B2 | Object storage (S3-compatible) |
| **CI/CD** | GitLab CI / GitHub Actions | Build and deployment |
| **Containers** | Podman | Rootless container runtime |
| **Database** | PostgreSQL | Relational database |
| **Proxy** | Caddy | Reverse proxy with auto-HTTPS |

### Desktop Technologies

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Compositor** | Niri | Scrollable tiling compositor |
| **Desktop Shell** | DankMaterialShell | Material Design desktop environment |
| **UI Framework** | Quickshell | QML-based shell framework |
| **Terminal** | Ghostty | Modern GPU-accelerated terminal |
| **Shell** | Fish | User-friendly command shell |
| **Editor** | Neovim + Zed | Code editors |
| **Theming** | Matugen | Material Design color generation |

### Development Tools

| Tool | Purpose |
|------|---------|
| **fzf** | Fuzzy finder |
| **eza** | Modern ls replacement |
| **ripgrep** | Fast text search |
| **fd** | Fast file finder |
| **bat** | Cat with syntax highlighting |
| **git** | Version control |
| **direnv** | Environment management |
| **OpenCode AI** | AI coding assistant |

---

## Filesystem Architecture

### BTRFS Subvolume Layout

```mermaid
graph TB
    Root[/ Root Subvolume]
    
    Root --> Nix[/nix<br/>Nix Store<br/>CoW disabled]
    Root --> Containers[/var/lib/containers<br/>Podman Storage<br/>CoW disabled]
    Root --> Dev[~/dev<br/>Development Workspace]
    Root --> Var[/var<br/>System Variables]
    Root --> VarLog[/var/log<br/>System Logs]
    Root --> VarCache[/var/cache<br/>System Cache]
    
    Nix --> NixStore[immutable packages]
    Containers --> Images[container images]
    Containers --> Volumes[container volumes]
    Dev --> Projects[project directories]
```

### Mount Options by Use Case

| Subvolume | Mount Options | Reasoning |
|-----------|---------------|-----------|
| `/nix` | `noatime,nodatacow,compress=none` | Nix store is already compressed, no CoW needed |
| `/var/lib/containers` | `noatime,nodatacow` | Container images don't benefit from CoW |
| `~/dev` | `noatime,compress=zstd:3` | Balance compression and performance |
| `/var/log` | `noatime,compress=zstd:6` | Logs compress well, read-heavy |
| `/var/cache` | `noatime,compress=zstd:1` | Fast access priority |

---

## Scalability Considerations

### Horizontal Scaling

```mermaid
graph LR
    subgraph "Current State - 5 Hosts"
        H1[Hetzner]
        H2[OVH]
        H3[Contabo]
        H4[Zephyrus]
        H5[Yoga]
    end
    
    subgraph "Future State - N Hosts"
        H1F[Production<br/>Server Farm]
        H2F[Staging<br/>Environment]
        H3F[Development<br/>Workstations]
        H4F[Edge<br/>Locations]
    end
    
    H1 -.-> H1F
    H2 -.-> H1F
    H3 -.-> H2F
    H4 -.-> H3F
    H5 -.-> H3F
```

### Module Extensibility

New hosts can be added by:
1. Creating host configuration in `hosts/`
2. Running hardware detection with facter
3. Importing shared modules
4. Adding to `flake.nix` outputs
5. CI/CD automatically picks up new host

### Cache Scaling

- **Current**: Single Attic instance
- **Future**: Multi-region cache replication
- **CDN**: Cloudflare caching layer
- **Local**: Developer machine caches

---

## Monitoring and Observability

### Metrics to Track

```mermaid
graph TB
    subgraph "System Metrics"
        CPU[CPU Usage]
        RAM[Memory Usage]
        Disk[Disk I/O]
        Net[Network Traffic]
    end
    
    subgraph "Application Metrics"
        BuildTime[Build Times]
        CacheHit[Cache Hit Rate]
        DeployTime[Deployment Duration]
        TestPass[Test Pass Rate]
    end
    
    subgraph "Business Metrics"
        Uptime[System Uptime]
        Incidents[Incident Count]
        MTTR[Mean Time to Recovery]
    end
    
    CPU --> Dashboard[Monitoring Dashboard]
    RAM --> Dashboard
    Disk --> Dashboard
    Net --> Dashboard
    BuildTime --> Dashboard
    CacheHit --> Dashboard
    DeployTime --> Dashboard
    TestPass --> Dashboard
    Uptime --> Dashboard
    Incidents --> Dashboard
    MTTR --> Dashboard
```

### Future Monitoring Stack
- **Metrics**: Prometheus
- **Logging**: Loki
- **Visualization**: Grafana
- **Alerting**: AlertManager
- **Tracing**: Tempo (if needed)

---

## Disaster Recovery

### Backup Strategy

```mermaid
graph TB
    subgraph "Configuration Backup"
        Git[Git Repository<br/>GitHub]
        Config[Nix Configurations<br/>Versioned]
    end
    
    subgraph "Data Backup"
        PG[PostgreSQL<br/>Daily Dumps]
        Secrets[1Password<br/>Cloud Vault]
        UserData[User Data<br/>Manual Backup]
    end
    
    subgraph "Infrastructure Backup"
        Snapshots[VPS Snapshots<br/>Provider Tools]
        Cache[Attic Cache<br/>Backblaze B2]
    end
    
    Git --> GitHub[(GitHub)]
    PG --> B2[(Backblaze B2)]
    Secrets --> OnePass[(1Password Cloud)]
    Snapshots --> Provider[(Cloud Provider)]
```

### Recovery Procedures

1. **Configuration Corruption**: Roll back to previous git commit
2. **Host Failure**: Deploy to new VPS from scratch using nixos-anywhere
3. **Data Loss**: Restore from PostgreSQL backups
4. **Cache Loss**: Rebuild from source (slower but functional)
5. **Secrets Compromise**: Rotate credentials in 1Password, redeploy

### RTO/RPO Targets

| Scenario | RTO (Recovery Time) | RPO (Data Loss) |
|----------|--------------------|--------------------|
| Configuration issue | 10 minutes | 0 (git rollback) |
| Host failure | 1 hour | 0 (stateless servers) |
| Database corruption | 2 hours | 24 hours (daily backup) |
| Cache corruption | 4 hours | 0 (rebuild from source) |
| Complete disaster | 8 hours | 24 hours |

---

## Future Architecture Evolution

### Planned Enhancements

1. **Multi-Region Deployment**
   - Additional VPS providers
   - Geographic distribution
   - Failover capabilities

2. **Advanced Monitoring**
   - Prometheus + Grafana stack
   - Custom dashboards
   - Automated alerting

3. **Enhanced Security**
   - Age-encrypted secrets (migrate from OpNix)
   - Hardware security keys
   - Audit logging

4. **Performance Optimization**
   - CDN for static assets
   - Database replication
   - Advanced BTRFS tuning

5. **Developer Experience**
   - IDE configurations
   - Development containers
   - Pre-commit hooks

---

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [BTRFS Documentation](https://btrfs.readthedocs.io/)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [Attic Documentation](https://github.com/zhaofengli/attic)

---

**Document Maintenance:**
- Review quarterly or after major architectural changes
- Update diagrams when components added/removed
- Keep technology stack table current
- Validate all links and references

**Contributors:**
- System Architecture: GitHub Copilot Agent
- Last Major Revision: 2025-12-04
