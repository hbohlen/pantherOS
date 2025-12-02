# modules/hardware/asus-rog.nix
# ASUS ROG laptop hardware support for NixOS
# Enables ASUS-specific tools, power management, and platform integration
#
# Source: https://github.com/NixOS/nixpkgs/tree/master/pkgs/tools/system/asusctl
#         https://wiki.archlinux.org/title/ASUS_ROG_utilities

{ config, lib, pkgs, facter, ... }:

with lib;

let
  cfg = config.hardware.asus;
  isFacterAvailable = facter != null && facter != { };
  isASUSROG = if isFacterAvailable then
    let
      system = attrByPath [ "hardware" "system" ] { } facter;
      manufacturer = system.manufacturer or "";
      product = system.product or "";
    in
    (hasPrefix "ASUS" manufacturer) || (hasInfix "ROG" product)
  else
    false;
in

{
  options.hardware.asus = {
    enable = mkOption {
      default = isASUSROG;
      type = types.bool;
      description = ''
        Enable ASUS ROG hardware support.
        Auto-detected from facter data if available.
      '';
    };

    asusc = mkOption {
      default = true;
      type = types.bool;
      description = "Enable asusctl for ASUS system control.";
    };

    powerProfiles = mkOption {
      default = true;
      type = types.bool;
      description = "Enable power-profiles-daemon for AC/battery profile management.";
    };

    enableBatteryThreshold = mkOption {
      default = 80;
      type = types.nullOr types.int;
      description = ''
        Set battery charge limit threshold (percentage).
        null to disable. Recommended: 80 for battery health.
      '';
    };

    enableKeyboardBacklight = mkOption {
      default = true;
      type = types.bool;
      description = "Enable keyboard backlight control.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enableBatteryThreshold == null || (cfg.enableBatteryThreshold > 0 && cfg.enableBatteryThreshold <= 100);
        message = "Battery threshold must be between 1 and 100, or null to disable.";
      }
    ];

    # System-level packages for ASUS hardware
    environment.systemPackages = with pkgs; [
      (mkIf cfg.asusc asusctl)
      (mkIf cfg.powerProfiles power-profiles-daemon)
      acpi  # Power state monitoring
      dmidecode  # System information detection
      lshw  # Detailed hardware listing
    ];

    # Power profiles daemon for AC/battery switching
    services.power-profiles-daemon = mkIf cfg.powerProfiles {
      enable = true;
    };

    # systemd service for asusctl (system control daemon)
    systemd.services.asusctl = mkIf cfg.asusc {
      description = "ASUS ROG System Control";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "dbus";
        BusName = "org.asusctl.service";
        ExecStart = "${pkgs.asusctl}/bin/asusctl";
        Restart = "on-failure";
      };
    };

    # Udev rules for battery charge limit control
    # TODO: Verify these paths work on all ASUS ROG models
    services.udev.rules = mkIf (cfg.enableBatteryThreshold != null) [
      ''
        # ASUS ROG Battery Charge Threshold Control
        # Allows non-root battery management
        SUBSYSTEM=="power_supply", ATTR{charge_control_end_threshold}!="", MODE="0644"
      ''
    ];

    # Allow unprivileged users to interact with power-profiles-daemon
    security.polkit.extraRules = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "net.hadess.PowerProfiles.ApplyProfile" ||
             action.id == "org.asusctl.service") &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';

    # Kernel modules for ASUS WMI (BIOS interface)
    boot.kernelModules = [
      "asus_nb_wmi"  # ASUS Notebook WMI interface
      "asus_wmi"     # ASUS WMI support
    ];

    # Boot parameters for optimal ASUS laptop performance
    boot.kernelParams = [
      # Power management
      "acpi_osi=Linux"
      # Disable PCIe ASPM for stability (ROG laptops often have issues with it)
      # Uncomment if you see power/stability issues:
      # "pcie_aspm=off"
    ];

    # Documentation
    environment.etc."asus-rog-config.md" = {
      mode = "0644";
      text = ''
        # ASUS ROG Configuration

        ## Enabled Features
        - ASUS Control (asusctl): ${if cfg.asusc then "enabled" else "disabled"}
        - Power Profiles Daemon: ${if cfg.powerProfiles then "enabled" else "disabled"}
        - Battery Threshold: ${if cfg.enableBatteryThreshold != null then "${toString cfg.enableBatteryThreshold}%" else "disabled"}
        - Keyboard Backlight: ${if cfg.enableKeyboardBacklight then "enabled" else "disabled"}

        ## Common Commands

        # Check ASUS control daemon status
        systemctl status asusctl

        # View/set power profile
        powerprofilesctl get
        powerprofilesctl set performance
        powerprofilesctl set balanced
        powerprofilesctl set power-saver

        # Check battery threshold
        cat /sys/class/power_supply/BAT*/charge_control_end_threshold

        # Set battery threshold (requires root or polkit authorization)
        echo 80 | tee /sys/class/power_supply/BAT*/charge_control_end_threshold

        # Get ASUS fan/thermal info
        asusctl --fan-mode

        ## Troubleshooting

        If asusctl fails to start:
        - Verify ASUS WMI kernel module is loaded: lsmod | grep asus
        - Check kernel logs: journalctl -xe
        - Try manual execution: asusctl --info
      '';
    };
  };
}
