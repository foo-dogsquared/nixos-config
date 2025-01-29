# This is just an extended implementation of exporting Nushell session
# variables since the one from home-manager is only in POSIX sh script.
{ config, lib, pkgs, ... }:

let cfg = config.programs.nushell;
in {
  config.programs.nushell.extraEnv = let
    exportToNuEnv = vars:
      lib.concatStringsSep "\n"
      (lib.mapAttrsToList (n: v: ''$env.${n} = "${v}"'') vars);
  in lib.mkBefore (''
    ${exportToNuEnv config.home.sessionVariables}
  '' + lib.optionalString (config.home.sessionPath != [ ]) ''
    $env.PATH = $env.PATH | split row ':' | prepend [
      ${lib.concatStringsSep " " config.home.sessionPath}
    ]
  '');
}
