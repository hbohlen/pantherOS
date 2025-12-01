# modules/home-manager/nixvim/keymaps/git.nix
# Git-related keymaps

{ ... }:

{
  programs.nixvim = {
    keymaps = [
      # Git integration keymaps can be added here
      # Currently handled by neotree toggle in navigation.nix
      # Additional git keymaps can be added as needed
    ];
  };
}