{ config, lib, ... }:

{
  imports = [
    ./server-impermanence.nix
    ./server-snapshots.nix
  ];
  
  config = {
    # Universal Btrfs mount options for servers
    fileSystems = {
      "/" = {
        options = [
          "compress=zstd:3"
          "noatime"
          "ssd"
          "space_cache=v2"
          "discard=async"
          "subvol=root"
        ];
      };
      
      "/nix" = {
        options = [
          "compress=zstd:1"
          "noatime"
          "ssd"
          "space_cache=v2"
          "discard=async"
          "subvol=nix"
        ];
      };
      
      "/persist" = {
        options = [
          "compress=zstd:3"
          "noatime"
          "ssd"
          "space_cache=v2"
          "discard=async"
          "subvol=persist"
        ];
      };
      
      "/var/log" = {
        options = [
          "compress=zstd:3"
          "noatime"
          "ssd"
          "space_cache=v2"
          "discard=async"
          "subvol=log"
        ];
      };
      
      "/var/lib/containers" = {
        options = [
          "compress=zstd:1"
          "noatime"
          "nodatacow"
          "nodatasum"
          "ssd"
          "space_cache=v2"
          "discard=async"
          "subvol=containers"
        ];
      };
    };
    
    # Enable Btrfs quota support for multi-tenant isolation
    services.btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/" ];
    };
  };
}