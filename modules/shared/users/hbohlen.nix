{ pkgs, ... }:

{
  programs.fish.enable = true;

  users.users.hbohlen = {
    isNormalUser = true;
    description = "PantherOS maintainer";
    home = "/home/hbohlen";
    createHome = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
}
