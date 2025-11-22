{ config, lib, ... }:

with lib;

let
  cfg = config.pantherOS.services.networking;
in
{
  options.pantherOS.services.networking = {
    enable = mkEnableOption "PantherOS network services configuration";
    
    enableCron = mkOption {
      type = types.bool;
      default = true;
      description = "Enable cron daemon";
    };
    
    enableAvahi = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Avahi for mDNS/DNS-SD";
      };
      nssmdns4 = mkOption {
        type = types.bool;
        default = false;
        description = "Use avahi for IPv4 mDNS lookups";
      };
      nssmdns6 = mkOption {
        type = types.bool;
        default = false;
        description = "Use avahi for IPv6 mDNS lookups";
      };
      publish = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable publishing of mDNS records";
        };
        addresses = mkOption {
          type = types.bool;
          default = false;
          description = "Publish IP addresses";
        };
        hinfo = mkOption {
          type = types.bool;
          default = false;
          description = "Publish host information";
        };
        userServices = mkOption {
          type = types.bool;
          default = false;
          description = "Publish user services";
        };
        workstation = mkOption {
          type = types.bool;
          default = false;
          description = "Publish workstation service";
        };
      };
    };
    
    enableTimeSyncd = mkOption {
      type = types.bool;
      default = true;
      description = "Enable systemd-timesyncd for NTP synchronization";
    };
    
    enableBridges = mkOption {
      type = types.bool;
      default = false;
      description = "Enable bridge interface support";
    };
    
    enableVlans = mkOption {
      type = types.bool;
      default = false;
      description = "Enable VLAN support";
    };
  };

  config = mkIf cfg.enable {
    # Enable/disable cron
    services.cron.enable = mkIf cfg.enableCron {
      enable = cfg.enableCron;
    };
    
    # Avahi configuration
    services.avahi = mkIf cfg.enableAvahi.enable {
      enable = cfg.enableAvahi.enable;
      nssmdns4 = cfg.enableAvahi.nssmdns4;
      nssmdns6 = cfg.enableAvahi.nssmdns6;
      publish = mkIf cfg.enableAvahi.publish.enable {
        enable = cfg.enableAvahi.publish.enable;
        addresses = cfg.enableAvahi.publish.addresses;
        hinfo = cfg.enableAvahi.publish.hinfo;
        userServices = cfg.enableAvahi.publish.userServices;
        workstation = cfg.enableAvahi.publish.workstation;
      };
    };
    
    # Time synchronization
    services.timesyncd = mkIf cfg.enableTimeSyncd {
      enable = cfg.enableTimeSyncd;
    };
    
    # Network interface configuration
    networking = {
      # Enable bridges if required
      bridges = mkIf cfg.enableBridges {
        br0.interfaces = [ ];  # To be configured per host
      };
      
      # Enable VLANs if required
      vlans = mkIf cfg.enableVlans {
        # To be configured per host
      };
      
      # Additional network settings
      networkmanager = {
        enable = true;
        # Don't control vSwitches if using bridges
        unmanaged = mkIf cfg.enableBridges [ "interface-name:br*"];
      };
    };
    
    # Enable required kernel modules for networking features
    boot.kernelModules = []
      ++ (mkIf cfg.enableBridges [ "bridge" "stp" ])
      ++ (mkIf cfg.enableVlans [ "8021q" ]);
  };
}