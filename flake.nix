{
  description = "pantherOS - Comprehensive NixOS configuration";

  inputs = {
    # Nixpkgs - Base package collection
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager - User environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko - Declarative disk management
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OpNix - 1Password secrets for NixOS
    opnix = {
      url = "github:mrjones2014/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-ai-tools - AI coding tools
    nix-ai-tools = {
      url = "github:hraban/nix-ai-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , disko
    , opnix
    , nix-ai-tools
    }:
    {
      # NixOS configurations for each host
      nixosConfigurations = {
        yoga = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit opnix disko nix-ai-tools; };
          modules = [
            ./hosts/yoga/default.nix
            opnix.nixosModules.opnix
          ];
        };

        zephyrus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit opnix disko nix-ai-tools; };
          modules = [
            ./hosts/zephyrus/default.nix
            opnix.nixosModules.opnix
          ];
        };

        hetzner-vps = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit opnix disko nix-ai-tools; };
          modules = [
            ./hosts/servers/hetzner-vps/default.nix
            opnix.nixosModules.opnix
          ];
        };

        ovh-vps = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit opnix disko nix-ai-tools; };
          modules = [
            ./hosts/servers/ovh-vps/default.nix
            opnix.nixosModules.opnix
          ];
        };
      };

      # Home Manager configurations
      homeConfigurations = {
        "hbohlen@yoga" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit opnix; };
          modules = [
            ./home/hbohlen/default.nix
          ];
        };

        "hbohlen@zephyrus" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit opnix; };
          modules = [
            ./home/hbohlen/default.nix
          ];
        };

        "hbohlen@hetzner-vps" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit opnix; };
          modules = [
            ./home/hbohlen/default.nix
          ];
        };

        "hbohlen@ovh-vps" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit opnix; };
          modules = [
            ./home/hbohlen/default.nix
          ];
        };
      };

      # Development shell for working on the configuration
      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.callPackage ./shell.nix {
        inherit opnix nix-ai-tools;
      };

      # Package overlay for custom packages
      packages.x86_64-linux = import ./pkgs { inherit nixpkgs; };
    };
}
