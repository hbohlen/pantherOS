{ config, lib, ... }:

with lib;

let
  cfg = config.pantherOS.core.networking;
in
{
  options.pantherOS.core.networking = {
    enable = mkEnableOption "PantherOS basic network configuration";
    
    networkmanager = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NetworkManager for network management";
      };
    };
    
    firewall = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable firewall configuration";
      };
      allowedTCPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "List of allowed TCP ports";
      };
      allowedUDPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "List of allowed UDP ports";
      };
      trustedInterfaces = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of trusted network interfaces";
      };
    };
    
    hostName = mkOption {
      type = types.str;
      default = "";
      description = "Hostname for the system";
    };
    
    domain = mkOption {
      type = types.str;
      default = "";
      description = "Domain name for the system";
    };
  };

  config = mkIf cfg.enable {
    # Network configuration
    networking = {
      # Set hostname and domain if provided
      hostName = mkIf (cfg.hostName != "") (mkDefault cfg.hostName);
      domain = mkIf (cfg.domain != "") (mkDefault cfg.domain);
      
      # NetworkManager for dynamic network configuration
      networkmanager = mkIf cfg.networkmanager.enable {
        enable = cfg.networkmanager.enable;
        # Disable DNS management by NetworkManager to avoid conflicts
        dns = "none";
      };
      
      # Firewall configuration
      firewall = mkIf cfg.firewall.enable {
        enable = cfg.firewall.enable;
        allowedTCPPorts = cfg.firewall.allowedTCPPorts;
        allowedUDPPorts = cfg.firewall.allowedUDPPorts;
        trustedInterfaces = cfg.firewall.trustedInterfaces;
        
        # Default to blocking everything except established connections
        enableSynFloodProtect = true;
        logRefusedConnections = false;
      };
      
      # Enable predictable network interface names
      usePredictableInterfaceNames = true;
      
      # Basic DNS configuration
      nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" "1.0.0.1" ];
    };
  };
}