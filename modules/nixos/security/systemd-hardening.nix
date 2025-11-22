{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.security.systemdHardening;
in
{
  options.pantherOS.security.systemdHardening = {
    enable = mkEnableOption "PantherOS systemd service hardening";
    
    enableSystemdAttackSurfaceReduction = mkOption {
      type = types.bool;
      default = true;
      description = "Reduce systemd attack surface by disabling unused features";
    };
    
    enableUnifiedCgroupHierarchy = mkOption {
      type = types.bool;
      default = true;
      description = "Enable unified cgroup hierarchy for better isolation";
    };
    
    enableUserSlices = mkOption {
      type = types.bool;
      default = true;
      description = "Enable user slices for user session isolation";
    };
    
    defaultServiceMode = mkOption {
      type = types.enum [ "strict" "balanced" "relaxed" ];
      default = "strict";
      description = "Default security mode for services";
    };
    
    enableServiceSandboxing = mkOption {
      type = types.bool;
      default = true;
      description = "Enable service sandboxing by default";
    };
    
    globalServiceSettings = {
      enableAmbientCapabilities = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable ambient capabilities by default";
      };
      
      enableSecureBits = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable secure bits by default";
      };
      
      enableNoNewPrivileges = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable no-new-privileges by default";
      };
      
      enablePrivateUsers = mkOption {
        type = types.bool;
        default = false;  # This can break some services
        description = "Whether to enable private users by default";
      };
    };
  };

  config = mkIf cfg.enable {
    # Systemd hardening configurations
    systemd = {
      # Systemd service hardening settings
      enableHardening = true;
      
      # Reduce attack surface
      service = mkIf cfg.enableSystemdAttackSurfaceReduction {
        # Default secure settings for all services
        default = {
          # Security settings
          NoNewPrivileges = mkDefault cfg.globalServiceSettings.enableNoNewPrivileges;
          
          # Isolation settings
          PrivateTmp = mkDefault true;
          PrivateDevices = mkDefault true;
          PrivateUsers = mkDefault cfg.globalServiceSettings.enablePrivateUsers;
          ProtectSystem = mkDefault "strict";
          ProtectHome = mkDefault true;
          ProtectHostname = mkDefault true;
          ProtectClock = mkDefault true;
          ProtectKernelTunables = mkDefault true;
          ProtectKernelModules = mkDefault true;
          ProtectControlGroups = mkDefault true;
          RestrictAddressFamilies = mkDefault [ "AF_INET" "AF_INET6" ];
          RestrictRealtime = mkDefault true;
          RestrictSUIDSGID = mkDefault true;
          RemoveIPC = mkDefault true;
          
          # Capabilities hardening
          AmbientCapabilities = mkIf cfg.globalServiceSettings.enableAmbientCapabilities [ ];
          NoExecPaths = mkDefault [
            "/tmp" "/var/tmp" "/dev/shm"
          ];
          ExecPaths = mkDefault [
            "/nix/store/*" "/run/current-system/sw/bin"
          ];
          ReadOnlyPaths = mkDefault [
            "/etc" "/usr" "/opt"
          ];
          ReadWritePaths = mkDefault [
            "/var" "/tmp" "/run" "/dev"
          ];
        };
      };
      
      # User session hardening
      user = mkIf cfg.enableUserSlices {
        enable = cfg.enableUserSlices;
        defaultSlice = mkIf (cfg.defaultServiceMode == "strict") "system.slice"; # More restrictive for user services
      };
    };
    
    # Kernel parameters for systemd hardening
    boot = mkIf cfg.enableUnifiedCgroupHierarchy {
      kernel.sysctl = {
        # Cgroup settings
        "kernel.unprivileged_userns_clone" = mkDefault 0; # Disable unprivileged user namespaces
        "kernel.ctrl-alt-del" = mkDefault 0; # Disable Ctrl+Alt+Del
        "kernel.modules_disabled" = mkDefault 0; # Can be set to 1 in very secure environments (disables module loading after boot)
        "kernel.kexec_load_disabled" = mkDefault 1; # Disable kexec (only when needed)
        "kernel.kptr_restrict" = mkDefault 2; # Restrict kernel pointer leaks
        "kernel.printk" = mkDefault [ 3 3 3 3 ]; # Restrict kernel messages
      };
    };
    
    # Extra packages for security monitoring
    environment.systemPackages = mkIf cfg.enableSystemdAttackSurfaceReduction [
      pkgs.systemd
      pkgs.acl  # For systemd ACLs
    ];
    
    # Additional security settings
    security = mkIf cfg.enableSystemdAttackSurfaceReduction {
      # Ensure systemd settings are properly applied
      protectKernelModules = true;
      protectKernelTunables = true;
    };
  };
}