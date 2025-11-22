{ config, lib, pkgs, ... }:

{
  imports = [
    ./1password-service.nix
    ./opnix-integration.nix
    ./secrets-mapping.nix
  ];
}
