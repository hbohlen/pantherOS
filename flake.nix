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
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations.ovh-cloud = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/servers/ovh-cloud/configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.users.hbohlen = ./hosts/servers/ovh-cloud/home.nix;
        }
      ];
    };

    # Development shells for different project types
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        git
        neovim
        fish
        starship
        direnv
        nil
        nixpkgs-fmt
        git
      ];
    };

    devShells.${system}.nix = pkgs.mkShell {
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

    devShells.${system}.rust = pkgs.mkShell {
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

    devShells.${system}.node = pkgs.mkShell {
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

    devShells.${system}.python = pkgs.mkShell {
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

    devShells.${system}.go = pkgs.mkShell {
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

    packages.${system}.default = self.nixosConfigurations.ovh-cloud.config.system.build.nixosSystem;
  };
}
