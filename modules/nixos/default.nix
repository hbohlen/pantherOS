# PantherOS NixOS Modules Collection
# Aggregates all PantherOS-specific NixOS modules using a granular, modular structure

{
  # Core modules
  core = import ./core;

  # Service modules  
  services = import ./services;

  # Security modules
  security = import ./security;

  # Filesystem modules
  filesystems = import ./filesystems;

  # Hardware modules
  hardware = import ./hardware;
}