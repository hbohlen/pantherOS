{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.testing;
in {
  options.services.testing = {
    enable = mkEnableOption "Enable NixOS testing infrastructure";

    # Testing framework configuration
    framework = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable comprehensive test framework";
      };

      parallel = mkOption {
        type = types.bool;
        default = true;
        description = "Enable parallel test execution";
      };

      coverage = mkOption {
        type = types.bool;
        default = true;
        description = "Enable test coverage reporting";
      };
    };

    # Disko.nix testing
    disko = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable disko.nix testing framework";
      };

      vm = mkOption {
        type = types.bool;
        default = true;
        description = "Enable VM-based disko testing";
      };
    };

    # Integration tests
    integration = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable integration tests for hosts";
      };

      vmBased = mkOption {
        type = types.bool;
        default = true;
        description = "Use VM-based integration testing";
      };
    };

    # Validation tests
    validation = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable configuration validation tests";
      };

      syntax = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Nix syntax validation";
      };
    };

    # CI/CD integration
    ci = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable CI/CD integration";
      };

      fastTests = mkOption {
        type = types.bool;
        default = true;
        description = "Enable fast test suite for quick feedback";
      };
    };
  };

  config = mkIf cfg.enable {
    imports = [
      ./framework.nix
      ./disko.nix
      ./integration.nix
      ./validation.nix
    ];

    # Testing system packages
    environment.systemPackages = with pkgs; [
      # Test runners and frameworks
      pytest
      python3Packages.pytest-cov

      # VM and virtualization
      qemu
      libvirt
      virt-manager

      # NixOS testing
      nixos-generators
      nixos-tests

      # Validation tools
      nix-validate
      statix
      deadnix

      # Coverage and reporting
      gcovr
      lcov
    ];

    # Test directories structure
    system.activationScripts.create-test-dirs = ''
      if [ ! -d "/var/lib/tests" ]; then
        mkdir -p /var/lib/tests/{framework,disko,integration,validation}
        chmod 755 /var/lib/tests
      fi

      if [ ! -d "/etc/tests" ]; then
        mkdir -p /etc/tests/{configs,fixtures,reports}
        chmod 755 /etc/tests
      fi
    '';

    # Environment variables for testing
    environment.sessionVariables = {
      NIXOS_TEST_CONFIG = "/etc/tests/configs";
      NIXOS_TEST_DATA = "/var/lib/tests";
      PYTEST_CURRENT_TEST = "1";
    };

    # Documentation
    environment.etc."tests/README".text = ''
      # NixOS Testing Infrastructure

      This directory contains the testing infrastructure for the NixOS configuration.

      ## Test Structure

      - `framework/` - Core testing framework utilities
      - `disko/` - Disko partition testing
      - `integration/` - Host integration tests
      - `validation/` - Configuration validation tests

      ## Running Tests

      Run all tests:
        nix flake check

      Run disko tests:
        nix build .#tests.disko

      Run integration tests:
        nix build .#tests.integration

      Run validation tests:
        nix build .#tests.validation

      For more information, see the testing documentation.
    '';
  };
}
