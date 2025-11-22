{
  description = "pantherOS - Declarative NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, nixos-hardware, home-manager, ... }: {
    nixosConfigurations = {
      # Yoga - Lenovo Yoga 7 2-in-1 (battery-optimized, lightweight development)
      yoga = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/yoga
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hbohlen = ./home/hbohlen/default.nix;
          }
        ];
      };

      # Zephyrus - ASUS ROG Zephyrus M16 (performance workstation, heavy development workflows)
      zephyrus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/zephyrus
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hbohlen = ./home/hbohlen/default.nix;
          }
        ];
      };

      # Hetzner VPS - Hetzner Cloud VPS (primary development server)
      hetzner-vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/servers/hetzner-vps
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hbohlen = ./home/hbohlen/default.nix;
          }
        ];
      };

      # OVH Cloud VPS - OVH Cloud VPS (secondary server)
      ovh-vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/servers/ovh-cloud
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hbohlen = ./home/hbohlen/default.nix;
          }
        ];
      };
    };

    # Development shell for working on the configuration
    devShells.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
      buildInputs = [
        nix
        git
        home-manager
        disko.packages.x86_64-linux.disko
        nixos-rebuild
        nixos-generators
        nil
        nixfmt
      ];
      
      shellHook = ''
        echo "pantherOS Development Environment"
        echo "================================="
        echo ""
        echo "Available tools:"
        echo "- nix, nixos-rebuild, git"
        echo "- home-manager, disko"
        echo "- nil (Nix language server)"
        echo "- nixfmt (formatter)"
        echo ""
        echo "To test a configuration: nixos-rebuild build --flake .#<hostname>"
        echo "To enter a Nix shell in this directory: nix develop"
      '';
    };
  };
}