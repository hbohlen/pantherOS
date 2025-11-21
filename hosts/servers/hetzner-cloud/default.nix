# hosts/servers/hetzner-cloud/default.nix
#
# Minimal NixOS configuration for Hetzner Cloud VPS
# Purpose: Personal development server with AI coding tools
# Access: Tailscale-only (no public SSH)
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Disk configuration
    ./disko.nix

    # Hardware configuration (generate with nixos-generate-config)
    ./hardware.nix

    # OpNix for 1Password secrets management
    inputs.opnix.nixosModules.default
  ];

  # ============================================
  # SYSTEM IDENTITY
  # ============================================
  networking.hostName = "hetzner-vps";

  # ============================================
  # BOOT CONFIGURATION
  # ============================================
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    efiSupport = true;
    efiInstallAsRemovable = true;  # Hetzner compatibility
  };

  # Placeholder - update after installation
  system.stateVersion = "24.05";
}
