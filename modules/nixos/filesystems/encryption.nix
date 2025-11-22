{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.filesystems.encryption;
in
{
  options.pantherOS.filesystems.encryption = {
    enable = mkEnableOption "PantherOS filesystem encryption configuration";
    
    enableLUKS = mkOption {
      type = types.bool;
      default = false;
      description = "Enable LUKS encryption support";
    };
    
    enableStatelessEncryption = mkOption {
      type = types.bool;
      default = false;
      description = "Enable stateless encryption with TPM or SSH key unlocking";
    };
    
    enableImpermanenceWithEncryption = mkOption {
      type = types.bool;
      default = false;
      description = "Enable impermanence with encrypted root filesystem";
    };
    
    encryptionSettings = {
      enableRandomEncryption = mkOption {
        type = types.bool;
        default = false;
        description = "Enable random encryption for swap and temporary storage";
      };
      
      enableDataAtRestProtection = mkOption {
        type = types.bool;
        default = true;
        description = "Enable data-at-rest protection for persistent storage";
      };
      
      allowDiscarddeForLVM = mkOption {
        type = types.bool;
        default = true;
        description = "Allow TRIM/discard operations on LVM volumes";
      };
    };
    
    # Key management settings
    keySupport = {
      enableTPM = mkOption {
        type = types.bool;
        default = false;
        description = "Enable TPM-based key management";
      };
      
      enableSSHKeyUnlock = mkOption {
        type = types.bool;
        default = false;
        description = "Enable SSH key-based remote unlocking";
      };
      
      enableUSBKeyUnlock = mkOption {
        type = types.bool;
        default = false;
        description = "Enable USB key-based unlocking";
      };
    };
  };

  config = mkIf cfg.enable {
    # Filesystem encryption configuration
    environment.systemPackages = with pkgs; [
      cryptsetup
      lvm2
    ] ++ (mkIf cfg.keySupport.enableTPM [ tpm2-tss tpm2-tools ]);
    
    # LUKS encryption settings
    boot = mkIf cfg.enableLUKS {
      # Enable necessary kernel modules for encryption
      kernelModules = [ "dm-crypt" "aesni_intel" "cryptd" ];
      
      # Extra initrd modules for encrypted root
      initrd = {
        availableKernelModules = [ "dm-crypt" "aesni_intel" "cryptd" ];
        
        # Include necessary tools in initrd if needed
        luks = {
          devices = mkIf cfg.enableImpermanenceWithEncryption {
            # Configuration would go here based on disk setup
          };
        };
      };
      
      # Enable stateless encryption components if configured
      extraModulePackages = mkIf cfg.enableStatelessEncryption [ ];
    };
    
    # Encryption-related systemd services
    systemd = mkIf (cfg.keySupport.enableSSHKeyUnlock || cfg.keySupport.enableUSBKeyUnlock) {
      # Services for remote unlocking
      services = mkIf cfg.keySupport.enableSSHKeyUnlock {
        "cryptsetup-remote" = {
          enable = cfg.keySupport.enableSSHKeyUnlock;
          description = "Remote LUKS unlocking via SSH";
          wantedBy = [ "sysinit.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            TimeoutSec = "infinity";  # Wait indefinitely for unlock
          };
          
          script = ''
            #!/bin/sh
            # This would implement SSH-based remote unlocking
            # In practice, this requires special initramfs configuration
            # and is quite complex to implement securely
            echo "SSH-based remote unlocking would be implemented here"
          '';
        };
      };
    };
    
    # If using stateless encryption with TPM or SSH unlocking
    services = mkIf cfg.enableStatelessEncryption {
      # Additional services for key management
    };
    
    # If impermanence is combined with encryption
    services = mkIf cfg.enableImpermanenceWithEncryption {
      # Special handling for encrypted impermanence
      # This requires careful handling of keys and subvolume management
    };
    
    # Disk encryption settings
    boot = {
      # Random encryption for swap (if enabled)
      swapDevices = mkIf cfg.encryptionSettings.enableRandomEncryption [
        { device = "/dev/disk/by-label/swap"; randomEncryption = true; }
      ];
      
      # Configuration for encrypted persistent storage
      # This would typically be handled in disko configuration
      # but we'll provide a framework here
    };
    
    # Additional security settings for encrypted systems
    security = mkIf cfg.encryptionSettings.enableDataAtRestProtection {
      # Additional security hardening for encrypted systems
    };
    
    # Packages for managing encryption
    environment.systemPackages = with pkgs; [
      cryptsetup
      gnutls
      netcat  # Needed for remote unlocking
    ] ++ (mkIf cfg.keySupport.enableTPM [ tpm2-tss tpm2-tools ])
    ++ (mkIf cfg.keySupport.enableSSHKeyUnlock [ openssh ]);
  };
}