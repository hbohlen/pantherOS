{ config, lib, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../../modules/shared/filesystems/server-btrfs.nix
  ];
  
  # Basic system configuration
  networking.hostName = "ovh-vps";
  
  # Add server impermanence configuration
  pantherOS.serverImpermanence = {
    enable = true;
    performanceMode = "balanced";  # Balanced for general use
    snapshotPolicy = {
      frequency = "12h";     # Every 12 hours
      retention = "30d";     # 30-day retention
      scope = "critical";    # Critical subvolumes only
    };
  };
  
  # Enable essential services for server
  pantherOS = {
    services = {
      ssh.enable = true;
      tailscale.enable = true;
    };
    
    security = {
      firewall.enable = true;
    };
  };
  
  # System state version
  system.stateVersion = "24.05";
}
