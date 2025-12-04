{ config, lib, pkgs, ... }:
{
  services.caddy = {
    enable = true;

    virtualHosts = {
      "hbohlen.systems" = {
        extraConfig = ''
          respond "pantherOS entrypoint" 200
        '';
      };

      "attic.hbohlen.systems" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8080
        '';
      };
    };
  };
}
