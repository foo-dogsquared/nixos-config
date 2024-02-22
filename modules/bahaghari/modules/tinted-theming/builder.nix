# A Bahaghari module for interacting with the Tinted Theming builder.
{ config, lib, pkgs, ... }:

let
  cfg = config.bahaghari;
in
{
  options.bahaghari.tinted-theming.builder = {
    package = lib.mkPackageOption pkgs "base16-builder-go" { };

    extraArgs = lib.mkOption {
      type = with lib.types; functionTo str;
      default = args: ''
        ${lib.getExe' pkgs.base16-builder-go "base16-builder-go"} \
          -schemes-dir ${lib.escapeShellArg args.schemesDir} \
          -template-dir ${lib.escapeShell args.template}
      '';
      description = ''
        A function returning a script to be applied per-template. The
        function parameter is an attribute set with the following values:

        * `template` contains the path to the template.
        * `name` is the attribute name of the template.
        * `schemesDir` is a path containing all of the schemes as a YAML file
        (technically a JSON file).
      '';
    };
  };
}
