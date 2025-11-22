{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.core.boot;
in
{
  options.pantherOS.core.boot = {
    enable = mkEnableOption "PantherOS boot and kernel configuration";
    
    bootloader = {
      grub = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable GRUB bootloader";
        };
        device = mkOption {
          type = types.str;
          default = "nodev";
          description = "GRUB device (for non-EFI systems)";
        };
        efiSupport = mkOption {
          type = types.bool;
          default = true;
          description = "Enable EFI support";
        };
        efiInstallAsRemovable = mkOption {
          type = types.bool;
          default = true;
          description = "Install GRUB as removable (for VMs)";
        };
      };
    };
    
    kernel = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kernel configuration";
      };
      parameters = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "quiet" "splash" ];
        description = "Additional kernel parameters";
      };
      sysctl = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Kernel sysctl parameters";
      };
    };
  };

  config = mkIf cfg.enable {
    # Bootloader configuration
    boot.loader = mkIf cfg.bootloader.grub.enable {
      grub = {
        enable = cfg.bootloader.grub.enable;
        device = cfg.bootloader.grub.device;
        efiSupport = cfg.bootloader.grub.efiSupport;
        efiInstallAsRemovable = cfg.bootloader.grub.efiInstallAsRemovable;
      };
    };
    
    # Kernel configuration
    boot = mkIf cfg.kernel.enable {
      # Additional kernel parameters
      kernelParams = cfg.kernel.parameters;
      
      # Kernel sysctl parameters
      kernel.sysctl = cfg.kernel.sysctl;
      
      # Enable Btrfs for systems that will use it
      supportedFilesystems = [ "btrfs" "ext4" "vfat" ];
      
      # Initrd configuration for encrypted systems
      initrd = {
        systemd.enable = true;
      };
    };
    
    # Additional kernel configurations based on system type
    system.stateVersion = "24.05"; # Recommended for new systems
  };
}