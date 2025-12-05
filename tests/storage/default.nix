{
  system ? builtins.currentSystem,
  # Accept pkgs and nix-unit from flake inputs
  pkgs ? import (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    ref = "nixos-unstable";
    rev = "2f9fb83df5782e0c1b95d3fa8cf9d3e9d5d8c3a5"; # Lock to a specific commit
  }) { inherit system; },
  nix-unit-src ? builtins.fetchGit {
    url = "https://github.com/nix-community/nix-unit";
    ref = "master";
    rev = "b8cd8a40f2a7f7a5c5e6e3d2f9a3c8e5f1d2b3a4"; # Lock to a specific commit
  }
}:

let
  inherit (pkgs) lib;
  # Import nix-unit as a library
  nix-unit-lib = pkgs.callPackage nix-unit-src {
    nixComponents = {
      inherit pkgs lib;
      nix-main = pkgs.nix;
      nix-store = pkgs.nix;
      nix-expr = pkgs.nix;
      nix-cmd = pkgs.nix;
      nix-flake = pkgs.nix;
    };
  };

  # Import test modules
  hardwareDetectionTests = import ./hardware-detection.nix { pkgs = pkgs; nix-unit = nix-unit-lib; };
  subvolumeTests = import ./subvolumes.nix { pkgs = pkgs; nix-unit = nix-unit-lib; };
  snapshotTests = import ./snapshots.nix { pkgs = pkgs; nix-unit = nix-unit-lib; };
  coverageGapTests = import ./coverage-gap-tests.nix { pkgs = pkgs; nix-unit = nix-unit-lib; };

  # Combine all tests into a single attribute set
  testSuite = hardwareDetectionTests // subvolumeTests // snapshotTests // coverageGapTests // {
    # Test metadata as an attribute
    meta = {
      description = "Storage Backup Foundation Unit Tests";
      license = "MIT";
    };
    # Global timeout setting
    timeout = 300; # 5 minutes per test suite
  };
in

# Wrap as a package so it can be built
pkgs.stdenv.mkDerivation {
  name = "storage-unit-tests";
  dontUnpack = true;
  buildInputs = [ nix-unit-lib ];
  buildPhase = ''
    # Run all tests from the combined test suite
    nix-unit run ${pkgs.writeText "test-suite.json" (builtins.toJSON testSuite)}
  '';
  # Tests succeed if the build phase succeeds
  doCheck = true;
  checkPhase = ''
    # Already running in build phase
  '';
}
