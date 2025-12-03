# tests/unit/completions-test.nix
# Unit tests for Fish shell completions module

{ lib, pkgs }:

{
  # Test that the module can be imported without errors
  testCompletionsModuleImports = {
    expr = builtins.isAttrs (import ../../modules/home-manager/completions/default.nix);
    expected = true;
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
