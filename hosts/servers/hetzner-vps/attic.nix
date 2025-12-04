# Attic Binary Cache Configuration for hetzner-vps
# Provides a private Nix binary cache using Backblaze B2 storage
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable Attic binary cache server
  services.ci.attic = {
    enable = true;

    # Listen on all interfaces
    listen = "[::]:8080";

    # Backblaze B2 storage configuration
    storage = {
      type = "s3";
      bucket = "pantherOS-nix-cache";
      region = "us-west-004";
      endpoint = "https://s3.us-west-004.backblazeb2.com";
    };

    # Enable OpNix integration for automatic secret management
    opnix = {
      enable = true;
      credentialsReference = "op://pantherOS/backblaze-b2/attic-credentials";
    };

    # Database configuration
    database = {
      url = "sqlite:///var/lib/atticd/server.db";
    };

    # Compression settings (zstd is fast and efficient)
    compression = {
      type = "zstd";
      level = 8;
    };
  };

  # Configure Nix to use the local Attic cache
  # Note: This requires setting up a cache first using atticd-atticadm
  # nix.settings = {
  #   substituters = [ "http://localhost:8080/pantherOS" ];
  #   trusted-public-keys = [ "pantherOS:..." ];  # Add your cache public key
  # };
}
