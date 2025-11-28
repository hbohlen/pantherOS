# modules/packages/default.nix
# Aggregator for all package modules

{
  imports = [
    ./core
    ./dev
  ];
}
