# Test runner for all disko layouts
# Validates that all disk layout modules can be evaluated without errors

{ pkgs, ... }:

{
  imports = [
    ./test-laptop-disk.nix
    ./test-dual-nvme-disk.nix
    ./test-server-disk.nix
  ];
}
