{ config, lib, pkgs, ... }:

{
  options = {
    programs.fish.enable = lib.mkEnableOption "Fish shell";
  };

  config = lib.mkIf config.programs.fish.enable {
    programs.fish = {
      enable = true;
      
      shellInit = ''
        # Fish shell configuration
        set -g fish_greeting  # Disable welcome message
        
        # Better defaults
        set -g fish_key_bindings fish_vi_key_bindings
        
        # Environment variables
        set -gx EDITOR zed
        set -gx BROWSER zen-browser
        
        # Path modifications
        fish_add_path /home/hbohlen/.local/bin
        fish_add_path /home/hbohlen/dev/bin
        
        # Auto-activate devshell in ~/dev
        if test -d ~/dev
          cd ~/dev
        end
      '';

      shellAliases = {
        # Common aliases
        ll = "ls -la";
        la = "ls -a";
        l = "ls";
        .. = "cd ..";
        ... = "cd ../..";
        
        # Git aliases
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git pull";
        
        # Nix aliases
        nb = "nixos-rebuild build";
        ns = "nixos-rebuild switch";
        nr = "nixos-rebuild rollback";
        
        # Development aliases
        dev = "nix develop";
        z = "zoxide";
      };

      functions = {
        # Custom Fish functions
        mkcd = ''
          mkdir -p $argv[1]
          cd $argv[1]
        '';
      };
    };

    # Install useful Fish plugins and tools
    environment.systemPackages = with pkgs; [
      fishPlugins.done
      fishPlugins.fzf-fish
      fishPlugins.autopair
      fishPlugins.colored-man-pages
      fzf
      zoxide
      eza
      bat
      ripgrep
    ];
  };
}