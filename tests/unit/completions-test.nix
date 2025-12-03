# tests/unit/completions-test.nix
# Unit tests for Fish shell completions module

{ lib, pkgs, home-manager ? null }:

let
  # Mock config for testing
  mockConfig = {
    xdg.cacheHome = "/home/testuser/.cache";
  };

  # Import completions module
  completionsModule = import ../../modules/home-manager/completions/default.nix {
    inherit lib pkgs;
    config = mockConfig;
  };

  # Helper function to check if option exists
  hasOption = path: builtins.hasAttr path completionsModule.options.programs.fish.completions;
in
{
  # Test that completions module defines the expected options
  testCompletionsModuleHasEnableOption = {
    expr = hasOption "enable";
    expected = true;
  };

  testCompletionsModuleHasOpencodeOption = {
    expr = hasOption "opencode";
    expected = true;
  };

  testCompletionsModuleHasOpenagentOption = {
    expr = hasOption "openagent";
    expected = true;
  };

  testCompletionsModuleHasSystemManagementOption = {
    expr = hasOption "systemManagement";
    expected = true;
  };

  testCompletionsModuleHasContainerOption = {
    expr = hasOption "container";
    expected = true;
  };

  testCompletionsModuleHasDevelopmentOption = {
    expr = hasOption "development";
    expected = true;
  };

  testCompletionsModuleHasCachingOption = {
    expr = hasOption "caching";
    expected = true;
  };

  # Test default values
  testCachingTimeoutDefaultIs300 = {
    expr = completionsModule.options.programs.fish.completions.caching.cacheTimeout.default;
    expected = 300;
  };

  # Test that completion files exist
  testOpencodeCompletionFileExists = {
    expr = builtins.pathExists ../../modules/home-manager/completions/files/opencode.fish;
    expected = true;
  };

  testOpenagentCompletionFileExists = {
    expr = builtins.pathExists ../../modules/home-manager/completions/files/openagent.fish;
    expected = true;
  };

  testNixCompletionFileExists = {
    expr = builtins.pathExists ../../modules/home-manager/completions/files/nix.fish;
    expected = true;
  };

  testSystemdCompletionFileExists = {
    expr = builtins.pathExists ../../modules/home-manager/completions/files/systemd.fish;
    expected = true;
  };

  testPodmanCompletionFileExists = {
    expr = builtins.pathExists ../../modules/home-manager/completions/files/podman.fish;
    expected = true;
  };

  testGitCompletionFileExists = {
    expr = builtins.pathExists ../../modules/home-manager/completions/files/git.fish;
    expected = true;
  };

  testZellijCompletionFileExists = {
    expr = builtins.pathExists ../../modules/home-manager/completions/files/zellij.fish;
    expected = true;
  };
}
