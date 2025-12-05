{ self, nixpkgs }:

let
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; };

  # Import all integration test modules
  laptopProfileTest = import ./laptop-profile.nix { inherit pkgs; };
  serverProfileTest = import ./server-profile.nix { inherit pkgs; };
  snapshotWorkflowTest = import ./snapshot-workflow.nix { inherit pkgs; };

in

{
  storage-integration-tests = pkgs.nixosTest {
    name = "storage-integration-tests";

    nodes = {
      laptop-test = {
        pkgs,
        imports = [
          ../../modules/storage/profiles/yoga.nix
        ];
        storage.disks.laptop = {
          enable = true;
          device = "/dev/vda";
        };
      };

      server-test = {
        pkgs,
        imports = [
          ../../modules/storage/profiles/hetzner.nix
        ];
        storage.disks.server = {
          enable = true;
          device = "/dev/vda";
          size = "458GB";
        };
      };
    };

    testScript = ''
      # Laptop profile test
      laptop_test = laptop-test
      laptop_test.wait_for_unit("multi-user.target")
      laptop_test.succeed("test -d /nix")
      laptop_test.succeed("test -d /home")
      print("✓ Laptop profile integration test passed")

      # Server profile test
      server_test = server-test
      server_test.wait_for_unit("multi-user.target")
      server_test.succeed("test -d /var/lib/containers")
      print("✓ Server profile integration test passed")

      print("All storage integration tests passed")
    '';

    metadata = {
      description = "Storage Integration Tests";
      maintainers = [ "admin@hbohlen.systems" ];
    };
  };
}
