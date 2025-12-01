# tests/integration/default.nix
# Integration tests for NixOS configurations using nixosTest

{ self, nixpkgs, ... }:

let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  # Test that a basic NixOS system builds and boots (representing yoga config)
  yoga-basic = pkgs.testers.runNixOSTest {
    name = "yoga-basic-test";
    nodes.machine = { config, pkgs, ... }: {
      # Basic system setup similar to yoga
      environment.systemPackages = with pkgs; [ git curl fish ];
      services.openssh.enable = true;
      users.users.testuser = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
      # Override hardware config for testing
      hardware.enableAllFirmware = false;
      boot.loader.grub.enable = false;
      boot.loader.systemd-boot.enable = true;
      fileSystems."/" = {
        device = "/dev/vda1";
        fsType = "ext4";
      };
    };
    testScript = ''
      machine.start()
      machine.wait_for_unit("default.target")
      # Basic test: check that system is up
      machine.succeed("uname -a")
      # Test that some services are running
      machine.wait_for_unit("network.target")
      machine.wait_for_unit("sshd.service")
      # Test that packages are installed
      machine.succeed("which git")
      machine.succeed("which curl")
      machine.succeed("which fish")
    '';
  };

# Test that a basic NixOS system builds and boots (representing zephyrus config) - DISABLED due to CUDA dependencies
  # zephyrus-basic = pkgs.testers.runNixOSTest {
  #   name = "zephyrus-basic-test";
  #   nodes.machine = { config, pkgs, ... }: {
  #     # Basic system setup similar to zephyrus
  #     environment.systemPackages = with pkgs; [ git curl fish ];
  #     services.openssh.enable = true;
  #     users.users.testuser = {
  #       isNormalUser = true;
  #         extraGroups = [ "wheel" ];
  #     };
  #     # Override hardware config for testing
  #     hardware.enableAllFirmware = false;
  #     boot.loader.grub.enable = false;
  #     boot.loader.systemd-boot.enable = true;
  #     fileSystems."/" = {
  #       device = "/dev/vda1";
  #         fsType = "ext4";
  #     };
  #   };
  #   testScript = ''
  #     machine.start()
  #     machine.wait_for_unit("default.target")
  #     # Basic test: check that system is up
  #     machine.succeed("uname -a")
  #     # Test that some services are running
  #     machine.wait_for_unit("network.target")
  #     machine.wait_for_unit("sshd.service")
  #     # Test that packages are installed
  #     machine.succeed("which git")
  #     machine.succeed("which curl")
  #     machine.succeed("which fish")
  #   '';
  # };
}