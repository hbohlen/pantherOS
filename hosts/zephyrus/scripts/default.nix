{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation {
  pname = "zephyrus-hardware-tools";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp hardware-inventory.fish $out/bin/hardware-inventory.fish
    cp parse-hardware.fish $out/bin/parse-hardware.fish
    cp verify-hardware.fish $out/bin/verify-hardware.fish
    chmod +x $out/bin/*
  '';

  postFixup = ''
    for script in $out/bin/*; do
      wrapProgram $script \
        --prefix PATH : ${lib.makeBinPath (with pkgs; [
          util-linux
          pciutils
          dmidecode
          btrfs-progs
          asusctl
          power-profiles-daemon
          pulseaudio
          fish
          gnugrep
          coreutils
        ])}
    done
  '';

  meta = with lib; {
    description = "Hardware detection and inventory tools for Zephyrus";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
