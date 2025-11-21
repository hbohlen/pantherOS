{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../modules/shared/filesystems/server-btrfs.nix
  ];
  
  # Add server impermanence configuration
  pantherOS.serverImpermanence = {
    enable = true;
    performanceMode = "io-optimized";  # Optimized for container/database workloads
    snapshotPolicy = {
      frequency = "6h";      # Every 6 hours
      retention = "30d";     # 30-day retention
      scope = "critical";     # Critical subvolumes only
    };
  };
  
  # Basic server configuration will be expanded in later tasks
  system.stateVersion = "24.05";
}