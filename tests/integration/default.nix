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

  # Test Hercules CI module configuration (manual mode)
  hercules-ci-module = pkgs.testers.runNixOSTest {
    name = "hercules-ci-module-test";
    nodes.machine = { config, pkgs, ... }: {
      imports = [ ../../modules ];
      
      # Enable CI with Hercules CI (manual secret management)
      services.ci = {
        enable = true;
        herculesCI = {
          enable = true;
          clusterJoinTokenPath = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
          binaryCachesPath = "/var/lib/hercules-ci-agent/secrets/binary-caches.json";
          # opnix.enable is false by default
        };
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
      
      # Test that the Hercules CI service configuration is present
      machine.succeed("systemctl list-unit-files | grep hercules-ci-agent")
      
      # Test that documentation was created
      machine.succeed("test -f /etc/hercules-ci/README")
      
      # Test that the secrets directory was created with correct permissions
      machine.succeed("test -d /var/lib/hercules-ci-agent/secrets")
      machine.succeed("[ $(stat -c '%a' /var/lib/hercules-ci-agent/secrets) = '700' ]")
      
      # Verify documentation mentions manual setup (OpNix disabled)
      machine.succeed("grep -q 'Manual Setup Instructions' /etc/hercules-ci/README")
    '';
  };

  # Test Hercules CI module with OpNix integration
  hercules-ci-opnix = pkgs.testers.runNixOSTest {
    name = "hercules-ci-opnix-test";
    nodes.machine = { config, pkgs, ... }: {
      imports = [ ../../modules ];
      
      # Enable CI with Hercules CI and OpNix integration
      services.ci = {
        enable = true;
        herculesCI = {
          enable = true;
          opnix = {
            enable = true;
            clusterJoinTokenReference = "op://pantherOS/hercules-ci/cluster-join-token";
            binaryCachesReference = "op://pantherOS/hercules-ci/binary-caches";
          };
        };
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
      
      # Test that the Hercules CI service configuration is present
      machine.succeed("systemctl list-unit-files | grep hercules-ci-agent")
      
      # Test that documentation was created
      machine.succeed("test -f /etc/hercules-ci/README")
      
      # Test that the secrets directory was created with correct permissions
      machine.succeed("test -d /var/lib/hercules-ci-agent/secrets")
      machine.succeed("[ $(stat -c '%a' /var/lib/hercules-ci-agent/secrets) = '700' ]")
      
      # Verify documentation mentions OpNix provisioning
      machine.succeed("grep -q 'OpNix Secret Provisioning' /etc/hercules-ci/README")
      machine.succeed("grep -q 'op://pantherOS/hercules-ci/cluster-join-token' /etc/hercules-ci/README")

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
