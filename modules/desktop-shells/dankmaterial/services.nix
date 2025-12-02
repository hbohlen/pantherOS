# modules/desktop-shells/dankmaterial/services.nix
# System services integration for DankMaterialShell

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  config = mkIf (cfg.enable && cfg.enableServices) {
    # Core system services
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Control";
          Experimental = true;
        };
      };
    };

    networking.networkmanager = {
      enable = true;
      wifi = {
        backend = "iwd";
      };
    };

    services = {
      # Audio services
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse = {
          enable = true;
        };
        jack = {
          enable = false;
        };
        wireplumber.enable = true;
      };







      # Power management
      power-profiles-daemon = {
        enable = true;
      };

      upower = {
        enable = true;
      };

      # Location services
      geoclue2 = {
        enable = true;
      };

      # Display management
      auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            turbo = "never";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };
      };

      # Thermal management
      thermald = {
        enable = true;
      };

      # File systems
      gvfs = {
        enable = true;
      };

      udisks2 = {
        enable = true;
      };

      # Printing
      printing = {
        enable = true;
      };

      # Scanning
      avahi = {
        enable = true;
        nssmdns = true;
        openFirewall = true;
      };

      # Time synchronization
      chrony = {
        enable = true;
      };

      # System tray integration
      system-config-printer = {
        enable = true;
      };
    };

    # Required system packages
    environment.systemPackages = with pkgs; [
      # Audio tools
      pulseaudio
      pamixer
      pavucontrol
      easyeffects
      
      # Network tools
      networkmanager
      iwgtk
      blueman
      bluez-tools
      
      # Power management
      tlp
      auto-cpufreq
      power-profiles-daemon
      
      # System monitoring
      lm_sensors
      acpi
      htop
      btop
      
      # File management
      gvfs
      udisks2
      nfs-utils
      
      # Bluetooth
      bluez
      bluez-tools
      
      # Printing
      cups
      system-config-printer
      
      # Time and date
      chrony
      
      # Location services
      geoclue2
      
      # Display management
      kanshi
      wlr-randr
      
      # System utilities
      dbus
      polkit
      xdg-utils
    ];

    # User groups for hardware access
    users.groups = {
      audio = {};
      video = {};
      input = {};
      network = {};
      bluetooth = {};
      lp = {};
      scanner = {};
      disk = {};
    };

    # Systemd user services for DankMaterialShell integration
    systemd.user = {
      # Audio control service
      services.dankmaterial-audio = {
        description = "DankMaterialShell Audio Service";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" "pipewire.service" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScript "dankmaterial-audio" ''
            # Initialize audio settings for DankMaterialShell
            export PULSE_RUNTIME_PATH="/run/user/$(id -u)/pulse"
            
            # Set default audio profile
            ${pkgs.pulseaudio}/bin/pactl set-default-sink @DEFAULT_SINK@
            
            # Initialize volume
            ${pkgs.pamixer}/bin/pamixer --set-volume 50
            
            # Start audio monitoring
            while true; do
              # Update audio status for widgets
              ${pkgs.pamixer}/bin/pamixer --get-volume > /tmp/dankmaterial_volume
              sleep 2
            done
          ''}";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };

      # Network monitoring service
      services.dankmaterial-network = {
        description = "DankMaterialShell Network Service";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" "NetworkManager.service" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScript "dankmaterial-network" ''
            # Network monitoring for DankMaterialShell
            while true; do
              # Get Wi-Fi status
              WIFI_STATUS=$(${pkgs.iw}/bin/iw dev wlan0 link | grep 'Connected to' | cut -d' ' -f2 | tr -d ',')
              WIFI_SIGNAL=$(${pkgs.iw}/bin/iw dev wlan0 link | grep 'signal' | awk '{print $2}' | tr -d 'dBm')
              
              # Get Ethernet status
              ETH_STATUS=$(${pkgs.networkmanager}/bin/nmcli -t -f TYPE,DEVICE,STATE connection show --active | grep ethernet | cut -d: -f3)
              ETH_IP=$(${pkgs.networkmanager}/bin/nmcli -t -f IP4.ADDRESS device show eth0 | head -1)
              
              # Write status for widgets
              echo "WIFI:$WIFI_STATUS:$WIFI_SIGNAL" > /tmp/dankmaterial_network
              echo "ETH:$ETH_STATUS:$ETH_IP" >> /tmp/dankmaterial_network
              
              sleep 5
            done
          ''}";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };

      # Power monitoring service
      services.dankmaterial-power = {
        description = "DankMaterialShell Power Service";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" "upower.service" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScript "dankmaterial-power" ''
            # Power monitoring for DankMaterialShell
            while true; do
              # Get battery status
              BATTERY_LEVEL=$(${pkgs.acpi}/bin/acpi -b | grep -P -o '[0-9]+(?=%)')
              BATTERY_STATUS=$(${pkgs.acpi}/bin/acpi -b | grep -o 'Charging\|Discharging\|Full\|Unknown')
              
              # Get temperature
              TEMP=$(${pkgs.lm_sensors}/bin/sensors | grep 'Core 0' | awk '{print $3}' | tr -d '+°C')
              
              # Write status for widgets
              echo "BATTERY:$BATTERY_LEVEL:$BATTERY_STATUS" > /tmp/dankmaterial_power
              echo "TEMP:$TEMP" >> /tmp/dankmaterial_power
              
              sleep 10
            done
          ''}";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };

      # System monitoring service
      services.dankmaterial-system = {
        description = "DankMaterialShell System Service";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScript "dankmaterial-system" ''
            # System monitoring for DankMaterialShell
            while true; do
              # Get CPU usage
              CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
              
              # Get memory usage
              MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
              
              # Get disk usage
              DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
              
              # Write status for widgets
              echo "CPU:$CPU_USAGE" > /tmp/dankmaterial_system
              echo "MEMORY:$MEMORY_USAGE" >> /tmp/dankmaterial_system
              echo "DISK:$DISK_USAGE" >> /tmp/dankmaterial_system
              
              sleep 3
            done
          ''}";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };
    };

    # D-Bus configuration for DankMaterialShell
    services.dbus = {
      enable = true;
      packages = with pkgs; [
        cfg.package
      ];
    };

    # Polkit configuration
    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.policykit.exec" &&
              subject.user == subject.user) {
            return polkit.Result.YES;
          }
        });
      '';
    };
  };
}