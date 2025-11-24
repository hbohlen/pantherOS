# flake.nix
{
  description = "NixOS configuration for Hetzner Cloud VPS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, opnix, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.hetzner-vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          opnix.nixosModules.default
          ./hosts/servers/hetzner-vps/hardware.nix
          ./hosts/servers/hetzner-vps/configuration.nix
          ./hosts/servers/hetzner-vps/disko.nix
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
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
      };
    };
}
