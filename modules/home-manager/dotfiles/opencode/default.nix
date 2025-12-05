{ config, lib, ... }:

{
  imports = [
    ./config.nix
    ./agents.nix
    ./mcp.nix
    ./lsp.nix
    ./formatters.nix
  ];
}
