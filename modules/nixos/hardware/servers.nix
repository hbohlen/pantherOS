{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.hardware.servers;
in
{
  options.pantherOS.hardware.servers = {
    enable = mkEnableOption "PantherOS server hardware configuration";
    
    enablePerformanceMode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable performance mode for server hardware";
    };
    
    enableHwmon = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hardware monitoring";
    };
    
    enableRemoteManagement = mkOption {
      type = types.bool;
      default = false;
      description = "Enable remote hardware management (IPMI, etc.)";
    };
    
    enableECCMemory = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ECC memory monitoring";
    };
    
    enableStorage = {
      enableZfs = mkOption {
        type = types.bool;
        default = false;
        description = "Enable ZFS storage support";
      };
      
      enableHWDetection = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic hardware detection for storage";
      };
    };
    
    powerManagement = {
      enableCpuGovernor = mkOption {
        type = types.bool;
        default = true;
        description = "Enable CPU frequency scaling governor";
      };
      
      cpuGovernor = mkOption {
        type = types.enum [ "performance" "ondemand" "conservative" "powersave" ];
        default = "performance";
        description = "CPU frequency scaling governor for servers";
      };
    };
  };

  config = mkIf cfg.enable {
    # Server hardware configuration
    hardware = {
      # Enable hardware monitoring
      sensor = mkIf cfg.enableHwmon {
        enable = cfg.enableHwmon;
      };
    };
    
    # CPU frequency scaling for servers
    services = mkIf cfg.powerManagement.enableCpuGovernor {
      cpupower = {
        enable = cfg.powerManagement.enableCpuGovernor;
        governor = mkDefault cfg.powerManagement.cpuGovernor;
        energyPolicy = mkDefault "performance";
      };
    };
    
    # Remote management (IPMI, etc.)
    services = mkIf cfg.enableRemoteManagement {
      # IPMI service configuration
      ipmievd = {
        enable = cfg.enableRemoteManagement;
        daemon = "openipmi";
      };
      
      # Enable OpenIPMI for hardware monitoring
      openipmi = mkIf cfg.enableRemoteManagement {
        enable = cfg.enableRemoteManagement;
      };
    };
    
    # Storage configuration
    services = mkIf cfg.enableStorage.enableZfs {
      # ZFS service configuration
      zfs = mkIf cfg.enableStorage.enableZfs {
        autoScrub = true;
        autoSnapshot = true;
      };
    };
    
    # Server-specific power management
    boot = {
      kernelParams = mkIf cfg.enablePerformanceMode [
        # Parameters for server performance
        "elevator=none"  # Use default scheduler which is typically best for servers 
        "quiet"          # Reduce boot verbosity
        "splash"         # Enable splash screen if available
      ];
      
      kernelModules = []
        ++ (mkIf cfg.enableHwmon [ "i2c-dev" "i2c-piix4" "coretemp" "k10temp" ])
        ++ (mkIf cfg.enableRemoteManagement [ "ipmi_si" "ipmi_devintf" ])
        ++ (mkIf cfg.enableStorage.enableZfs [ "zfs" ]);
      
      # Additional kernel parameters for server stability
      extraModprobeConfig = mkIf cfg.enableECCMemory ''
        # ECC memory monitoring
        options mce-inject recovery_mode=1
      '';
    };
    
    # System configuration for servers
    system = {
      # Enable sysctl parameters for server performance
      sysctl = mkIf cfg.enablePerformanceMode {
        # TCP optimizations for server workloads
        "net.core.rmem_max" = mkDefault 134217728;
        "net.core.wmem_max" = mkDefault 134217728;
        "net.ipv4.tcp_rmem" = mkDefault "4096 65536 134217728";
        "net.ipv4.tcp_wmem" = mkDefault "4096 65536 134217728";
        "net.core.netdev_max_backlog" = mkDefault 5000;
        
        # VM optimizations for server workloads
        "vm.swappiness" = mkIf cfg.enablePerformanceMode 1;
        "vm.dirty_ratio" = mkDefault 15;
        "vm.dirty_background_ratio" = mkDefault 5;
      };
    };
    
    # Additional packages for server hardware management
    environment.systemPackages = with pkgs; [
      # Hardware monitoring tools
      lm_sensors
      smartmontools
      ipmitool
      
      # Server utilities
      mcelog  # Machine Check Exception logging
      hdparm  # Drive configuration
      nvme-cli  # NVMe management
      
      # Storage utilities
    ] ++ (mkIf cfg.enableStorage.enableZfs [ zfs ]);
    
    # Services for hardware monitoring
    services = {
      # SMART monitoring for storage health
      smartd = mkIf cfg.enableHwmon {
        enable = cfg.enableHwmon;
        notifications = {
          mailTo = [ "root@localhost" ];
        };
      };
      
      # Enable mcelog for ECC memory error reporting
      mcelog = mkIf cfg.enableECCMemory {
        enable = cfg.enableECCMemory;
        client = {
          enable = true;
          commandLine = "--client";
        };
        daemon = {
          enable = true;
        };
      };
    };
  };
}