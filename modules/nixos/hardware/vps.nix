{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.hardware.vps;
in
{
  options.pantherOS.hardware.vps = {
    enable = mkEnableOption "PantherOS VPS hardware configuration";
    
    vpsProvider = mkOption {
      type = types.enum [ "hetzner" "ovh" "digitalocean" "aws" "gcp" "azure" "other" ];
      default = "other";
      description = "VPS provider for specific optimizations";
    };
    
    enableVirtio = mkOption {
      type = types.bool;
      default = true;
      description = "Enable VirtIO drivers for virtualized hardware";
    };
    
    enableBalloonDriver = mkOption {
      type = types.bool;
      default = true;
      description = "Enable VirtIO balloon driver for memory management";
    };
    
    enableNetworkOptimization = mkOption {
      type = types.bool;
      default = true;
      description = "Enable VPS network optimizations";
    };
    
    enableBlockOptimization = mkOption {
      type = types.bool;
      default = true;
      description = "Enable VPS block device optimizations";
    };
    
    enableEntropy = mkOption {
      type = types.bool;
      default = true;
      description = "Enable entropy generation for VPS";
    };
    
    enablePerformanceMode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable performance optimizations for VPS";
    };
    
    enableMonitoring = mkOption {
      type = types.bool;
      default = true;
      description = "Enable VPS hardware monitoring";
    };
  };

  config = mkIf cfg.enable {
    # VPS hardware configuration
    hardware = {
      # Enable virtualization-specific drivers
      enableRedistributableFirmware = true;  # Usually needed in VPS environments
    };
    
    # Kernel modules for VPS environments
    boot = {
      kernelModules = []
        ++ (mkIf cfg.enableVirtio [ 
          "virtio" 
          "virtio_pci" 
          "virtio_blk" 
          "virtio_net" 
          "virtio_balloon"
        ])
        ++ (mkIf cfg.enableBalloonDriver [ "virtio_balloon" ]);
      
      # Additional kernel parameters for VPS
      kernelParams = mkIf cfg.enablePerformanceMode [
        # VPS-specific kernel parameters
        "console=tty1"
        "console=ttyS0"  # Enable serial console
        "elevator=noop"  # Use noop scheduler for virtualized block devices
        "virtio_pci.disable_sriov=1"  # Disable SR-IOV if not supported
      ];
    };
    
    # Services for VPS environments
    services = {
      # Enable entropy daemon for VPS (often needed)
      haveged = mkIf cfg.enableEntropy {
        enable = cfg.enableEntropy;
        extraOptions = "--no-daemon";  # Run in foreground in systemd
      };
      
      # Disable hardware services that don't apply to VPS
      tlp = mkIf cfg.enablePerformanceMode {
        enable = false;  # Disable TLP since it's for laptops
      };
    };
    
    # System configuration for VPS environments
    system = {
      # System settings optimized for VPS
      stateVersion = mkDefault config.system.nixos.release;
      
      # Sysctl parameters for VPS performance
      sysctl = mkIf cfg.enableNetworkOptimization {
        # Network optimizations for VPS
        "net.core.rmem_max" = mkDefault 134217728;
        "net.core.wmem_max" = mkDefault 134217728;
        "net.ipv4.tcp_rmem" = mkDefault "4096 65536 134217728";
        "net.ipv4.tcp_wmem" = mkDefault "4096 65536 134217728";
        "net.core.netdev_max_backlog" = mkDefault 5000;
        "net.core.somaxconn" = mkDefault 1024;
        
        # VM/VPS optimizations
        "vm.swappiness" = mkIf cfg.enablePerformanceMode 1;
        "vm.dirty_ratio" = mkDefault 15;
        "vm.dirty_background_ratio" = mkDefault 5;
        "vm.vfs_cache_pressure" = mkDefault 50;
      };
    };
    
    # Environment packages for VPS management
    environment.systemPackages = with pkgs; [
      # VPS administration tools
      virtio-drivers  # VirtIO drivers
      qemu  # Needed for various virtualization utilities
      
      # Monitoring tools
      htop
      iotop
      iftop
      nethogs
      
      # System utilities
      virt-what  # Detect virtualization
      pciutils   # Hardware information
      usbutils   # USB information
    ];
    
    # Specialized configurations based on VPS provider
    system.activationScripts = mkIf cfg.enable {
      "vps-optimizations" = let
        providerSpecificConfig = 
          if cfg.vpsProvider == "hetzner" then
            "# Hetzner-specific optimizations would go here"
          else if cfg.vpsProvider == "ovh" then
            "# OVH-specific optimizations would go here"
          else if cfg.vpsProvider == "digitalocean" then
            "# DigitalOcean-specific optimizations would go here"
          else if cfg.vpsProvider == "aws" then
            "# AWS-specific optimizations would go here"
          else if cfg.vpsProvider == "gcp" then
            "# GCP-specific optimizations would go here"
          else if cfg.vpsProvider == "azure" then
            "# Azure-specific optimizations would go here"
          else
            "# Generic VPS optimizations";
      in
        providerSpecificConfig;
    };
    
    # Enable or disable services based on VPS environment
    services = mkIf cfg.enableMonitoring {
      # Monitoring and logging specific to VPS
      rsyslogd = {
        enable = true;
        extraConfig = ''
          # VPS-specific logging configuration
          $SystemLogSize 200M
          $SystemLogFacilityLevel local0.warning
        '';
      };
      
      # Disable services that don't make sense in VPS
      thermald.enable = false;  # No thermal management needed in VPS
      upower.enable = false;   # No battery management in VPS
    };
  };
}