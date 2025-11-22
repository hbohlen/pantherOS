{ config, lib, ... }:

with lib;

let
  cfg = config.pantherOS.security.firewall;
in
{
  options.pantherOS.security.firewall = {
    enable = mkEnableOption "PantherOS advanced firewall configuration";
    
    enableImplicitNetwork = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to allow traffic on the local loopback and private networks by default";
    };
    
    allowPing = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow incoming ping requests";
    };
    
    trustTailscale = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to trust Tailscale interfaces completely";
    };
    
    trustedInterfaces = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of trusted network interfaces that have more permissions";
    };
    
    allowedTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of TCP ports to allow through the firewall";
    };
    
    allowedUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of UDP ports to allow through the firewall";
    };
    
    allowedTCPPortRanges = mkOption {
      type = types.listOf (types.submodule {
        options = {
          from = mkOption { type = types.port; };
          to = mkOption { type = types.port; };
        };
      });
      default = [ ];
      description = "List of TCP port ranges to allow through the firewall";
    };
    
    allowedUDPPortRanges = mkOption {
      type = types.listOf (types.submodule {
        options = {
          from = mkOption { type = types.port; };
          to = mkOption { type = types.port; };
        };
      });
      default = [ ];
      description = "List of UDP port ranges to allow through the firewall";
    };
    
    extraForwardRules = mkOption {
      type = types.lines;
      default = "";
      description = "Additional iptables rules for the forward chain";
    };
    
    logRefusedConnections = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to log refused connections";
    };
  };

  config = mkIf cfg.enable {
    # Advanced firewall configuration
    networking.firewall = {
      enable = true;
      enableIPv6 = true;  # Enable IPv6 firewall as well
      trustedInterfaces = 
        cfg.trustedInterfaces
        ++ (mkIf cfg.trustTailscale [ "tailscale0" ]);
      
      # Apply implicit network settings
      enableImplicitNetwork = cfg.enableImplicitNetwork;
      
      # Allow ping if configured
      allowPing = cfg.allowPing;
      
      # Additional ports
      allowedTCPPorts = cfg.allowedTCPPorts;
      allowedUDPPorts = cfg.allowedUDPPorts;
      
      # Port ranges
      allowedTCPPortRanges = cfg.allowedTCPPortRanges;
      allowedUDPPortRanges = cfg.allowedUDPPortRanges;
      
      # Log refused connections if configured
      logRefusedConnections = cfg.logRefusedConnections;
      
      # Additional forward rules
      extraFilterForward = cfg.extraForwardRules;
      
      # Additional security settings
      synFloodProtector = "systemd";
      stateFile = "/var/lib/nixos/state-firewall";
    };
    
    # Additional security hardening for the firewall
    boot = {
      kernel.sysctl = {
        # Protect against SYN flood attacks
        "net.ipv4.tcp_syncookies" = mkDefault 1;
        "net.ipv4.tcp_synack_retries" = mkDefault 5;
        "net.ipv4.tcp_max_syn_backlog" = mkDefault 4096;
        
        # IP spoofing protection
        "net.ipv4.conf.all.rp_filter" = mkDefault 1;
        "net.ipv4.conf.default.rp_filter" = mkDefault 1;
        
        # Ignore ICMP broadcasts to prevent broadcast attacks
        "net.ipv4.icmp_echo_ignore_broadcasts" = mkDefault 1;
        
        # Prevent against man in the middle attacks
        "net.ipv4.conf.all.accept_redirects" = mkDefault 0;
        "net.ipv4.conf.all.secure_redirects" = mkDefault 0;
        "net.ipv4.conf.all.send_redirects" = mkDefault 0;
        
        # Accepting source route can be used for attacks
        "net.ipv4.conf.all.accept_source_route" = mkDefault 0;
        "net.ipv6.conf.all.accept_ra" = mkDefault 0;
        "net.ipv6.conf.all.accept_redirects" = mkDefault 0;
      };
    };
  };
}