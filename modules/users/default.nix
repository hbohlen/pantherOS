# modules/users/default.nix
{ pkgs, ... }:

{
  # User configuration
  users.users.root = {
    # OpNix writes to /root/.ssh/authorized_keys
  };

  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # sudo access
      "podman" # container management
      "docker" # docker CLI compat
    ];
    shell = pkgs.fish; # Set fish as default shell
    # OpNix writes to /home/hbohlen/.ssh/authorized_keys
  };

  # Enable fish shell system-wide for proper shell integration
  programs.fish.enable = true;

  # Sudo configuration - passwordless for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Ensure directories exist for subvolume mounts
  system.activationScripts.createSubvolumeDirs = {
    text = ''
      # Create user subvolume mount points with correct ownership
      mkdir -p /home/hbohlen/{dev,.config,.local,.cache,.ai-tools}
      chown -R hbohlen:users /home/hbohlen/{dev,.config,.local,.cache,.ai-tools}
      chmod 755 /home/hbohlen/{dev,.config,.local,.cache,.ai-tools}

      # Create AI tools structure
      mkdir -p /home/hbohlen/.ai-tools/{claude-code,opencode}
      chown -R hbohlen:users /home/hbohlen/.ai-tools

      # Ensure .ssh exists with correct permissions
      mkdir -p /root/.ssh /home/hbohlen/.ssh
      chmod 700 /root/.ssh /home/hbohlen/.ssh
      chown root:root /root/.ssh
      chown hbohlen:users /home/hbohlen/.ssh

      # Create cache subdirectories for language tools
      mkdir -p /home/hbohlen/.cache/{npm,cargo,rustup,go,go-build,pip}
      chown -R hbohlen:users /home/hbohlen/.cache

      # Create local directories
      mkdir -p /home/hbohlen/.local/{bin,share,state}
      chown -R hbohlen:users /home/hbohlen/.local
    '';
    deps = [ "users" ];
  };
}
