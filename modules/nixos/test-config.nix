{ config, pkgs, ... }: {
  # Import the new modular structure
  imports = [
    # Import the core users module
    ./core/users/user-management.nix
    ./core/users/sudo-config.nix
    
    # Import a networking service
    ./services/networking/tailscale-service.nix
    
    # Import security configurations
    ./security/firewall/firewall-config.nix
  ];

  # Example configuration using the new modules
  pantherOS = {
    core = {
      users = {
        enable = true;
        defaultUser = {
          name = "testuser";
          description = "Test User";
          extraGroups = [ "networkmanager" "wheel" ];
        };
      };
    };
    
    services = {
      tailscale = {
        enable = true;
        port = 41641;
      };
    };
    
    security = {
      firewall = {
        enable = true;
        allowedTCPPorts = [ 22 80 443 ];
        allowedUDPPorts = [ 41641 ];  # Tailscale port
      };
    };
  };
}