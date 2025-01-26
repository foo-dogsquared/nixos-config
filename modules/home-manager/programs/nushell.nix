# This is just an extended implementation of exporting Nushell session
# variables since the one from home-manager is only in POSIX sh script.
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.nushell;
in
{
  config.programs.nushell.extraEnv = let
    exportSessionVariables = lib.mapAttrs (n: v:
      "$env.${n} = ${v}") config.home.sessionVariables;
  in lib.mkBefore ''
    ${exportSessionVariables}
  '';
}
