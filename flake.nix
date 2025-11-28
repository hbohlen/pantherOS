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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules = {
      url = "github:nix-community/nixos-facter-modules";
      # inputs.nixpkgs.follows = "nixpkgs";  # Commented out to fix flake check
    };
    nix-ai-tools = {
      url = "github:numtide/nix-ai-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DankMaterialShell - Material design shell configuration
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    DankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dgop.follows = "dgop";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      opnix,
      home-manager,
      nixvim,
      nixos-facter-modules,
      nix-ai-tools,
      dgop,
      DankMaterialShell,
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          (final: prev: {
            opencode = nix-ai-tools.packages.${system}.opencode;
          })
        ];
      };
    in
    {
      nixosConfigurations.hetzner-vps = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          opnix.nixosModules.default
          home-manager.nixosModules.home-manager
          ./hosts/servers/hetzner-vps/hardware.nix
          ./hosts/servers/hetzner-vps/default.nix
          ./hosts/servers/hetzner-vps/disko.nix
        ];
        specialArgs = { inherit lib pkgs; };
      };

      nixosConfigurations.ovh-vps = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          opnix.nixosModules.default
          ./hosts/servers/ovh-vps/hardware.nix
          ./hosts/servers/ovh-vps/default.nix
          ./hosts/servers/ovh-vps/disko.nix
        ];
        specialArgs = { inherit lib pkgs; };
      };

      nixosConfigurations.yoga = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # disko.nixosModules.disko  # Commented out for configuration testing
          opnix.nixosModules.default
          home-manager.nixosModules.home-manager
          nixos-facter-modules.nixosModules.facter
          nixvim.nixosModules.nixvim
          DankMaterialShell.nixosModules.default
          { config.facter.reportPath = ./hosts/zephyrus/zephyrus-facter.json; }
          ./hosts/zephyrus/default.nix
          # ./hosts/zephyrus/disko.nix  # Commented out for configuration testing
        ];
        specialArgs = { inherit lib pkgs; };
      };

      nixosConfigurations.zephyrus = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # disko.nixosModules.disko  # Commented out for configuration testing
          opnix.nixosModules.default
          home-manager.nixosModules.home-manager
          nixos-facter-modules.nixosModules.facter
          nixvim.nixosModules.nixvim
          DankMaterialShell.nixosModules.dankMaterialShell
          { config.facter.reportPath = ./hosts/zephyrus/zephyrus-facter.json; }
          ./hosts/zephyrus/default.nix
          # ./hosts/zephyrus/disko.nix  # Commented out for configuration testing
        ];
        specialArgs = { inherit lib pkgs; };
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
