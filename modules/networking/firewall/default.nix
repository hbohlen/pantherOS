{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.firewall;
in {
  options.networking.firewall = {
    enable = mkEnableOption "Enable advanced firewall and networking configuration";

    # Firewall configuration
    enabled = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the firewall";
    };

    # Allowed ports
    allowedTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [ 22 80 443 ];
      description = "List of allowed TCP ports";
    };

    allowedUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [];
      description = "List of allowed UDP ports";
    };

    # Traffic rules
    rules = {
      allowSSH = mkOption {
        type = types.bool;
        default = true;
        description = "Allow SSH traffic";
      };

      allowHTTP = mkOption {
        type = types.bool;
        default = true;
        description = "Allow HTTP traffic";
      };

      allowHTTPS = mkOption {
        type = types.bool;
        default = true;
        description = "Allow HTTPS traffic";
      };

      allowDNS = mkOption {
        type = types.bool;
        default = true;
        description = "Allow DNS traffic";
      };
    };

    # Security settings
    security = {
      enableRateLimiting = mkOption {
        type = types.bool;
        default = true;
        description = "Enable rate limiting for connections";
      };

      blockInvalidPackets = mkOption {
        type = types.bool;
        default = true;
        description = "Block invalid packets";
      };

      logBlocked = mkOption {
        type = types.bool;
        default = true;
        description = "Log blocked connection attempts";
      };
    };
  };

  config = mkIf cfg.enabled {
    # System packages
    environment.systemPackages = with pkgs; [
      iptables
      nftables
      conntrack-tools
      tcpdump
      wireshark-cli
    ];

    # Firewall configuration
    networking.firewall = {
      enable = true;
      allowedTCPPorts = cfg.allowedTCPPorts;
      allowedUDPPorts = cfg.allowedUDPPorts;
    };

    # Enhanced firewall rules via iptables
    systemd.services.iptables-restore = {
      wantedBy = [ "network.target" ];
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.writeScript "iptables-setup" ''
          #!/bin/sh
          iptables -F INPUT
          iptables -F OUTPUT
          iptables -F FORWARD

          # Set default policies
          iptables -P INPUT DROP
          iptables -P FORWARD DROP
          iptables -P OUTPUT ACCEPT

          # Allow loopback
          iptables -A INPUT -i lo -j ACCEPT
          iptables -A OUTPUT -o lo -j ACCEPT

          # Allow established connections
          iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

          ${optionalString cfg.rules.allowSSH ''
          # Allow SSH
          iptables -A INPUT -p tcp --dport 22 -j ACCEPT
          ''}

          ${optionalString cfg.rules.allowHTTP ''
          # Allow HTTP
          iptables -A INPUT -p tcp --dport 80 -j ACCEPT
          ''}

          ${optionalString cfg.rules.allowHTTPS ''
          # Allow HTTPS
          iptables -A INPUT -p tcp --dport 443 -j ACCEPT
          ''}

          ${optionalString cfg.rules.allowDNS ''
          # Allow DNS
          iptables -A INPUT -p udp --dport 53 -j ACCEPT
          iptables -A INPUT -p tcp --dport 53 -j ACCEPT
          ''}

          ${optionalString cfg.security.logBlocked ''
          # Log dropped packets
          iptables -A INPUT -j LOG --log-prefix "iptables-dropped: "
          ''}
        ''}";
      };
    };

    # Rate limiting configuration
    systemd.services.rate-limit-setup = {
      wantedBy = [ "network.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.writeScript "rate-limit-setup" ''
          #!/bin/sh
          ${optionalString cfg.security.enableRateLimiting ''
          # Enable connection tracking
          modprobe nf_conntrack

          # Rate limit SSH (5 connections per minute)
          iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
          iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 5 -j DROP
          ''}
        ''}";
      };
    };
  };
}
