{ config, lib, ... }:

with lib;

let
  cfg = config.pantherOS.services.ssh;
in
{
  options.pantherOS.services.ssh = {
    enable = mkEnableOption "PantherOS SSH service configuration";
    
    enableEnhancedSecurity = mkOption {
      type = types.bool;
      default = true;
      description = "Enable enhanced SSH security settings";
    };
    
    settings = {
      permitRootLogin = mkOption {
        type = types.enum [ "yes" "no" "without-password" "forced-commands-only" ];
        default = "no";
        description = "Whether root can log in through SSH";
      };
      
      passwordAuthentication = mkOption {
        type = types.bool;
        default = false;
        description = "Whether password authentication is allowed";
      };
      
      kbdInteractiveAuthentication = mkOption {
        type = types.bool;
        default = false;
        description = "Whether keyboard-interactive authentication is allowed";
      };
      
      allowAgentForwarding = mkOption {
        type = types.bool;
        default = false;
        description = "Whether agent forwarding is allowed";
      };
      
      allowTcpForwarding = mkOption {
        type = types.bool;
        default = true;
        description = "Whether TCP forwarding is allowed";
      };
      
      gatewayPorts = mkOption {
        type = types.enum [ "no" "yes" "clientspecified" ];
        default = "no";
        description = "Whether gateway ports are allowed";
      };
      
      x11Forwarding = mkOption {
        type = types.bool;
        default = false;
        description = "Whether X11 forwarding is allowed";
      };
      
      maxAuthTries = mkOption {
        type = types.int;
        default = 3;
        description = "Maximum number of authentication attempts";
      };
      
      clientAliveInterval = mkOption {
        type = types.int;
        default = 300;
        description = "Interval for checking if client is alive (seconds)";
      };
      
      clientAliveCountMax = mkOption {
        type = types.int;
        default = 3;
        description = "Maximum number of alive checks before disconnecting";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
        settings = mkMerge [
          {
            PermitRootLogin = cfg.settings.permitRootLogin;
            PasswordAuthentication = cfg.settings.passwordAuthentication;
            KbdInteractiveAuthentication = cfg.settings.kbdInteractiveAuthentication;
            AllowAgentForwarding = cfg.settings.allowAgentForwarding;
            AllowTcpForwarding = cfg.settings.allowTcpForwarding;
            GatewayPorts = cfg.settings.gatewayPorts;
            X11Forwarding = cfg.settings.x11Forwarding;
            MaxAuthTries = cfg.settings.maxAuthTries;
            ClientAliveInterval = cfg.settings.clientAliveInterval;
            ClientAliveCountMax = cfg.settings.clientAliveCountMax;
          }
          (mkIf cfg.enableEnhancedSecurity {
            # Additional security hardening settings
            Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr";
            MACs = "hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256,hmac-sha2-512,umac-128@openssh.com";
            KexAlgorithms = "curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256";
            PubkeyAcceptedKeyTypes = "ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa";
          })
        ];
      };
    };
    
    # Additional firewall configuration for SSH if needed
    networking.firewall = {
      allowedTCPPorts = [ 22 ];
      # Only allow SSH from specific interfaces if Tailscale is used
      # This can be extended based on specific security requirements
    };
  };
}