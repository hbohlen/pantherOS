# modules/packages/dev/default.nix
{ pkgs, ... }:

{
  # Development tools - compilers, build tools, and development utilities
  environment.systemPackages = with pkgs; [
    # Development tools
    gcc
    gnumake
    pkg-config
  ];
}
