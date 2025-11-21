{ config, lib, pkgs, ... }:

{
  options = {
    programs.fnm.enable = lib.mkEnableOption "fnm (Fast Node Manager)";
  };

  config = lib.mkIf config.programs.fnm.enable {
    programs.fish = {
      shellAliases = {
        fnm = "fnm";
      };
      
      interactiveShellInit = ''
        # fnm (Fast Node Manager) integration
        if command -v fnm >/dev/null 2>&1
          fnm env --use-on-cd | source
        end
      '';
    };

    environment.systemPackages = with pkgs; [
      fnm
      nodejs # Default Node.js version
    ];

    # Ensure fnm can manage Node.js versions
    users.users.hbohlen.shellInit = ''
      export FNM_DIR="$HOME/.fnm"
      export PATH="$FNM_DIR:$PATH"
    '';
  };
}