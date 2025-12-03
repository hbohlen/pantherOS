{
  # Server metadata for Contabo Cloud VPS 40
  # 12 vCPU Cores, 48 GB RAM, 250 GB NVMe

  # Basic server information
  hostname = "contabo-vps";
  description = "Contabo Cloud VPS 40 - Development Server";

  # Hardware specifications (to be updated after running setup script)
  hardware = {
    cpu = {
      cores = 12;
      type = "QEMU KVM Virtual";
    };
    memory = {
      gb = 48;
    };
    storage = {
      size = "250GB";
      type = "NVMe";
    };
  };

  # Deployment information
  deployment = {
    provider = "contabo";
    region = "unknown"; # Update after connecting to server
    ipv4 = "unknown"; # Update after server is active
  };

  # System configuration
  system = {
    platform = "x86_64-linux";
    bootType = "unknown"; # Will be detected as BIOS or UEFI via facter
  };
}
