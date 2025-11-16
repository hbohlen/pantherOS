{
  description = "PantherOS - NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko.url = "github:nix-community/disko";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
    opnix.url = "github:brizzbuzz/opnix";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, disko, nix-ai-tools, opnix, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { 
      inherit system; 
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.ovh-cloud = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/servers/ovh-cloud/configuration.nix
        disko.nixosModules.default
        # Temporarily disabled for initial deployment to reduce closure size
        # opnix.nixosModules.default
        # home-manager.nixosModules.home-manager {
        #   home-manager.users.hbohlen = ./hosts/servers/ovh-cloud/home.nix;
        #   home-manager.useGlobalPkgs = true;
        #   home-manager.useUserPackages = true;
        # }
      ];
    };

    nixosConfigurations.hetzner-cloud = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/servers/hetzner-cloud/configuration.nix
        disko.nixosModules.default
        # Temporarily disabled for initial deployment to reduce closure size
        # opnix.nixosModules.default
        # home-manager.nixosModules.home-manager {
        #   home-manager.users.hbohlen = ./hosts/servers/hetzner-cloud/home.nix;
        #   home-manager.useGlobalPkgs = true;
        #   home-manager.useUserPackages = true;
        # }
      ];
    };

    # Development shells for different project types
    devShells.${system} = {
      default = pkgs.mkShell {
        packages = with pkgs; [
          git
          neovim
          fish
          starship
          direnv
          nil
          nixpkgs-fmt
        ];
      };

      nix = pkgs.mkShell {
        packages = with pkgs; [
          nix
          nil
          nixpkgs-fmt
          nix-init
          nix-eval-lsp
          git
          neovim
        ];
      };

      rust = pkgs.mkShell {
        packages = with pkgs; [
          rustup
          cargo
          rust-analyzer
          clippy
          bindgen
          cbindgen
          git
          neovim
        ];
      };

      node = pkgs.mkShell {
        packages = with pkgs; [
          nodejs-18_x
          nodejs-20_x
          yarn
          pnpm
          npm-9_x
          git
          neovim
        ];
      };

      python = pkgs.mkShell {
        packages = with pkgs; [
          python3
          python3Packages.pip
          python3Packages.virtualenv
          python3Packages.venv
          python3Packages.pylint
          python3Packages.black
          python3Packages.isort
          git
          neovim
        ];
      };

      go = pkgs.mkShell {
        packages = with pkgs; [
          go
          gopls
          golangci-lint
          gotools
          air
          git
          neovim
        ];
      };

      # MCP-enabled development shell with AI tooling
      mcp = pkgs.mkShell {
        packages = with pkgs; [
          # Core development tools
          git
          neovim
          fish
          starship
          direnv
          
          # Nix tools
          nil
          nixpkgs-fmt
          nix-init
          
          # Node.js for MCP servers
          nodejs-20_x
          yarn
          
          # Database tools for AgentDB
          postgresql
          sqlite
          
          # Additional utilities
          jq
          curl
          wget
          ripgrep
          fd
          bat
          
          # Docker for testing
          docker
          docker-compose
        ];
        
        shellHook = ''
          echo "🚀 pantherOS MCP Development Environment"
          echo "📚 MCP servers configured in .github/mcp-servers.json"
          echo "🔧 Use 'nix develop .#<shell>' to switch environments"
          echo ""
          echo "Available development shells:"
          echo "  - default: General development"
          echo "  - nix: Nix-specific development"
          echo "  - rust: Rust development"
          echo "  - node: Node.js development"
          echo "  - python: Python development"
          echo "  - go: Go development"
          echo "  - mcp: AI/MCP development (current)"
          echo ""
          
          # Set up MCP environment variables if not already set
          export MCP_CONFIG_PATH="${MCP_CONFIG_PATH:-.github/mcp-servers.json}"
          
          # Create .opencode directory structure if it doesn't exist
          if [ ! -d ".opencode" ]; then
            echo "Creating .opencode directory structure..."
            mkdir -p .opencode/{mcp,plugin,skills}
          fi
        '';
      };

      # AI infrastructure development shell
      ai = pkgs.mkShell {
        packages = with pkgs; [
          # Python for AI/ML tools
          python3
          python3Packages.pip
          python3Packages.virtualenv
          python3Packages.numpy
          python3Packages.pandas
          
          # Node.js for MCP and tooling
          nodejs-20_x
          yarn
          
          # Database tools
          postgresql
          sqlite
          redis
          
          # Development tools
          git
          neovim
          tmux
          
          # Nix tools
          nil
          nixpkgs-fmt
          
          # Utilities
          jq
          curl
          ripgrep
        ];
        
        shellHook = ''
          echo "🤖 pantherOS AI Infrastructure Development"
          echo "📖 See ai_infrastructure/ for integration plans"
          echo ""
          echo "Key components:"
          echo "  - AgentDB: Vector database integration"
          echo "  - MCP Servers: Model Context Protocol tools"
          echo "  - OpenCode: AI development environment"
          echo ""
        '';
      };
    };

    packages.${system}.default = self.nixosConfigurations.ovh-cloud.config.system.build.toplevel;
  };
}
