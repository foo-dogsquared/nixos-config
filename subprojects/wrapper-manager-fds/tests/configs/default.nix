let
  sources = import ../../npins;
in
{
  pkgs ? import sources.nixos-unstable { },
}:

let
  wmLib = (import ../../. { }).lib;
  build = args: wmLib.build (args // { inherit pkgs; });
in
{
  fastfetch = build { modules = [ ./wrapper-fastfetch.nix ]; };
  neofetch = build {
    modules = [ ./wrapper-neofetch.nix ];
    specialArgs.yourMomName = "Yor mom";
  };
  single-basepackage = build { modules = [ ./single-basepackage.nix ]; };
  neofetch-with-additional-files = build { modules = [ ./neofetch-with-additional-files.nix ]; };
}
