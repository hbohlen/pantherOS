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
  };
}
