# Architecture Diagrams & System Visualizations

**Purpose**: Visual representations of pantherOS and OpenCode+AgentDB architectures  
**Format**: Mermaid diagrams optimized for AI agent understanding  
**Version**: 1.0  
**Last Updated**: 2025-11-15

---

## Table of Contents

1. [System Overview](#system-overview)
2. [pantherOS Layer Architecture](#pantheros-layer-architecture)
3. [Secrets Management Flow](#secrets-management-flow)
4. [OpenCode+AgentDB Data Flow](#opencode-agentdb-data-flow)
5. [Service Integration](#service-integration)
6. [Desktop Environment Stack](#desktop-environment-stack)
7. [Build and Deployment Pipeline](#build-and-deployment-pipeline)

---

## System Overview

### Complete Infrastructure Topology

```mermaid
graph TB
    subgraph "User Devices"
        PHONE[Phone<br/>Termux SSH]
        LAPTOP[Laptop<br/>yoga/zephyrus]
        DESKTOP[Desktop<br/>pantherOS]
    end
    
    subgraph "Tailscale Private Network"
        TS[Tailscale Mesh VPN<br/>100.x.x.x addresses]
    end
    
    subgraph "VPS Infrastructure"
        VPS1[OVH Cloud VPS<br/>NixOS 25.05]
        VPS2[Hetzner VPS<br/>Future expansion]
    end
    
    subgraph "External Services"
        OP[1Password<br/>Secret Vault]
        DD[Datadog<br/>Monitoring]
        B2[Backblaze B2<br/>Binary Cache]
        GH[GitHub<br/>Source Code]
    end
    
    subgraph "VPS Services"
        OC[OpenCode Agent]
        ADB[AgentDB]
        PG[PostgreSQL]
        ATTIC[Attic Cache]
        DDA[Datadog Agent]
    end
    
    PHONE --> TS
    LAPTOP --> TS
    DESKTOP --> TS
    TS --> VPS1
    TS --> VPS2
    
    VPS1 --> OP
    VPS1 --> DD
    VPS1 --> B2
    VPS1 --> GH
    
    VPS1 --> OC
    VPS1 --> ADB
    VPS1 --> PG
    VPS1 --> ATTIC
    VPS1 --> DDA
    
    OC --> ADB
    ADB --> PG
    DDA --> DD
    ATTIC --> B2
    
    LAPTOP --> ATTIC
    DESKTOP --> ATTIC
```

---

## pantherOS Layer Architecture

### Module Organization Hierarchy

```mermaid
graph LR
    subgraph "Layer 1: Modules<br/>(Atomic Components)"
        BASE[base/]
        APPS[apps/]
        SVCS[services/]
        HW[hardware/]
        NET[networking/]
        CONT[containers/]
    end
    
    subgraph "Layer 2: Profiles<br/>(Composed Configs)"
        WS[workstation/<br/>gui.nix<br/>devtools.nix]
        SRV[server/<br/>base.nix<br/>observability.nix]
        COM[common/<br/>time-locale.nix<br/>ssd-trim.nix]
    end
    
    subgraph "Layer 3: Hosts<br/>(Final Configs)"
        YOGA[yoga]
        ZEPH[zephyrus]
        DESK[desktop]
        OVH[servers/ovh-cloud-vps]
    end
    
    BASE --> WS
    APPS --> WS
    HW --> WS
    NET --> WS
    CONT --> WS
    
    SVCS --> WS
    SVCS --> SRV
    
    HW --> SRV
    NET --> SRV
    
    COM --> YOGA
    COM --> ZEPH
    COM --> DESK
    COM --> OVH
    
    WS --> YOGA
    WS --> ZEPH
    WS --> DESK
    
    SRV --> OVH
    
    style BASE fill:#e1f5ff
    style APPS fill:#e1f5ff
    style SVCS fill:#e1f5ff
    style HW fill:#e1f5ff
    style NET fill:#e1f5ff
    style CONT fill:#e1f5ff
    
    style WS fill:#fff4e1
    style SRV fill:#fff4e1
    style COM fill:#fff4e1
    
    style YOGA fill:#e8f5e9
    style ZEPH fill:#e8f5e9
    style DESK fill:#e8f5e9
    style OVH fill:#e8f5e9
```

### Flake Structure and Build Process

```mermaid
graph TD
    FLAKE[flake.nix<br/>inputs + outputs]
    
    subgraph "Inputs"
        NPK[nixpkgs 25.05]
        HM[home-manager]
        DISKO[disko]
        OPNIX[opnix]
        NIRI[niri-flake]
        DMS[dankMaterialShell]
    end
    
    subgraph "Helpers"
        LIB[lib/mkSystem.nix<br/>lib/mkHome.nix]
    end
    
    subgraph "Outputs"
        NIXOS[nixosConfigurations<br/>yoga, zephyrus, desktop, ovh]
        HOME[homeConfigurations<br/>hayden@yoga]
        DEV[devShells<br/>default]
    end
    
    FLAKE --> NPK
    FLAKE --> HM
    FLAKE --> DISKO
    FLAKE --> OPNIX
    FLAKE --> NIRI
    FLAKE --> DMS
    
    FLAKE --> LIB
    
    LIB --> NIXOS
    LIB --> HOME
    FLAKE --> DEV
    
    NIXOS --> BUILD[System Build<br/>activationScript]
    HOME --> HMBUILD[HM Build<br/>homeActivation]
    
    BUILD --> SWITCH[nixos-rebuild switch]
    HMBUILD --> HMSWITCH[home-manager switch]
```

---

## Secrets Management Flow

### OpNix Secret Materialization Process

```mermaid
sequenceDiagram
    participant User
    participant OpNix
    participant 1Pass as 1Password Vault
    participant Systemd
    participant Service
    
    User->>OpNix: sudo opnix token set
    OpNix->>OpNix: Store token in /etc/opnix-token
    
    Note over User,Service: System Rebuild
    
    User->>Systemd: nixos-rebuild switch
    Systemd->>OpNix: Start opnix-secrets.service
    OpNix->>OpNix: Read /etc/opnix-token
    OpNix->>1Pass: Authenticate with service account
    1Pass-->>OpNix: Token valid
    
    loop For each secret
        OpNix->>1Pass: Read op://pantherOS/service/field
        1Pass-->>OpNix: Secret value
        OpNix->>OpNix: Write to /var/lib/opnix/secrets/secretName
        OpNix->>OpNix: Set permissions (owner:group, mode)
    end
    
    OpNix->>Systemd: Secrets ready
    Systemd->>Service: Start service (After=opnix-secrets.service)
    Service->>Service: Read secret from file
    Service-->>User: Service running with secrets
```

### Secret File Layout

```mermaid
graph TD
    ROOT[/var/lib/opnix/secrets/]
    
    subgraph "NixOS System Secrets"
        TS[tailscale/<br/>tailscaleAuthKey]
        DD_S[datadog/<br/>datadogApiKey<br/>datadogAppKey]
        AT[attic/<br/>b2KeyId<br/>b2AppKey]
        GH[github/<br/>githubPat]
    end
    
    subgraph "User Secrets (Home Manager)"
        SSH[~/.ssh/<br/>id_ed25519<br/>yoga<br/>zephyrus<br/>desktop]
        CONF[~/.config/<br/>github/pat<br/>...other tokens]
    end
    
    ROOT --> TS
    ROOT --> DD_S
    ROOT --> AT
    ROOT --> GH
    
    HM[Home Manager<br/>Activation] --> SSH
    HM --> CONF
    
    style ROOT fill:#fff4e1
    style TS fill:#e1f5ff
    style DD_S fill:#e1f5ff
    style AT fill:#e1f5ff
    style GH fill:#e1f5ff
    style SSH fill:#e8f5e9
    style CONF fill:#e8f5e9
```

---

## OpenCode+AgentDB Data Flow

### Agent Knowledge Lifecycle

```mermaid
graph TB
    subgraph "Documentation Sources"
        DOCS1[GitHub Repos<br/>API Docs]
        DOCS2[Internal Wikis<br/>Confluence]
        DOCS3[Technical Blogs<br/>Medium, Dev.to]
    end
    
    subgraph "Crawl & Process"
        C4AI[Crawl4ai<br/>Async Scraper]
        NORM[Markdown<br/>Normalization]
    end
    
    subgraph "Storage"
        ADB[AgentDB<br/>Vector Database]
        PG[PostgreSQL<br/>Structured Data]
    end
    
    subgraph "Agent Runtime"
        USER[User Query<br/>via SSH/Web]
        OC[OpenCode SDK]
        ENRICH[Prompt Enrichment]
        LLM[LLM<br/>Claude/GPT]
        SUBA[Sub-agents<br/>Parallel Tasks]
    end
    
    subgraph "Scheduling"
        CRON[Systemd Timer<br/>Daily 2AM]
    end
    
    DOCS1 --> C4AI
    DOCS2 --> C4AI
    DOCS3 --> C4AI
    
    C4AI --> NORM
    NORM --> ADB
    NORM --> PG
    
    CRON --> C4AI
    
    USER --> OC
    OC --> ADB
    ADB --> ENRICH
    ENRICH --> LLM
    LLM --> OC
    OC --> SUBA
    SUBA --> ADB
    SUBA --> OC
    OC --> USER
    
    style C4AI fill:#e1f5ff
    style ADB fill:#fff4e1
    style OC fill:#e8f5e9
    style SUBA fill:#e8f5e9
```

### OpenCode Agent Phases

```mermaid
graph LR
    P1[Phase 1<br/>Local MVP<br/>5-10 hours]
    P2[Phase 2<br/>VPS Deploy<br/>2-3 days]
    P3[Phase 3<br/>Persistent Services<br/>2-3 days]
    P4[Phase 4<br/>Web Interface<br/>2-3 weeks]
    
    P1 -->|crawl4ai<br/>agentdb<br/>local test| P2
    P2 -->|NixOS deploy<br/>systemd services<br/>tailscale| P3
    P3 -->|sub-agents<br/>scheduling<br/>monitoring| P4
    P4 -->|FastAPI<br/>React frontend<br/>mobile access| DONE[Production]
    
    style P1 fill:#e1f5ff
    style P2 fill:#fff4e1
    style P3 fill:#e8f5e9
    style P4 fill:#ffe1e1
    style DONE fill:#c8e6c9
```

---

## Service Integration

### Service Dependency Graph

```mermaid
graph TD
    BOOT[System Boot]
    
    subgraph "Infrastructure Layer"
        NET[network.target]
        NETOL[network-online.target]
        FS[Filesystem Mounts]
    end
    
    subgraph "Secret Management"
        OPNIX[opnix-secrets.service<br/>After: network-online]
    end
    
    subgraph "Core Services"
        TS[tailscale.service<br/>After: opnix-secrets]
        PG[postgresql.service<br/>After: network]
        DD[datadog-agent.service<br/>After: opnix-secrets]
    end
    
    subgraph "Application Services"
        OC_SVC[opencode.service<br/>After: postgresql, opnix-secrets]
        ATTIC[atticpersonal.service<br/>After: opnix-secrets]
    end
    
    BOOT --> FS
    FS --> NET
    NET --> NETOL
    NETOL --> OPNIX
    
    OPNIX --> TS
    OPNIX --> DD
    OPNIX --> ATTIC
    OPNIX --> OC_SVC
    
    NET --> PG
    PG --> OC_SVC
    
    style OPNIX fill:#fff4e1
    style TS fill:#e1f5ff
    style PG fill:#e1f5ff
    style DD fill:#e1f5ff
    style OC_SVC fill:#e8f5e9
    style ATTIC fill:#e8f5e9
```

---

## Desktop Environment Stack

### Niri + DankMaterialShell Architecture

```mermaid
graph TB
    subgraph "Display Server"
        WAYLAND[Wayland Protocol]
    end
    
    subgraph "Compositor Layer"
        NIRI[Niri Compositor<br/>Scrolling Window Manager]
    end
    
    subgraph "Session Management"
        GREETD[greetd Display Manager]
        DMS_GREETER[DankMaterialShell Greeter<br/>Login Screen]
    end
    
    subgraph "Shell Components"
        DMS_SHELL[DankMaterialShell<br/>Quickshell-based]
        BAR[Status Bar]
        NOTIF[Notifications]
        LAUNCHER[App Launcher]
        LOCK[Screen Lock]
    end
    
    subgraph "Supporting Services"
        POLKIT[Polkit Agent<br/>Privilege Escalation]
        PORTAL[XDG Portals<br/>Screen Share, etc]
        PIPE[Pipewire<br/>Audio/Video]
    end
    
    subgraph "Applications"
        BROWSER[Browser<br/>Brave/Zen]
        TERM[Terminal<br/>Alacritty/Kitty]
        APPS[Other Apps]
    end
    
    WAYLAND --> NIRI
    GREETD --> DMS_GREETER
    DMS_GREETER --> NIRI
    
    NIRI --> DMS_SHELL
    DMS_SHELL --> BAR
    DMS_SHELL --> NOTIF
    DMS_SHELL --> LAUNCHER
    DMS_SHELL --> LOCK
    
    NIRI --> POLKIT
    NIRI --> PORTAL
    NIRI --> PIPE
    
    NIRI --> BROWSER
    NIRI --> TERM
    NIRI --> APPS
    
    style NIRI fill:#e1f5ff
    style DMS_GREETER fill:#fff4e1
    style DMS_SHELL fill:#fff4e1
    style POLKIT fill:#e8f5e9
```

---

## Build and Deployment Pipeline

### NixOS Rebuild Workflow

```mermaid
flowchart TD
    START[User runs<br/>nixos-rebuild switch]
    
    EVAL[Evaluate flake.nix<br/>Build configuration.nix]
    FETCH[Fetch dependencies<br/>from binary caches]
    
    subgraph "Build Phase"
        BUILD_CHECK{All builds<br/>successful?}
        BUILD_PKG[Build packages]
        BUILD_SYS[Build system closure]
    end
    
    subgraph "Activation Phase"
        SWITCH_GEN[Switch generation<br/>Update bootloader]
        ACTIVATE[Run activation scripts]
        RESTART_SVCS[Restart changed services]
    end
    
    subgraph "OpNix Phase"
        OPNIX_RUN[opnix-secrets.service]
        FETCH_SECRETS[Fetch from 1Password]
        WRITE_FILES[Write secret files]
    end
    
    SUCCESS[System updated<br/>Services running]
    FAIL[Build failed<br/>Rollback available]
    
    START --> EVAL
    EVAL --> FETCH
    FETCH --> BUILD_PKG
    BUILD_PKG --> BUILD_SYS
    BUILD_SYS --> BUILD_CHECK
    
    BUILD_CHECK -->|Yes| SWITCH_GEN
    BUILD_CHECK -->|No| FAIL
    
    SWITCH_GEN --> ACTIVATE
    ACTIVATE --> OPNIX_RUN
    OPNIX_RUN --> FETCH_SECRETS
    FETCH_SECRETS --> WRITE_FILES
    WRITE_FILES --> RESTART_SVCS
    RESTART_SVCS --> SUCCESS
    
    style BUILD_CHECK fill:#fff4e1
    style SUCCESS fill:#c8e6c9
    style FAIL fill:#ffcdd2
    style OPNIX_RUN fill:#e1f5ff
```

### Multi-Host Deployment Strategy

```mermaid
graph TB
    subgraph "Development"
        DEV[Local Development<br/>Edit Nix files]
        VM[Test in VM<br/>nix build + test]
    end
    
    subgraph "Version Control"
        GIT[Git Repository<br/>GitHub]
        CI[GitHub Actions<br/>nix flake check]
    end
    
    subgraph "Deployment"
        WORKSTATION[Workstations<br/>yoga, zephyrus, desktop]
        SERVER[Servers<br/>ovh-cloud-vps]
    end
    
    DEV --> VM
    VM -->|Tests pass| GIT
    GIT --> CI
    
    CI -->|Build success| WORKSTATION
    CI -->|Build success| SERVER
    
    WORKSTATION -->|Manual| REBUILD_WS[nixos-rebuild switch<br/>--flake .#yoga]
    SERVER -->|SSH + Rebuild| REBUILD_SRV[nixos-rebuild switch<br/>--flake .#ovh-cloud-vps<br/>--target-host ovh]
    
    style VM fill:#e1f5ff
    style CI fill:#fff4e1
    style REBUILD_WS fill:#e8f5e9
    style REBUILD_SRV fill:#e8f5e9
```

---

## Network Topology

### Tailscale Mesh Network

```mermaid
graph TB
    subgraph "Tailscale Control Plane"
        CTRL[Tailscale<br/>Coordination Server]
    end
    
    subgraph "pantherOS Network<br/>100.x.x.x"
        YOGA[yoga<br/>100.64.1.1<br/>Workstation]
        ZEPH[zephyrus<br/>100.64.1.2<br/>Workstation]
        DESK[desktop<br/>100.64.1.3<br/>Workstation]
        OVH[ovh-cloud-vps<br/>100.64.2.1<br/>Server]
        PHONE[phone<br/>100.64.3.1<br/>Mobile]
    end
    
    subgraph "External Access"
        SSH_Y[SSH: yoga<br/>Port 22]
        SSH_O[SSH: ovh<br/>Port 22]
        WEB[Web UI<br/>Port 8080<br/>Phase 4]
    end
    
    CTRL -.Control.-> YOGA
    CTRL -.Control.-> ZEPH
    CTRL -.Control.-> DESK
    CTRL -.Control.-> OVH
    CTRL -.Control.-> PHONE
    
    YOGA <-->|Direct P2P<br/>WireGuard| ZEPH
    YOGA <-->|Direct P2P| DESK
    YOGA <-->|Relay if needed| OVH
    PHONE <-->|Cellular| OVH
    
    PHONE --> SSH_Y
    PHONE --> SSH_O
    PHONE -.Phase 4.-> WEB
    
    OVH --> WEB
    
    style CTRL fill:#e1f5ff
    style OVH fill:#fff4e1
    style WEB fill:#ffe1e1
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-15 | Initial architecture diagrams |

---

**Note for AI Agents**: These diagrams represent the current architecture as of 2025-11-15. Always cross-reference with the latest project brief and implementation guides for up-to-date information.
