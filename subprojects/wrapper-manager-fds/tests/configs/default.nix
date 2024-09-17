let
  sources = import ../../npins;
in
{
  pkgs ? import sources.nixos-unstable { },
}:

let
  wmLib = (import ../../. { }).lib;
  build = modules: wmLib.build { inherit pkgs modules; };
in
{
  fastfetch = build [ ./wrapper-fastfetch.nix ];
  neofetch = build [ ./wrapper-neofetch.nix ];
  single-basepackage = build [ ./single-basepackage.nix ];
  neofetch-with-additional-files = build [ ./neofetch-with-additional-files.nix ];
}
