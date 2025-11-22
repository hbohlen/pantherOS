{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.services.podman;
in
{
  options.pantherOS.services.podman = {
    enable = mkEnableOption "PantherOS Podman container service";
    
    enableDockerSocket = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Docker-compatible socket for Podman";
    };
    
    dockerSocketGroup = mkOption {
      type = types.str;
      default = "docker";
      description = "Group to own the Docker-compatible socket";
    };
    
    enableContainerHost = mkOption {
      type = types.bool;
      default = false;
      description = "Enable additional services for container hosting";
    };
    
    defaultNetwork = {
      enableIPv6 = mkOption {
        type = types.bool;
        default = false;
        description = "Enable IPv6 for the default Podman network";
      };
      subnet = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "10.89.0.0/16";
        description = "Subnet for the default Podman network";
      };
    };
    
    settings = {
      cgroupManager = mkOption {
        type = types.enum [ "cgroupfs" "systemd" ];
        default = "systemd";
        description = "Cgroup manager for Podman";
      };
      
      networkBackend = mkOption {
        type = types.enum [ "cni" "netavark" ];
        default = "netavark";
        description = "Network backend for Podman";
      };
      
      storageDriver = mkOption {
        type = types.enum [ "overlay" "vfs" ];
        default = "overlay";
        description = "Storage driver for Podman";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = cfg.enableDockerSocket;
        dockerSocket.enable = cfg.enableDockerSocket;
        dockerSocket.group = cfg.dockerSocketGroup;
        
        # Default settings
        defaultNetwork = {
          enableIPv6 = cfg.defaultNetwork.enableIPv6;
          subnet = cfg.defaultNetwork.subnet;
        };
        
        # Podman daemon settings
        daemon = {
          cgroupManager = cfg.settings.cgroupManager;
          networkBackend = cfg.settings.networkBackend;
          storageDriver = cfg.settings.storageDriver;
        };
      };
    };
    
    # Additional container host features if enabled
    services = mkIf cfg.enableContainerHost {
      # Enable container registry if needed
      podman = {
        enable = true;
        # Enable Podman API service
        api = {
          enable = true;
          socket = true;
        };
      };
    };
    
    # Required packages
    environment.systemPackages = with pkgs; [
      podman
      podman-compose
      skopeo
      containers-common
    ];
    
    # Enable additional security features
    security = {
      polkit.enable = true;
      # Enable cgroups v2 for better container isolation
      # This is handled in systemd module
    };
  };
}