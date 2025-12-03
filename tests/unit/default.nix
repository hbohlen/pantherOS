# tests/unit/default.nix
# Unit tests for Nix functions using nix-unit

{ lib, pkgs ? null }:

let
  # Import completions tests if pkgs is provided
  completionsTests = if pkgs != null 
    then import ./completions-test.nix { inherit lib pkgs; }
    else {};
in
{
  # Test basic lib functions
  testLibAdd = {
    expr = lib.add 2 3;
    expected = 5;
  };

  testLibStrings = {
    expr = lib.strings.toUpper "hello";
    expected = "HELLO";
  };

  # Placeholder for custom function tests
  # Add tests for your custom Nix functions here
  # Example:
  # testMyFunction = {
  #   expr = myModule.myFunction "input";
  #   expected = "expected output";
  # };
} // completionsTests