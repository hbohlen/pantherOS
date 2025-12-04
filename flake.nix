# flake.nix
{
  description = "NixOS configuration for Hetzner Cloud VPS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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

    # Hercules CI - Continuous Integration for Nix
    hercules-ci-agent = {
      url = "github:hercules-ci/hercules-ci-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Attic - Nix binary cache server
    attic = {
      url = "github:zhaofengli/attic";
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
      hercules-ci-agent,
      attic,
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
          hercules-ci-agent.nixosModules.agent-service
          attic.nixosModules.atticd
          ./hosts/servers/hetzner-vps/hardware.nix
          ./hosts/servers/hetzner-vps/default.nix
          ./hosts/servers/hetzner-vps/disko.nix
          { nixpkgs.pkgs = pkgs; }
        ];
        specialArgs = { inherit lib; };
      };

      nixosConfigurations.ovh-vps = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          opnix.nixosModules.default
          ./hosts/servers/ovh-vps/hardware.nix
          ./hosts/servers/ovh-vps/default.nix
          ./hosts/servers/ovh-vps/disko.nix
          { nixpkgs.pkgs = pkgs; }
        ];
        specialArgs = { inherit lib; };
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
          { nixpkgs.pkgs = pkgs; }
        ];
        specialArgs = { inherit lib; };
      };

      nixosConfigurations.zephyrus = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          opnix.nixosModules.default
          home-manager.nixosModules.home-manager
          nixos-facter-modules.nixosModules.facter
          DankMaterialShell.nixosModules.dankMaterialShell
          # niri.nixosModules.niri # Conflict with local module
          { config.facter.reportPath = ./hosts/zephyrus/zephyrus-facter.json; }
          ./hosts/zephyrus/default.nix
          { nixpkgs.pkgs = pkgs; }
        ];
        specialArgs = { inherit lib; };
      };



       devShells.${system}.default = pkgs.mkShell {
         buildInputs = with pkgs; [
           # Nix Language Servers and Formatters (existing)
           nil
           nixd
           nixpkgs-fmt
           nixfmt-rfc-style
           alejandra
           
           # Build and Test Tools
           nix-tree
           git
           
           # NixOS Development Tools
           nix-diff      # Compare derivations
           nix-info      # System information
           nix-index     # Package searching
           nix-du        # Disk usage analysis
           
           # Code Quality Tools
           statix        # Nix linting
           deadnix       # Dead code detection
           shellcheck    # Shell script validation
           
           # Documentation and Exploration
           manix         # Nix function documentation
           nix-doc       # Inline documentation for Nix
           
           # Deployment and Testing
           nixos-rebuild
           nix-unit.packages.${system}.default  # Unit testing for Nix
         ];

         shellHook = ''
           echo "╔════════════════════════════════════════════════════════════╗"
           echo "║           pantherOS Development Environment               ║"
           echo "╚════════════════════════════════════════════════════════════╝"
           echo ""
           echo "📦 Build Tools:"
           echo "  • nixos-rebuild - Build and switch NixOS configurations"
           echo "  • nix-tree      - Visualize dependency trees"
           echo "  • nix-diff      - Compare derivations"
           echo "  • nix-du        - Analyze disk usage"
           echo ""
           echo "🔍 Development Tools:"
           echo "  • nil, nixd     - Language servers"
           echo "  • nix-index     - Package search"
           echo "  • nix-info      - System information"
           echo "  • manix         - Nix function docs"
           echo ""
           echo "✨ Code Quality:"
           echo "  • nixpkgs-fmt, nixfmt-rfc-style, alejandra - Formatters"
           echo "  • statix        - Nix linter"
           echo "  • deadnix       - Dead code detection"
           echo "  • shellcheck    - Shell script validation"
           echo ""
           echo "🧪 Testing:"
           echo "  • nix-unit      - Unit testing framework"
           echo ""
           echo "💡 Quick Commands:"
           echo "  • nixos-rebuild build - Build config without switching"
           echo "  • nix flake check     - Run all checks"
           echo "  • statix check .      - Lint Nix files"
           echo "  • deadnix -e .        - Find dead code"
           echo ""
         '';
       };

       # Integration tests using nixosTest
       checks.${system} = import ./tests/integration/default.nix { inherit self nixpkgs; };
     };
}
