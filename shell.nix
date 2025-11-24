{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nil
    nixd
    nixpkgs-fmt
    nix-tree
    git
  ];

  shellHook = ''
    echo "Development environment for pantherOS"
    echo "Available tools: nil, nixd, nixpkgs-fmt, nix-tree, git"
  '';
}