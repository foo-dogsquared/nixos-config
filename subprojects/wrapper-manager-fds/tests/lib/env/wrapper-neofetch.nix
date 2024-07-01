{ lib, pkgs, yourMomName, ... }:

{
  arg0 = lib.getExe' pkgs.neofetch "neofetch";
  executableName = yourMomName;
  appendArgs = [
    "--ascii_distro" "guix"
    "--title_fqdn" "off"
    "--os_arch" "off"
  ];
}
