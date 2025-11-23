# Hetzner VPS Complete Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a complete, minimal NixOS configuration for the Hetzner Cloud VPS with declarative disk management (Btrfs), Tailscale networking, AI development tools, and 1Password secrets management.

**Architecture:** The Hetzner VPS serves as a personal development server accessible only via Tailscale. It uses Btrfs with optimized subvolumes for different workloads, impermanence-ready design, and minimal attack surface with firewall restricted to the Tailnet.

**Tech Stack:** NixOS, Disko, Btrfs, Tailscale, 1Password CLI, OpNix, Fish shell, nix-ai-tools (opencode, claude-code)

---

## Part 1: disko.nix - Declarative Disk Configuration

### Task 1.1: Create disko.nix with GPT and Boot Partitions

**Files:**
- Create: `hosts/servers/hetzner-cloud/disko.nix`

**Step 1: Create the base disko structure with GPT partitions**

```nix
# hosts/servers/hetzner-cloud/disko.nix
# Declarative disk configuration for Hetzner Cloud VPS
#
# Hardware: 457.8GB SSD (/dev/sda)
# Architecture: GPT with BIOS boot, ESP, and Btrfs root
{ config, lib, ... }:

{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition - Required for GRUB on GPT disks
            # Hetzner Cloud VMs use BIOS boot, not pure UEFI
            bios-boot = {
              size = "1M";
              type = "EF02";  # BIOS boot partition type
              priority = 1;   # First partition on disk
            };

            # EFI System Partition - Boot loader and kernels
            # 512M is sufficient for single-kernel server configuration
            esp = {
              size = "512M";
              type = "EF00";  # EFI System Partition type
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"  # Restrict access to root only
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
              priority = 2;
            };

            # Btrfs root partition - Remaining space (~457GB)
            root = {
              size = "100%";
              type = "8300";  # Linux filesystem type
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];  # Force creation (wipe existing)
                # Subvolumes defined in next task
              };
              priority = 3;
            };
          };
        };
      };
    };
  };
}
```

**Step 2: Verify syntax**

Run: `nix-instantiate --parse hosts/servers/hetzner-cloud/disko.nix`
Expected: No output (successful parse)

**Step 3: Commit base structure**

```bash
git add hosts/servers/hetzner-cloud/disko.nix
git commit -m "feat(hetzner-vps): add disko.nix with GPT boot partitions"
```

---

### Task 1.2: Add Btrfs Subvolumes Configuration

**Files:**
- Modify: `hosts/servers/hetzner-cloud/disko.nix:45-150`

**Step 1: Add subvolumes to the Btrfs partition**

Replace the `content` section of the root partition (starting at line ~45) with:

```nix
            root = {
              size = "100%";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  # ============================================
                  # ROOT SUBVOLUME - System files
                  # ============================================
                  # Purpose: Core system files and configuration
                  # Why: Separating root allows for impermanence (ephemeral root)
                  # and easy system snapshots without including user data
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # HOME SUBVOLUME - User data
                  # ============================================
                  # Purpose: User home directories and dotfiles
                  # Why: Separate snapshots for user data, independent backup
                  # retention from system, and quotas if needed
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # DEV SUBVOLUME - Development projects
                  # ============================================
                  # Purpose: Code repositories and development work
                  # Why: Separate from home for targeted snapshots before
                  # major changes, different compression (code compresses well),
                  # and potential different backup frequency
                  "/home/dev" = {
                    mountpoint = "/home/hbohlen/dev";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # NIX SUBVOLUME - Nix store
                  # ============================================
                  # Purpose: /nix/store and Nix database
                  # Why: Critical for boot, needs to be mounted early,
                  # high read traffic but low writes, compress well
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # VAR SUBVOLUME - Variable data
                  # ============================================
                  # Purpose: /var for service data, state, spool
                  # Why: Separate from root for independent snapshots,
                  # services often have different retention needs
                  "/var" = {
                    mountpoint = "/var";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # LOG SUBVOLUME - System logs
                  # ============================================
                  # Purpose: /var/log for all logging
                  # Why: High write frequency with small sequential writes,
                  # nodatacow improves performance for constant appending,
                  # separate retention from system state
                  "/var/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "noatime"
                      "nodatacow"
                      "nodatasum"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # CACHE SUBVOLUME - Application caches
                  # ============================================
                  # Purpose: /var/cache for package caches, build caches
                  # Why: Can be cleared without data loss, separate from
                  # snapshots (no point backing up caches), good compression
                  "/var/cache" = {
                    mountpoint = "/var/cache";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # CONTAINERS SUBVOLUME - Podman/Docker storage
                  # ============================================
                  # Purpose: Container images, layers, and volumes
                  # Why: nodatacow because container storage does many
                  # random writes (database in container = disaster with COW),
                  # separate for easy cleanup and migration
                  "/var/lib/containers" = {
                    mountpoint = "/var/lib/containers";
                    mountOptions = [
                      "noatime"
                      "nodatacow"
                      "nodatasum"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # SWAP SUBVOLUME - Swapfile location
                  # ============================================
                  # Purpose: Contains the swapfile
                  # Why: Btrfs requires nodatacow for swapfiles,
                  # separate subvolume allows easy swapfile management
                  # without affecting other data
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "4G";
                    mountOptions = [
                      "noatime"
                      "nodatacow"
                      "nodatasum"
                      "ssd"
                      "discard=async"
                    ];
                  };
                };
              };
              priority = 3;
            };
```

**Step 2: Verify full syntax**

Run: `nix-instantiate --parse hosts/servers/hetzner-cloud/disko.nix`
Expected: No output (successful parse)

**Step 3: Commit subvolumes**

```bash
git add hosts/servers/hetzner-cloud/disko.nix
git commit -m "feat(hetzner-vps): add Btrfs subvolumes with optimized mount options

Subvolumes:
- /root: System files (compressed)
- /home: User data (compressed)
- /home/dev: Development projects (compressed)
- /nix: Nix store (compressed)
- /var: Service state (compressed)
- /var/log: Logs (nodatacow for write performance)
- /var/cache: Caches (compressed)
- /var/lib/containers: Containers (nodatacow for DB workloads)
- /swap: 4G swapfile (nodatacow required)"
```

---

## Part 2: default.nix - Minimal Server Configuration

### Task 2.1: Create Base default.nix Structure

**Files:**
- Create: `hosts/servers/hetzner-cloud/default.nix`

**Step 1: Create the base configuration**

```nix
# hosts/servers/hetzner-cloud/default.nix
#
# Minimal NixOS configuration for Hetzner Cloud VPS
# Purpose: Personal development server with AI coding tools
# Access: Tailscale-only (no public SSH)
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Disk configuration
    ./disko.nix

    # Hardware configuration (generate with nixos-generate-config)
    ./hardware.nix

    # OpNix for 1Password secrets management
    inputs.opnix.nixosModules.default
  ];

  # ============================================
  # SYSTEM IDENTITY
  # ============================================
  networking.hostName = "hetzner-vps";

  # ============================================
  # BOOT CONFIGURATION
  # ============================================
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    efiSupport = true;
    efiInstallAsRemovable = true;  # Hetzner compatibility
  };

  # Placeholder - update after installation
  system.stateVersion = "25.05";
}
```

**Step 2: Verify syntax**

Run: `nix-instantiate --parse hosts/servers/hetzner-cloud/default.nix`
Expected: No output (successful parse)

**Step 3: Commit base**

```bash
git add hosts/servers/hetzner-cloud/default.nix
git commit -m "feat(hetzner-vps): add base default.nix with system identity"
```

---

### Task 2.2: Add Tailscale and Firewall Configuration

**Files:**
- Modify: `hosts/servers/hetzner-cloud/default.nix`

**Step 1: Add networking and Tailscale configuration**

Append after the boot configuration section:

```nix
  # ============================================
  # TAILSCALE NETWORKING
  # ============================================
  # Why Tailscale SSH instead of regular SSH:
  # 1. Zero-config - no port forwarding, no dynamic DNS
  # 2. Identity-based auth - Tailscale handles authentication
  # 3. End-to-end encrypted - even Tailscale can't see traffic
  # 4. No public IP exposure - only reachable via Tailnet
  # 5. MagicDNS - access via hetzner-vps.tailnet-name.ts.net

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";  # Allow as exit node if needed

    # Use auth key from 1Password for automated authentication
    # Key stored at: op://pantherOS/tailscale/authKey
    authKeyFile = config.age.secrets.tailscale-auth-key.path;

    # Enable Tailscale SSH - replaces OpenSSH for remote access
    # Auth is handled by Tailscale identity, not SSH keys
    extraUpFlags = [
      "--ssh"
      "--accept-dns=false"  # Keep local DNS resolution
    ];
  };

  # ============================================
  # OPENSSH CONFIGURATION
  # ============================================
  # OpenSSH is still installed for:
  # 1. Emergency local access (Hetzner console)
  # 2. Git operations (git@github.com)
  # 3. Fallback if Tailscale is down
  #
  # IMPORTANT: Firewall restricts SSH to Tailnet only

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      KbdInteractiveAuthentication = false;
    };
    # Only listen on Tailscale interface
    listenAddresses = [
      { addr = "100.64.0.0/10"; port = 22; }  # Tailscale CGNAT range
    ];
  };

  # ============================================
  # FIREWALL CONFIGURATION
  # ============================================
  # Why this structure:
  # 1. Default deny - only explicitly allowed ports open
  # 2. Tailscale interface trusted - all Tailnet traffic allowed
  # 3. Public interface restricted - only Tailscale handshake
  #
  # Result: Server is invisible on public internet but fully
  # accessible to authenticated Tailnet members

  networking.firewall = {
    enable = true;

    # Public interface: Only allow Tailscale to establish connection
    allowedUDPPorts = [ 41641 ];  # Tailscale WireGuard port

    # Trust the Tailscale interface completely
    trustedInterfaces = [ "tailscale0" ];

    # No TCP ports on public interface
    allowedTCPPorts = [ ];

    # Enable connection tracking for stateful firewall
    checkReversePath = "loose";  # Required for Tailscale
  };
```

**Step 2: Verify syntax**

Run: `nix-instantiate --parse hosts/servers/hetzner-cloud/default.nix`
Expected: No output (successful parse)

**Step 3: Commit networking**

```bash
git add hosts/servers/hetzner-cloud/default.nix
git commit -m "feat(hetzner-vps): add Tailscale SSH and restricted firewall

- Tailscale as primary access method (identity-based auth)
- OpenSSH restricted to Tailnet only (100.64.0.0/10)
- Firewall trusts tailscale0, blocks public SSH
- Only UDP 41641 open publicly (Tailscale handshake)"
```

---

### Task 2.3: Add User Configuration

**Files:**
- Modify: `hosts/servers/hetzner-cloud/default.nix`

**Step 1: Add user configuration**

Append after the firewall section:

```nix
  # ============================================
  # USER CONFIGURATION
  # ============================================
  # Minimal user setup for server administration
  # Authentication via Tailscale SSH (no password needed)

  users.users.hbohlen = {
    isNormalUser = true;
    description = "Henning Bohlen";
    extraGroups = [
      "wheel"       # sudo access
      "docker"      # container management (if using Docker)
      "podman"      # container management (if using Podman)
    ];

    # No password - auth via Tailscale SSH identity
    # For emergency access, use Hetzner console with root
    hashedPassword = null;

    # Default shell
    shell = pkgs.fish;

    # SSH public keys from 1Password (fallback access)
    # Primary access: Tailscale SSH
    # Fallback: 1Password SSH agent + these keys
    openssh.authorizedKeys.keys = [
      # SSH keys managed via OpNix from 1Password vault
      # op://pantherOS/yogaSSH/public key
      # op://pantherOS/zephyrusSSH/public key
      # op://pantherOS/desktopSSH/public key
      # op://pantherOS/phoneSSH/public key
      # These will be injected by OpNix during build
    ];
  };

  # Allow wheel group to sudo without password
  # Safe because auth is via Tailscale identity
  security.sudo.wheelNeedsPassword = false;
```

**Step 2: Verify syntax**

Run: `nix-instantiate --parse hosts/servers/hetzner-cloud/default.nix`
Expected: No output (successful parse)

**Step 3: Commit user config**

```bash
git add hosts/servers/hetzner-cloud/default.nix
git commit -m "feat(hetzner-vps): add minimal user hbohlen with wheel access"
```

---

### Task 2.4: Add 1Password and OpNix Configuration

**Files:**
- Modify: `hosts/servers/hetzner-cloud/default.nix`

**Step 1: Add 1Password and OpNix**

Append after the user configuration section:

```nix
  # ============================================
  # 1PASSWORD CLI & OPNIX
  # ============================================
  # How they fit together:
  # 1. 1Password CLI (op) - Command-line interface to 1Password vaults
  # 2. OpNix - NixOS module that uses 'op' to inject secrets at build time
  #
  # Workflow:
  # 1. Store secrets in 1Password (API keys, tokens, etc.)
  # 2. Reference in Nix config: op://<vault>/<item>/<field>
  # 3. OpNix fetches and injects during nixos-rebuild
  #
  # Benefits:
  # - Secrets never in git
  # - Single source of truth
  # - Easy rotation
  # - Audit trail in 1Password

  # Install 1Password CLI
  environment.systemPackages = with pkgs; [
    _1password-cli
  ];

  # Enable OpNix - fetches secrets from 1Password during build
  # Requires OP_SERVICE_ACCOUNT_TOKEN environment variable
  # Service account: pantherOS
  # Vault: pantherOS
  services.opnix = {
    enable = true;
  };

  # Define secrets fetched from 1Password
  age.secrets = {
    # Tailscale authentication key
    # Used for automated Tailscale connection on boot
    tailscale-auth-key = {
      source = "op://pantherOS/tailscale/authKey";
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  # SSH public keys from 1Password
  # These are injected into user's authorized_keys
  # Note: Field names with spaces must be quoted
  users.users.hbohlen.openssh.authorizedKeys.keys = [
    # Yoga workstation
    (builtins.readFile (pkgs.runCommand "yoga-ssh-key" {} ''
      ${pkgs._1password-cli}/bin/op read 'op://pantherOS/yogaSSH/"public key"' > $out
    ''))

    # Zephyrus workstation
    (builtins.readFile (pkgs.runCommand "zephyrus-ssh-key" {} ''
      ${pkgs._1password-cli}/bin/op read 'op://pantherOS/zephyrusSSH/"public key"' > $out
    ''))

    # Desktop
    (builtins.readFile (pkgs.runCommand "desktop-ssh-key" {} ''
      ${pkgs._1password-cli}/bin/op read 'op://pantherOS/desktopSSH/"public key"' > $out
    ''))

    # Phone
    (builtins.readFile (pkgs.runCommand "phone-ssh-key" {} ''
      ${pkgs._1password-cli}/bin/op read 'op://pantherOS/phoneSSH/"public key"' > $out
    ''))
  ];
```

**Step 2: Verify syntax**

Run: `nix-instantiate --parse hosts/servers/hetzner-cloud/default.nix`
Expected: No output (successful parse)

**Step 3: Commit 1Password config**

```bash
git add hosts/servers/hetzner-cloud/default.nix
git commit -m "feat(hetzner-vps): add 1Password CLI and OpNix base config

OpNix enabled with no secrets defined yet.
Secrets will be added as services are configured."
```

---

### Task 2.5: Add AI Coding Tools

**Files:**
- Modify: `hosts/servers/hetzner-cloud/default.nix`

**Step 1: Add AI coding tools from nix-ai-tools**

Append after the OpNix section:

```nix
  # ============================================
  # AI CODING TOOLS
  # ============================================
  # Installation strategy: System packages vs Home Manager
  #
  # System packages (environment.systemPackages):
  # - Available to all users
  # - Managed by root/nixos-rebuild
  # - Good for: CLI tools, daemons, system utilities
  #
  # Home Manager (home.packages):
  # - Per-user configuration
  # - User can customize without root
  # - Good for: User-specific tools, dotfiles integration
  #
  # Decision: System packages for AI tools because:
  # 1. Single user server - no need for per-user config
  # 2. Simpler management - one rebuild updates everything
  # 3. AI tools are CLI-based, no user-specific config needed

  environment.systemPackages = with pkgs; [
    # AI Development Tools from nix-ai-tools
    inputs.nix-ai-tools.packages.${pkgs.system}.opencode
    inputs.nix-ai-tools.packages.${pkgs.system}.claude-code

    # Already added above: _1password-cli

    # Shell
    fish

    # Essential utilities
    git
    curl
    wget
    htop
    tree
  ];

  # Enable fish shell system-wide
  programs.fish.enable = true;
```

**Step 2: Verify syntax**

Run: `nix-instantiate --parse hosts/servers/hetzner-cloud/default.nix`
Expected: No output (successful parse)

**Step 3: Commit AI tools**

```bash
git add hosts/servers/hetzner-cloud/default.nix
git commit -m "feat(hetzner-vps): add AI coding tools (opencode, claude-code)

Tools installed as system packages for single-user server simplicity.
Fish shell enabled as default."
```

---

### Task 2.6: Configure 1Password SSH Agent

**Files:**
- Modify: `hosts/servers/hetzner-cloud/default.nix`

**Step 1: Add 1Password SSH agent configuration**

Append after the AI tools section:

```nix
  # ============================================
  # 1PASSWORD SSH AGENT
  # ============================================
  # 1Password as SSH agent provides:
  # 1. Fallback authentication if Tailscale SSH fails
  # 2. SSH key management via 1Password
  # 3. Biometric authentication support (from devices)
  # 4. Centralized key storage and rotation
  #
  # SSH Keys available in 1Password vault:
  # - yogaSSH (Lenovo Yoga workstation)
  # - zephyrusSSH (ASUS ROG Zephyrus workstation)
  # - desktopSSH (Desktop)
  # - phoneSSH (Mobile device)

  programs._1password = {
    enable = true;
  };

  programs._1password-gui = {
    enable = false;  # Server - no GUI needed
  };

  # Configure SSH to use 1Password agent as fallback
  # This allows SSH connections using keys stored in 1Password
  programs.ssh = {
    enable = true;
    extraConfig = ''
      # Use 1Password SSH agent as fallback
      # Primary: Tailscale SSH (identity-based)
      # Fallback: 1Password SSH agent + authorized keys
      IdentityAgent ~/.1password/agent.sock
    '';
  };
```

**Step 2: Verify syntax**

Run: `nix-instantiate --parse hosts/servers/hetzner-cloud/default.nix`
Expected: No output (successful parse)

**Step 3: Commit 1Password SSH agent**

```bash
git add hosts/servers/hetzner-cloud/default.nix
git commit -m "feat(hetzner-vps): add 1Password SSH agent as fallback

- 1Password agent configured for SSH authentication
- Fallback to 1Password if Tailscale SSH unavailable
- 4 authorized SSH keys from 1Password vault"
```

---

### Task 3.1: Add Required Flake Inputs

**Files:**
- Modify: `flake.nix` (inputs section)

**Step 1: Ensure required inputs exist**

Verify/add these inputs in your flake.nix:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko - Declarative disk management
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OpNix - 1Password secrets for NixOS
    opnix = {
      url = "github:mrjones2014/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-ai-tools - AI coding tools
    nix-ai-tools = {
      url = "github:your-username/nix-ai-tools";  # Update with actual URL
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ... other existing inputs
  };
}
```

**Step 2: Verify flake syntax**

Run: `nix flake check --no-build`
Expected: No errors

**Step 3: Commit inputs**

```bash
git add flake.nix
git commit -m "feat(flake): add opnix and nix-ai-tools inputs"
```

---

### Task 3.2: Add NixOS Configuration for hetzner-vps

**Files:**
- Modify: `flake.nix` (outputs section)

**Step 1: Add the hetzner-vps configuration**

In the `nixosConfigurations` section of your flake.nix:

```nix
{
  outputs = { self, nixpkgs, home-manager, disko, opnix, nix-ai-tools, ... }@inputs: {

    nixosConfigurations = {
      # ... existing configurations (yoga, zephyrus, ovh-vps)

      hetzner-vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # Pass inputs to modules
        specialArgs = { inherit inputs; };

        modules = [
          # Disko disk management
          disko.nixosModules.disko

          # Host-specific configuration
          ./hosts/servers/hetzner-cloud/default.nix

          # Note: disko.nix is imported by default.nix
          # Note: opnix is imported by default.nix

          # Home Manager (optional, can add later)
          # home-manager.nixosModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.users.hbohlen = import ./home/hbohlen;
          # }
        ];
      };
    };
  };
}
```

**Step 2: Verify flake configuration**

Run: `nix flake check --no-build`
Expected: No errors

Run: `nix flake show`
Expected: Shows `nixosConfigurations.hetzner-vps`

**Step 3: Commit flake configuration**

```bash
git add flake.nix
git commit -m "feat(flake): add hetzner-vps nixosConfiguration

Includes disko and opnix modules.
Home Manager support prepared but commented out."
```

---

## Part 4: Validation & Deployment

### Task 4.1: Dry Build Validation

**Files:**
- None (validation only)

**Step 1: Run dry build to verify configuration**

This builds the configuration without activating it. Use this to catch errors before deployment.

```bash
# Build the configuration
nixos-rebuild build --flake .#hetzner-vps

# Check the result
ls -la result/
```

Expected:
- Build completes without errors
- `result` symlink points to built configuration

**Step 2: Check what would be created**

```bash
# Show the disk layout that would be created
nix eval .#nixosConfigurations.hetzner-vps.config.disko.devices --json | jq .

# Show installed packages
nix eval .#nixosConfigurations.hetzner-vps.config.environment.systemPackages --json | jq .
```

Expected:
- Shows partition layout with sda, bios-boot, esp, root
- Shows packages including fish, git, opencode, claude-code

**Step 3: Validate with dry-activate (if existing system)**

If you have SSH access to the current system:

```bash
# Copy configuration and test activation
nixos-rebuild dry-activate --flake .#hetzner-vps --target-host root@hetzner-vps
```

Expected: Shows what would change without applying

---

### Task 4.2: Initial Deployment (Fresh Install)

**Files:**
- None (deployment procedure)

**Step 1: Mount NixOS ISO via Hetzner Cloud Console**

1. Log into Hetzner Cloud Console
2. Go to your server → ISO Images
3. Select "NixOS 25.05" (or latest available)
4. Click "Mount & Power cycle"
5. Wait for server to boot into NixOS installer
6. SSH into installer: `ssh root@<server-ip>` (password from console)

**Step 2: Clone configuration and run Disko**

```bash
# From NixOS installer environment
# Clone your configuration
git clone https://github.com/your-username/pantherOS
cd pantherOS

# Run disko to partition and mount
# Disko is available in the NixOS installer
sudo disko --mode disko ./hosts/servers/hetzner-cloud/disko.nix
```

Expected:
- Disk partitioned with GPT (1M BIOS boot, 512M ESP, ~457GB Btrfs)
- Btrfs filesystem created with 9 subvolumes
- Everything mounted at /mnt

**Step 3: Generate hardware configuration**

```bash
# Generate hardware.nix with detected hardware
nixos-generate-config --root /mnt --dir ./hosts/servers/hetzner-cloud/

# Commit the generated hardware.nix
git add hosts/servers/hetzner-cloud/hardware.nix
git commit -m "feat(hetzner-vps): add generated hardware.nix"
```

Expected: Creates hardware.nix with:
- Detected CPU/memory
- Network interfaces
- Kernel modules
- Filesystem UUIDs

**Step 4: Bootstrap OP_SERVICE_ACCOUNT_TOKEN**

⚠️ **CHICKEN-AND-EGG PROBLEM:**
- The token is stored at `op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token`
- But you need the token to access 1Password!
- Solution: Manually provide token for initial install

```bash
# Retrieve token from 1Password (on your local machine first)
# Copy the token value, then set it in the installer:

# For bash (NixOS installer default):
export OP_SERVICE_ACCOUNT_TOKEN="ops_xxx_your_actual_token_here"

# Verify it's set
echo $OP_SERVICE_ACCOUNT_TOKEN
```

**Step 5: Install NixOS**

```bash
# Install from the cloned repo
# OpNix will use OP_SERVICE_ACCOUNT_TOKEN to fetch secrets during build
sudo nixos-install --flake .#hetzner-vps --no-root-password
```

Expected:
- OpNix fetches Tailscale auth key and SSH public keys from 1Password
- NixOS installs to /mnt
- GRUB bootloader configured on /dev/sda
- User hbohlen created with 4 authorized SSH keys
- All packages installed

If build fails with OpNix errors:
1. Verify `OP_SERVICE_ACCOUNT_TOKEN` is set: `echo $OP_SERVICE_ACCOUNT_TOKEN`
2. Test 1Password access: `op vault list` (should show pantherOS vault)
3. Check secret paths are correct in the configuration

**Step 6: Configure OP_SERVICE_ACCOUNT_TOKEN for Future Rebuilds**

After install completes, but BEFORE rebooting, enter the new system and set the token:

```bash
# Enter the installed system
sudo nixos-enter

# Set OP_SERVICE_ACCOUNT_TOKEN for future nixos-rebuild
# Fish shell syntax (set -x exports variable):
set -x OP_SERVICE_ACCOUNT_TOKEN "ops_xxx_your_actual_token_here"

# Or for bash:
# export OP_SERVICE_ACCOUNT_TOKEN="ops_xxx_your_actual_token_here"

# Add to persistent config so it survives reboots
mkdir -p /persist/secrets
echo "ops_xxx_your_actual_token_here" > /persist/secrets/op-token

# Exit the installed system
exit
```

**Step 7: Unmount ISO and reboot**

```bash
# Reboot (will boot from disk now)
reboot
```

Then via Hetzner Cloud Console:
1. Go to ISO Images → Unmount ISO
2. Server will boot into installed NixOS

**Step 8: Initial Tailscale setup**

After reboot, Tailscale should authenticate automatically using the auth key from 1Password.

Verify via Hetzner console (VNC):

```bash
# Check Tailscale status
tailscale status

# Should show: Connected, hostname: hetzner-vps
```

If not connected, manually authenticate:

```bash
# Log in as root via console (emergency access)
# Tailscale will use auth key from /run/secrets/tailscale-auth-key
tailscale up --ssh
```

**Step 9: Configure Persistent OP_SERVICE_ACCOUNT_TOKEN**

For future `nixos-rebuild` operations, configure the token to load automatically:

```bash
# Via Hetzner console or Tailscale SSH:
sudo -i

# Add to fish config (if using fish)
echo 'set -x OP_SERVICE_ACCOUNT_TOKEN (cat /persist/secrets/op-token)' >> /etc/fish/config.fish

# Or add to bash profile
# echo 'export OP_SERVICE_ACCOUNT_TOKEN=$(cat /persist/secrets/op-token)' >> /root/.bashrc

# Test it works:
source /etc/fish/config.fish  # or source /root/.bashrc
op vault list  # Should show pantherOS vault
```

**Step 10: Connect via Tailscale SSH**

From your local machine:

```bash
# Connect via Tailscale (preferred)
ssh hbohlen@hetzner-vps

# Or use full Tailscale hostname
ssh hbohlen@hetzner-vps.<your-tailnet>.ts.net

# Fallback: Use 1Password SSH agent with authorized keys
ssh -i ~/.ssh/yoga_key hbohlen@hetzner-vps
```

Expected: Passwordless login via Tailscale identity or 1Password SSH agent

---

### Task 4.3: Update Deployment (Existing System)

**Files:**
- None (deployment procedure)

**Step 1: Build locally**

```bash
nixos-rebuild build --flake .#hetzner-vps
```

**Step 2: Deploy via Tailscale**

```bash
# Deploy to remote system
nixos-rebuild switch --flake .#hetzner-vps --target-host hbohlen@hetzner-vps --use-remote-sudo
```

Expected:
- Configuration copied to remote
- Built remotely
- Activated
- Services restarted

**Step 3: Verify deployment**

```bash
# SSH via Tailscale
ssh hbohlen@hetzner-vps

# Check services
systemctl status tailscaled
systemctl status sshd

# Check tools
opencode --version
claude --version
op --version

# Check filesystem
btrfs subvolume list /
df -h
```

---

## Appendix A: Subvolume Design Rationale

| Subvolume | Mount | Options | Rationale |
|-----------|-------|---------|-----------|
| /root | / | compress | System files, snapshot-able, impermanence-ready |
| /home | /home | compress | User data, independent backup schedule |
| /home/dev | /home/hbohlen/dev | compress | Dev projects, targeted snapshots before major changes |
| /nix | /nix | compress | Package store, high read/low write, compresses well |
| /var | /var | compress | Service state, different retention than system |
| /var/log | /var/log | nodatacow | High sequential writes, COW overhead bad for logs |
| /var/cache | /var/cache | compress | Rebuildable, exclude from snapshots |
| /var/lib/containers | /var/lib/containers | nodatacow | DBs in containers need nodatacow for performance |
| /swap | /swap | nodatacow | Btrfs requires nodatacow for swapfiles |

## Appendix B: Security Model Summary

```
┌─────────────────────────────────────────┐
│           PUBLIC INTERNET               │
│  (Only UDP 41641 open - Tailscale)     │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│           TAILSCALE LAYER               │
│  - Identity-based authentication        │
│  - End-to-end encryption                │
│  - MagicDNS (hetzner-vps.ts.net)       │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         HETZNER VPS (tailscale0)        │
│  - All ports accessible via Tailnet     │
│  - SSH on port 22 (Tailnet only)        │
│  - Tailscale SSH (preferred)            │
│  - sudo without password (Tailscale ID) │
└─────────────────────────────────────────┘
```

## Appendix C: 1Password Configuration Summary

### Service Account Setup

```yaml
Service Account: pantherOS
Vault: pantherOS
Permissions: --can-create-vaults (auto-adds new vaults)
```

### Secrets Stored in 1Password

```yaml
Tailscale Auth Key:
  Path: op://pantherOS/tailscale/authKey
  Usage: Automatic Tailscale authentication on boot
  Injected: /run/secrets/tailscale-auth-key (OpNix)

OP_SERVICE_ACCOUNT_TOKEN:
  Path: op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token
  Usage: Authenticate to 1Password for fetching secrets
  Bootstrap: Must be manually provided during initial install
  Persistent: Store in /persist/secrets/op-token after install

SSH Keys (4 devices):
  1. yogaSSH:
      Path: op://pantherOS/yogaSSH/"public key"
      Fields: "public key", "private key", fingerprint, "key type"
      Device: Lenovo Yoga workstation
      Note: Field names with spaces must be quoted

  2. zephyrusSSH:
      Path: op://pantherOS/zephyrusSSH/"public key"
      Fields: "public key", "private key", fingerprint, "key type"
      Device: ASUS ROG Zephyrus workstation

  3. desktopSSH:
      Path: op://pantherOS/desktopSSH/"public key"
      Fields: "public key", "private key", fingerprint, "key type"
      Device: Desktop computer

  4. phoneSSH:
      Path: op://pantherOS/phoneSSH/"public key"
      Fields: "public key", "private key", fingerprint, "key type"
      Device: Mobile device
```

### SSH Authentication Flow

```
┌─────────────────────────────────────────┐
│         Attempt SSH Connection          │
└─────────────────┬───────────────────────┘
                  │
                  ▼
         ┌────────────────────┐
         │  Tailscale SSH?    │──Yes──> Authenticate via
         │  (Primary)         │         Tailscale identity
         └────────┬───────────┘
                  │ No
                  ▼
         ┌────────────────────┐
         │ 1Password SSH      │──Yes──> Authenticate via
         │ Agent?             │         1Password + key
         │ (Fallback)         │
         └────────┬───────────┘
                  │ No
                  ▼
         ┌────────────────────┐
         │  Connection Failed │
         └────────────────────┘
```

### OpNix Integration

OpNix fetches secrets from 1Password during `nixos-rebuild`:

1. Reads `OP_SERVICE_ACCOUNT_TOKEN` environment variable
2. Authenticates to 1Password service account
3. Fetches secrets from `pantherOS` vault
4. Injects into configuration at build time
5. Secrets available as files in `/run/secrets/`

---

## Appendix D: Required Environment Variables

### Bootstrap Process (Initial Install)

The OP_SERVICE_ACCOUNT_TOKEN creates a chicken-and-egg problem:

```
┌────────────────────────────────────────────┐
│ Problem: Token is IN 1Password             │
│ But: Need token to ACCESS 1Password        │
└────────────────────────────────────────────┘
```

**Solution: Three-stage bootstrap**

**Stage 1: Initial Install (NixOS ISO)**
```bash
# Manually provide token from your local machine
export OP_SERVICE_ACCOUNT_TOKEN="ops_xxx_from_your_1password"

# Run install (OpNix uses token to fetch secrets)
sudo nixos-install --flake .#hetzner-vps --no-root-password
```

**Stage 2: Post-Install (Before Reboot)**
```bash
# Enter installed system
sudo nixos-enter

# Store token persistently
mkdir -p /persist/secrets
echo "ops_xxx_from_your_1password" > /persist/secrets/op-token
chmod 600 /persist/secrets/op-token

# Configure shell to load token (Fish shell)
echo 'set -x OP_SERVICE_ACCOUNT_TOKEN (cat /persist/secrets/op-token)' >> /etc/fish/config.fish

# Or for bash:
# echo 'export OP_SERVICE_ACCOUNT_TOKEN=$(cat /persist/secrets/op-token)' >> /root/.bashrc

exit
```

**Stage 3: After Reboot**
```bash
# Token loads automatically from /persist/secrets/op-token
# Future nixos-rebuild will work without manual export

# Verify:
op vault list  # Should show pantherOS vault
```

### Future Deployments

For remote deployments from your local machine:

```bash
# Set token locally
export OP_SERVICE_ACCOUNT_TOKEN="ops_xxx_from_your_1password"

# Deploy
nixos-rebuild switch --flake .#hetzner-vps \
  --target-host hbohlen@hetzner-vps \
  --use-remote-sudo
```

### Alternative: Fetch Token from 1Password

Once you have 1Password CLI configured locally:

```bash
# Fetch token from 1Password
export OP_SERVICE_ACCOUNT_TOKEN=$(op read "op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token")

# Use for deployment
nixos-rebuild switch --flake .#hetzner-vps --target-host hbohlen@hetzner-vps
```

---

**Plan Created:** 2025-11-21
**Estimated Implementation Time:** 2-3 hours
**Author:** BMad Orchestrator (Harley-chan)
