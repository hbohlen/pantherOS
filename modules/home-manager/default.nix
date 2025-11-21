{ config, lib, pkgs, ... }:

{
  imports = [
    ./shell
    ./applications
    ./development
    ./desktop
  ];

  # Home-manager modules are organized by category
  # Import specific modules as needed in host configurations
}