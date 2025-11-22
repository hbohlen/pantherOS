{ config, lib, ... }:

with lib;

let
  cfg = config.pantherOS.core.systemd;
in
{
  options.pantherOS.core.systemd = {
    enable = mkEnableOption "PantherOS systemd optimization and management";
    
    services = {
      enableCullServices = mkOption {
        type = types.bool;
        default = true;
        description = "Enable systemd service culling to free up disk space";
      };
      enableTmpfiles = mkOption {
        type = types.bool;
        default = true;
        description = "Enable systemd tmpfiles for temporary file management";
      };
    };
    
    journald = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable systemd journald configuration";
      };
      maxSize = mkOption {
        type = types.str;
        default = "100M";
        description = "Maximum size for journal files";
      };
      maxFile = mkOption {
        type = types.str;
        default = "10M";
        description = "Maximum size for individual journal files";
      };
      compress = mkOption {
        type = types.bool;
        default = true;
        description = "Compress journal files";
      };
      rateLimitIntervalSec = mkOption {
        type = types.int;
        default = 30;
        description = "Interval for rate limiting in seconds";
      };
      rateLimitBurst = mkOption {
        type = types.int;
        default = 10000;
        description = "Burst limit for rate limiting";
      };
    };
    
    logind = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable systemd logind configuration";
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Additional logind configuration";
      };
    };
    
    enableUnifiedCgroupHierarchy = mkOption {
      type = types.bool;
      default = true;
      description = "Enable unified cgroup hierarchy";
    };
  };

  config = mkIf cfg.enable {
    # Systemd optimizations
    systemd = {
      # Enable service culling to free up disk space
      cullSpecificUnits = cfg.services.enableCullServices;
      
      # Enable tmpfiles for temporary file management
      tmpfiles = mkIf cfg.services.enableTmpfiles {
        enable = true;
      };
      
      # Journald configuration
      journald = mkIf cfg.journald.enable {
        enable = cfg.journald.enable;
        extraConfig = ''
          SystemMaxUse=${cfg.journald.maxSize}
          SystemMaxFileSize=${cfg.journald.maxFile}
          Compress=${if cfg.journald.compress then "yes" else "no"}
          RateLimitIntervalSec=${toString cfg.journald.rateLimitIntervalSec}
          RateLimitBurst=${toString cfg.journald.rateLimitBurst}
          ForwardToSyslog=no
        '';
      };
      
      # Logind configuration
      logind = mkIf cfg.logind.enable {
        enable = cfg.logind.enable;
        extraConfig = cfg.logind.extraConfig;
      };
    };
    
    # Unified cgroup hierarchy
    boot.kernel.sysctl."kernel.unprivileged_userns_clone" = mkDefault 1;
    
    # Additional systemd settings
    boot = {
      # Enable unified cgroup hierarchy
      kernelModules = mkIf cfg.enableUnifiedCgroupHierarchy [ "cgroup_no_v1" ];
      extraModprobeConfig = mkIf cfg.enableUnifiedCgroupHierarchy ''
        options cgroup_no_v1 all
      '';
    };
  };
}