# modules/home-manager/nixvim/plugins/productivity.nix
# ADHD-friendly productivity plugins

{ ... }:

{
  programs.nixvim = {
    plugins = {
      # ADHD-friendly productivity plugins
      hardtime-nvim = {
        # Enforces good habits
        enable = true;
        setting = {
          mode = "normal";
          repeat_only_moves = true;
          maxrepeat = 10;
        };
      };

      precognition-nvim = {
        # Motion hints
        enable = true;
        setting = {
          startVisiChars = [
            "f"
            "F"
            "t"
            "T"
            "s"
            "S"
          ];
          endVisiChars = [
            "F"
            "T"
            "a"
            "A"
            "i"
            "I"
            "l"
            "L"
          ];
          maxVisiChars = 50;
        };
      };

      which-key-nvim = {
        # Key binding suggestions
        enable = true;
        setting = {
          timeout = 3000;
          notify = false;
          hideOnRelease = true;
        };
      };

      flash-nvim = {
        # Enhanced search
        enable = true;
        setting = {
          search = {
            mode = "search";
            multi_window = true;
            priority = 2;
            incremental = true;
          };
        };
      };

      todo-comments-nvim = {
        # TODO highlighting
        enable = true;
        setting = {
          keywords = {
            FIX = {
              icon = "f";
              color = "error";
              alt = [
                "FIXME"
                "BUG"
                "HACK"
              ];
            };
            TODO = {
              icon = "t";
              color = "info";
            };
            NOTE = {
              icon = "n";
              color = "hint";
              alt = [
                "INFO"
                "IDEA"
              ];
            };
            WARNING = {
              icon = "w";
              color = "warning";
              alt = [ "WARN" ];
            };
            PERF = {
              icon = "p";
              alt = [
                "PERFORMANCE"
                "OPTIMIZE"
              ];
            };
          };
        };
      };

      trouble-nvim = {
        # Better diagnostics
        enable = true;
        setting = {
          position = "bottom";
          height = 10;
        };
      };
    };
  };
}