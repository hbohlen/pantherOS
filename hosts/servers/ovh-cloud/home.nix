{ pkgs, inputs, config, ... }:

{
  home = {
    username = "hbohlen";
    homeDirectory = "/home/hbohlen";
  };

  programs.home-manager.enable = true;

  # Packages for the user
  home.packages = with pkgs; [
    # CLI tools
    git
    neovim
    fish
    starship
    exa
    ripgrep
    fd
    bat
    tree
    jq
    curl
    wget
    _1password

    # Navigation and fuzzy finding
    zoxide
    fzf
    gh
    btm

    # Dev tools
    direnv
    nil  # Nix language server
    nixpkgs-fmt  # Nix formatter

    # AI Coding Tools (from nix-ai-tools)
    inputs.nix-ai-tools.packages.${pkgs.system}.spec-kit
    inputs.nix-ai-tools.packages.${pkgs.system}.qwen-code
    inputs.nix-ai-tools.packages.${pkgs.system}.opencode
    inputs.nix-ai-tools.packages.${pkgs.system}.gemini-cli
    inputs.nix-ai-tools.packages.${pkgs.system}.code
    inputs.nix-ai-tools.packages.${pkgs.system}.claudebox
    inputs.nix-ai-tools.packages.${pkgs.system}.claude-code-router
    inputs.nix-ai-tools.packages.${pkgs.system}.claude-code
    inputs.nix-ai-tools.packages.${pkgs.system}.catnip
  ];

  # Git configuration optimized for AI coding workflows
  programs.git = {
    enable = true;
    userName = "Hayden Bohlen";
    userEmail = "bohlenhayden@gmail.com";

    # Performance optimizations for AI coding agents
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rerere.enabled = true;

      # Core performance optimizations
      core.preloadIndex = true;        # Faster git status on large repos
      core.fscache = true;             # Cache filesystem calls (Windows, but helpful)
      core.useBuiltin = true;          # Use built-in git features
      core.checkStat = "minimal";      # Reduce stat() calls
      core.autocrlf = false;           # No line ending conversion

      # Garbage collection and packing
      gc.auto = 256;                   # More frequent GC for many small files
      gc.autoDetach = false;           # Run GC synchronously
      pack.threads = 0;                # Use all CPU cores for packing
      pack.window = "10";              # Larger window for better compression

      # Index optimization
      index.version = 4;               # Newest index format (faster)
      index.threads = true;            # Use threads for index operations

      # Status and diff optimizations
      status.submoduleSummary = true;
      diff.algorithm = "histogram";    # Faster for code changes

      # Merge strategies
      merge.conflictStyle = "diff3";   # Better conflict resolution context

      # Logging
      log.date = "iso";
      log.follow = true;               # Follow renames in git log

      # Push and pull
      push.autoSetupRemote = true;     # Automatically setup remote for push
      pull.rebase = true;              # Always rebase on pull

      # Branch and tag handling
      branch.autosetupmerge = true;
      tag.sort = "version:refname";    # Semantic version tags

      # Large file handling
      lfs.fetchinclude = "*";          # LFS tracking for necessary files

      # Performance for AI tools reading many files
      core.sparseCheckout = true;      # Enable sparse checkout for large repos
    };

    # Ignore certain files by default in ~/dev
    ignores = [
      "*.tmp"
      "*.temp"
      ".DS_Store"
      "Thumbs.db"
      "*.swp"
      "*.swo"
      "*~"
      ".envrc"
      "result"
      "result-*"
      "*.build"
      "*.target"
      "*.dist"
      "node_modules/.cache"
      ".cache/*"
      "*.pid"
      "*.seed"
      "*.pid.lock"
      "*.tgz"
      ".nix-profile"
    ];

    # Git aliases for development
    extraConfig.alias = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      cm = "commit -m";
      amend = "commit --amend --no-edit";
      undo = "reset --soft HEAD~1";
      last = "log -1 HEAD";
      visual = "log --oneline --graph --decorate --all";
      unstage = "reset HEAD";
      uncommit = "reset --mixed HEAD~1";
      snapshot = "stash push -m \"snapshot: $(date +%Y%m%d-%H%M%S)\"";
      restore-staged = "restore --staged .";
      restore = "restore .";
      sync = "!git fetch && git rebase --autostash && git push && git pull --rebase";

      # AI-friendly shortcuts
      ll = "log --oneline";
      changes = "diff --name-status";
      files = "diff --name-only";
      size = "count-objects -v";
    };
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    extraConfig = ''
      " General settings
      set number
      set relativenumber
      set cursorline
      set wildmenu
      set showcmd
      set showmode
      set ruler
      set incsearch
      set hlsearch
      set ignorecase
      set smartcase
      set autoindent
      set smartindent
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set softtabstop=2
      set clipboard=unnamedplus
      set mouse=a

      " Split navigation
      set splitbelow
      set splitright

      " Auto-resize splits
      set winwidth=84
      set winheight=10
      set winminheight=5
      set winminwidth=5

      " File handling
      set autoread
      set autowrite
      set hidden

      " Backup and swap files
      set nobackup
      set noswapfile
      set undodir=~/.config/nvim/undodir
      set undofile

      " Leader key
      let mapleader = " "

      " Keybindings
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " Telescope
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      nnoremap <leader>fr <cmd>Telescope lsp_references<cr>
    '';
  };

  # Fish shell configuration with dev workflow helpers
  programs.fish = {
    enable = true;

    # Shell initialization
    shellInit = ''
      set -gx PATH $PATH ~/.local/bin
      starship init fish | source

      # Initialize zoxide for smarter navigation
      zoxide init fish | source

      # Initialize fzf for fuzzy finding
      if type -q fzf
        set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --inline-info --cycle"
        set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"

        # fzf keybindings
        fzf --fish | source
      end

      # Mobile SSH optimizations
      set -gx TERM "xterm-256color"

      # Enable vi mode for better mobile keyboard navigation
      fish_vi_key_bindings

      # Fish abbreviations for faster mobile typing
      abbr -a ll "exa -lah"
      abbr -a la "exa -lah"
      abbr -a l "exa -lah"
      abbr -a grep "rg"
      abbr -a cat "bat"
      abbr -a find "fd"

      # Quick Git shortcuts
      abbr -a gs "git status"
      abbr -a ga "git add"
      abbr -a gc "git commit"
      abbr -a gp "git push"
      abbr -a gl "git log --oneline"

      # Development shortcuts
      abbr -a devn "nix develop"
      abbr -a devl "dev-list"
      abbr -a ctx "ai-context"

      # Mobile-friendly navigation
      abbr -a .. "cd .."
      abbr -a ... "cd ../.."
      abbr -a .... "cd ../../.."

      # Monitor shortcut
      abbr -a top "btm"
    '';

    # Functions for development workflow
    functions = {
      dev = {
        definition = "function dev\n  cd ~/dev/$argv[1]\nend";
        onVariable = false;
      };
      dev-list = {
        definition = "function dev-list\n  echo \"Development projects in ~/dev:\"\n  echo \"\"\n  find ~/dev -maxdepth 1 -type d ! -name dev -exec basename {} \\; | sort | while read -l dir\n    set -l project_path ~/dev/$dir\n    set -l git_status \"\"\n\n    if test -d \"$project_path/.git\"\n      set -l commits (cd \"$project_path\"; git rev-list --all --count 2>/dev/null; or echo 0)\n      set -l branch (cd \"$project_path\"; git branch --show-current 2>/dev/null; or echo \"no-branch\")\n      set -l modified (cd \"$project_path\"; git status --porcelain 2>/dev/null | wc -l; or echo 0)\n      set -l git_status \" [git: $branch, $commits commits, $modified modified]\"\n    end\n\n    echo \"  - $dir$git_status\"\n  end\n  echo \"\"\n  echo \"Total: \"(find ~/dev -maxdepth 1 -type d ! -name dev | wc -l)\" projects\"\nend";
        onVariable = false;
      };
      ai-context = {
        definition = "function ai-context\n  if test -z \"$argv[1]\"\n    set -l project_dir (pwd)\n  else\n    set -l project_dir \"$argv[1]\"\n  end\n\n  echo \"=== Project Context for AI ===\"\n  echo \"\"\n  echo \"Project: \"(basename \"$project_dir\")\n  echo \"Path: $project_dir\"\n  echo \"\"\n  echo \"=== Git Status ===\"\n  git status --short 2>/dev/null; or echo \"Not a git repository\"\n  echo \"\"\n  echo \"=== Recent Changes ===\"\n  git log --oneline -10 2>/dev/null; or echo \"No git history\"\n  echo \"\"\n  echo \"=== Key Files ===\"\n  find \"$project_dir\" -maxdepth 2 -type f -name \"*.nix\" -o -name \"*.rs\" -o -name \"*.js\" -o -name \"*.py\" -o -name \"*.go\" -o -name \"*.md\" | head -20\nend";
        onVariable = false;
      };
      dev-auto = {
        definition = "function dev-auto\n  # Auto-detect project type and activate appropriate devShell\n  set -l current_dir (pwd)\n  set -l flake_found 0\n\n  # Check if we're in a project with flake.nix\n  if test -f \"$current_dir/flake.nix\"\n    set flake_found 1\n  end\n\n  # Check if we're in ~/dev or a subdirectory\n  if string match -q \"$HOME/dev*\" \"$current_dir\"\n    if test $flake_found -eq 1\n      echo \"Activating Nix devShell...\"\n      nix develop --command fish\n    else\n      echo \"No flake.nix found. Current directory: $current_dir\"\n    end\n  else\n    echo \"Not in ~/dev directory. Current: $current_dir\"\n  end\nend";
        onVariable = false;
      };
    };

    # Key bindings for mobile-friendly navigation
    keyBindings = {
      "alt-h" = "backward-word";
      "alt-l" = "forward-word";
      "alt-d" = "kill-word";
    };
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      hostname = {
        style = "cyan bold";
      };
      username = {
        style_user = "green bold";
        show_always = true;
      };
      hostname = {
        style_hostname = "cyan bold";
      };
    };
  };

  # Shell aliases and dev workflow functions
  programs.bash = {
    enable = true;
    initExtra = ''
      # Enable vi mode for better mobile keyboard navigation
      set -o vi

      alias ll='exa -lah'
      alias la='exa -lah'
      alias l='exa -lah'
      alias grep='rg'
      alias cat='bat'
      alias find='fd'

      # Git shortcuts
      alias gs='git status'
      alias ga='git add'
      alias gc='git commit'
      alias gp='git push'
      alias gl='git log --oneline'

      # Development shortcuts
      alias devn='nix develop'
      alias devl='dev-list'
      alias ctx='ai-context'

      # Mobile-friendly navigation
      alias ..='cd ..'
      alias ...='cd ../..'
      alias ....='cd ../../..'

      # Monitor shortcut
      alias top='btm'

      # Dev workflow functions
      dev() {
        cd ~/dev/$1
      }

      # Create new project from template with auto-activation
      dev-new() {
        local project_type=$1
        local project_name=$2

        if [ -z "$project_type" ] || [ -z "$project_name" ]; then
          echo "Usage: dev-new <type> <name>"
          echo "Types: nix, rust, node, python, go, generic"
          return 1
        fi

        local project_dir=~/dev/$project_name
        mkdir -p "$project_dir"
        cd "$project_dir"

        case $project_type in
          nix)
            cat > flake.nix << 'EOF'
{
  description = "Nix project";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, ... }: rec {
    packages.x86_64-linux.hello = nixpkgs.hello;
    apps.x86_64-linux.default = {
      type = "app";
      package = packages.x86_64-linux.hello;
    };
  }
}
EOF
            echo "use flake" > .envrc
            direnv allow
            git init
            ;;
          rust)
            cargo init --name "$project_name"
            cat > .envrc << 'EOF'
use flake
EOF
            git init
            ;;
          node)
            npm init -y
            echo "node_modules/" > .gitignore
            echo "*.log" >> .gitignore
            echo "use nix" > .envrc
            direnv allow
            git init
            ;;
          python)
            mkdir -p "$project_name"
            echo "#!/usr/bin/env python3" > "$project_name/main.py"
            echo "use nix" > .envrc
            direnv allow
            git init
            ;;
          go)
            mkdir -p "$project_name"
            echo "module github.com/hbohlen/$project_name" > "$project_name/go.mod"
            echo "use nix" > .envrc
            direnv allow
            git init
            ;;
          generic)
            git init
            ;;
        esac

        echo "✓ Created $project_type project at $project_dir"
        echo "  Run 'dev-auto' or 'cd ~/dev/$project_name' to activate devShell"
      }

      # Auto-detect and activate appropriate devShell
      dev-auto() {
        local current_dir=$(pwd)
        local flake_found=0

        # Check if we're in a project with flake.nix
        if [ -f "$current_dir/flake.nix" ]; then
          flake_found=1
        fi

        # Check if we're in ~/dev or a subdirectory
        if [[ "$current_dir" == "$HOME/dev"* ]]; then
          if [ $flake_found -eq 1 ]; then
            echo "Activating Nix devShell..."
            nix develop
          else
            echo "No flake.nix found. Current directory: $current_dir"
          fi
        else
          echo "Not in ~/dev directory. Current: $current_dir"
        fi
      }

      # Quick dev directory navigation
      __dev_completion() {
        COMPREPLY=($(compgen -W "$(ls -1 ~/dev/)" -- "$COMP_WORDS[1]"))
      }
      complete -F __dev_completion -o filenames dev

      # List all projects in ~/dev
      dev-list() {
        echo "Development projects in ~/dev:"
        echo ""
        find ~/dev -maxdepth 1 -type d ! -name dev -exec basename {} \; | sort | while read dir; do
          local project_path=~/dev/$dir
          local git_status=""

          if [ -d "$project_path/.git" ]; then
            local commits=$(cd "$project_path" && git rev-list --all --count 2>/dev/null || echo 0)
            local branch=$(cd "$project_path" && git branch --show-current 2>/dev/null || echo "no-branch")
            local modified=$(cd "$project_path" && git status --porcelain 2>/dev/null | wc -l || echo 0)
            git_status=" [git: $branch, $commits commits, $modified modified]"
          fi

          echo "  - $dir$git_status"
        done
        echo ""
        echo "Total: $(find ~/dev -maxdepth 1 -type d ! -name dev | wc -l) projects"
      }

      # AI coding helpers
      ai-context() {
        local project_dir="$1"
        if [ -z "$project_dir" ]; then
          project_dir=$(pwd)
        fi

        echo "=== Project Context for AI ==="
        echo ""
        echo "Project: $(basename "$project_dir")"
        echo "Path: $project_dir"
        echo ""
        echo "=== Git Status ==="
        git status --short 2>/dev/null || echo "Not a git repository"
        echo ""
        echo "=== Recent Changes ==="
        git log --oneline -10 2>/dev/null || echo "No git history"
        echo ""
        echo "=== Key Files ==="
        find "$project_dir" -maxdepth 2 -type f -name "*.nix" -o -name "*.rs" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.md" | head -20
      }
    '';
  };

  # Environment variables (sourced from 1Password via OpNix)
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    DEV_DIR = "$HOME/dev";

    # API Keys from 1Password (auto-sourced via OpNix)
    ANTHROPIC_API_KEY = config.opnix.secrets.opnix-1password."op://pantherOS/secrets:ANTHROPIC_API_KEY";
    OPENAI_API_KEY = config.opnix.secrets.opnix-1password."op://pantherOS/secrets:OPENAI_API_KEY";
    GITHUB_TOKEN = config.opnix.secrets.opnix-1password."op://pantherOS/secrets:GITHUB_TOKEN";
    GITLAB_TOKEN = config.opnix.secrets.opnix-1password."op://pantherOS/secrets:GITLAB_TOKEN";
    NPM_TOKEN = config.opnix.secrets.opnix-1password."op://pantherOS/secrets:NPM_TOKEN";

    # Additional development tokens
    OPENCODE_API_KEY = config.opnix.secrets.opnix-1password."op://pantherOS/secrets:OPENCODE_API_KEY";
    GEMINI_API_KEY = config.opnix.secrets.opnix-1password."op://pantherOS/secrets:GEMINI_API_KEY";
  };

  # Claude Code configuration
  programs.claude = {
    enable = true;
  };

  # Claude Code settings.json
  xdg.configFile."claude/settings.json".text = builtins.toJSON {
    # Anthropic API configuration
    anthropic = {
      apiKey = "{env:ANTHROPIC_API_KEY}";
      apiUrl = "https://api.anthropic.com";
    };

    # Model configuration
    model = "claude-3-5-sonnet-20241022";
    maxTokens = 8192;
    temperature = 0.2;

    # Output preferences
    output = {
      format = "markdown";
      color = true;
      showTokenCount = true;
    };

    # Development settings
    development = {
      autoSave = true;
      confirmEdits = true;
      confirmDeletions = true;
    };

    # Git integration
    git = {
      autoCommit = false;
      autoPush = false;
    };

    # Allowed directories (for security)
    allowedDirectories = [
      "$HOME/dev"
      "$HOME/.local/share/claude"
    ];

    # Default commands and agents
    plugins = [
      {
        name = "commit-commands";
        enabled = true;
      }
      {
        name = "code-review";
        enabled = true;
      }
    ];

    # Additional AI tools integration
    tools = {
      opencode = {
        apiKey = "{env:OPENCODE_API_KEY}";
      };
      gemini = {
        apiKey = "{env:GEMINI_API_KEY}";
      };
      openai = {
        apiKey = "{env:OPENAI_API_KEY}";
      };
    };
  };

  # 1Password CLI shell integration
  programs.bash.initExtraExtra = ''
    eval "$(op completion bash)"
  '';

  programs.zsh.initExtraExtra = ''
    eval "$(op completion zsh)"
  '';

  # Fish shell integration
  programs.fish.shellInit = ''
    ${programs.fish.shellInit}
    eval "$(op completion fish)"
    eval "$(gh completion --shell fish)"
  '';

  # Enable Nix development features with auto-activation
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    # Global .envrc configuration
    globalConfig = ''
      # Automatically allow projects without .envrc
      watch add

      # Use nix-direnv for flake-based projects
      use flake

      # Lowercase allowed
      allow pure
    '';
  };

  # Create a global .envrc in ~/dev for auto-activation
  xdg.configFile."direnv/direnvrc".text = ''
    # Auto-detect and activate Nix devShells
    use_devshell() {
      if test -f flake.nix
        nix develop --command fish
      elif test -f .envrc
        source_env
      end
    }
  '';
}
