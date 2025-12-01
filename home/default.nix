# home/default.nix
# Home Manager main aggregator

{
  imports = [
    ./window-managers
    ./desktop-shells
    ./development
  ];
}