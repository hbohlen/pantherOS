{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, disko, ... }:
    {
      nixosConfigurations.hetzner-vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/servers/hetzner-vps/configuration.nix
          ./hosts/servers/hetzner-vps/disko.nix
          disko.nixosModules.disko
        ];
      };
    };
}
