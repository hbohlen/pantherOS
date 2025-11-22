{ config, lib, ... }:

with lib;

let
  cfg = config.pantherOS.core.base;
in
{
  options.pantherOS.core.base = {
    enable = mkEnableOption "PantherOS base system configuration";
    
    timeZone = mkOption {
      type = types.str;
      default = "UTC";
      description = "System timezone";
    };
    
    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "System locale";
    };
    
    console = {
      font = mkOption {
        type = types.str;
        default = "Lat2-Terminus16";
        description = "Console font";
      };
      keyMap = mkOption {
        type = types.str;
        default = "us";
        description = "Console keymap";
      };
    };
  };

  config = mkIf cfg.enable {
    # Basic system configuration
    environment.systemPackages = with pkgs; [
      cacert
      curl
      git
      vim
      htop
      iotop
      iostat
      tree
      unzip
      zip
      rsync
      openssh
    ];

    # Time zone and locale
    time.timeZone = cfg.timeZone;
    i18n.defaultLocale = cfg.locale;
    
    # Console settings
    console = {
      font = cfg.console.font;
      keyMap = cfg.console.keyMap;
    };
    
    # Basic system services
    services = {
      # Enable the OpenSSH daemon for remote access
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
      
      # Enable basic logging
      rsyslogd.enable = true;
      journald.extraConfig = ''
        SystemMaxUse=100M
        SystemMaxFileSize=10M
      '';
    };
    
    # System security settings
    security = {
      sudo.enable = true;
      sudo.wheelNeedsPassword = false;
    };
    
    # Basic networking
    networking = {
      networkmanager.enable = true;
      firewall.enable = true;
    };
  };
}