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

    nix-unit = {
      url = "github:nix-community/nix-unit";
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

    # Quickshell - required by DankMaterialShell
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Niri - scrollable-tiling Wayland window manager
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zed - high-performance code editor
    zed = {
      url = "github:zed-industries/zed";
      inputs.nixpkgs.follows = "nixpkgs";
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
      quickshell,
      niri,
      zed,
      nix-unit,
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
            # opencode = nix-ai-tools.packages.${system}.opencode;
            quickshell = quickshell.packages.${system}.default;
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
          disko.nixosModules.disko
          opnix.nixosModules.default
          home-manager.nixosModules.home-manager
          nixos-facter-modules.nixosModules.facter
           DankMaterialShell.nixosModules.dankMaterialShell
          niri.nixosModules.niri
          { config.facter.reportPath = ./hosts/yoga/yoga-facter.json; }
          ./hosts/yoga/default.nix
        ];
        specialArgs = { inherit lib pkgs; };
      };

# Only include zephyrus if explicitly requested (to avoid CUDA dependencies on other hosts)
      # nixosConfigurations.zephyrus = lib.nixosSystem {
      #   { config.facter.reportPath = ./hosts/zephyrus/zephyrus-facter.json; }
      #   ./hosts/zephyrus/default.nix
      # };

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

       # Integration tests using nixosTest
       checks.${system} = import ./tests/integration/default.nix { inherit self nixpkgs; };
     };
}
