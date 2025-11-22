{ config, lib, ... }:

with lib;

let
  cfg = config.pantherOS.security.ssh;
in
{
  options.pantherOS.security.ssh = {
    enable = mkEnableOption "PantherOS SSH security hardening";
    
    settings = {
      # Basic security settings
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
      
      # Additional security settings
      usePAM = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to use PAM for authentication";
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
        default = 2;
        description = "Maximum number of authentication attempts";
      };
      
      maxSessions = mkOption {
        type = types.int;
        default = 10;
        description = "Maximum number of open sessions per connection";
      };
      
      clientAliveInterval = mkOption {
        type = types.int;
        default = 300;
        description = "Interval for checking if client is alive (seconds)";
      };
      
      clientAliveCountMax = mkOption {
        type = types.int;
        default = 2;
        description = "Maximum number of alive checks before disconnecting";
      };
      
      # Cryptography settings
      ciphers = mkOption {
        type = types.listOf types.str;
        default = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];
        description = "Allowed ciphers for SSH encryption";
      };
      
      macs = mkOption {
        type = types.listOf types.str;
        default = [
          "hmac-sha2-256-etm@openssh.com"
          "hmac-sha2-512-etm@openssh.com"
          "umac-128-etm@openssh.com"
          "hmac-sha2-256"
          "hmac-sha2-512"
          "umac-128@openssh.com"
        ];
        description = "Allowed MAC algorithms";
      };
      
      kexAlgorithms = mkOption {
        type = types.listOf types.str;
        default = [
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group-exchange-sha256"
        ];
        description = "Allowed key exchange algorithms";
      };
      
      hostKeyAlgorithms = mkOption {
        type = types.listOf types.str;
        default = [
          "ssh-ed25519-cert-v01@openssh.com"
          "ssh-rsa-cert-v01@openssh.com"
          "ssh-ed25519"
          "ssh-rsa"
        ];
        description = "Allowed host key algorithms";
      };
    };
    
    # Fail2Ban settings for additional protection
    enableFail2Ban = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Fail2Ban for SSH protection";
    };
  };

  config = mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = cfg.settings.permitRootLogin;
          PasswordAuthentication = cfg.settings.passwordAuthentication;
          KbdInteractiveAuthentication = cfg.settings.kbdInteractiveAuthentication;
          UsePAM = cfg.settings.usePAM;
          AllowAgentForwarding = cfg.settings.allowAgentForwarding;
          AllowTcpForwarding = cfg.settings.allowTcpForwarding;
          GatewayPorts = cfg.settings.gatewayPorts;
          X11Forwarding = cfg.settings.x11Forwarding;
          MaxAuthTries = cfg.settings.maxAuthTries;
          MaxSessions = cfg.settings.maxSessions;
          ClientAliveInterval = cfg.settings.clientAliveInterval;
          ClientAliveCountMax = cfg.settings.clientAliveCountMax;
          
          # Advanced security settings
          Ciphers = concatStringsSep "," cfg.settings.ciphers;
          MACs = concatStringsSep "," cfg.settings.macs;
          KexAlgorithms = concatStringsSep "," cfg.settings.kexAlgorithms;
          HostKeyAlgorithms = concatStringsSep "," cfg.settings.hostKeyAlgorithms;
          
          # Additional security hardening
          PermitUserEnvironment = false;
          IgnoreUserKnownHosts = true;
          AllowUsers = mkDefault [ ];  # Configure per host if needed
          DenyUsers = mkDefault [ ];   # Configure per host if needed
          AllowGroups = mkDefault [ ]; # Configure per host if needed
          DenyGroups = mkDefault [ ];  # Configure per host if needed
        };
      };
      
      # Enable Fail2Ban for additional SSH protection
      fail2ban = mkIf cfg.enableFail2Ban {
        enable = cfg.enableFail2Ban;
        bantime-increment.enable = true;
        jails = {
          # Default SSH jail
          sshd = {
            filter = "sshd";
            logPath = "/var/log/auth.log";
            maxRetry = 3;
            bantime = "10m";
            findtime = "10m";
          };
        };
      };
    };
    
    # Additional SSH security configurations
    security.pam.services.sshd = {
      # Prevent users from changing their authentication methods
      text = ''
        auth       required     pam_securetty.so
        auth       requisite    pam_deny.so
        auth       required     pam_permit.so
        account    required     pam_permit.so
        session    required     pam_permit.so
      '';
    };
  };
}