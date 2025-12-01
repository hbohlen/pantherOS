# modules/home-manager/nixvim/lsp/servers.nix
# LSP server configurations for nixvim

{ ... }:

{
  programs.nixvim = {
    # LSP configuration for better development experience
    lspServers = {
      bashls.enable = true; # Bash
      jsonls.enable = true; # JSON
      yamlls.enable = true; # YAML
      nixvim-lsp-setup.enable = true; # Nix
    };
  };
}