# A Bahaghari module for interacting with the Tinted Theming builder.
{ lib, pkgs, ... }:

{
  options.bahaghari.tinted-theming.builder = {
    script = lib.mkOption {
      type = with lib.types; functionTo str;
      default = args: ''
        ${lib.getExe' pkgs.base16-builder-go "base16-builder-go"} \
          -schemes-dir ${lib.escapeShellArg args.schemesDir} \
          -template-dir ${lib.escapeShell args.templateDir}
      '';
      description = ''
        A function returning a script to be applied per-template. The
        function parameter is an attribute set with the following values:

        * `templateDir` contains the path to the template.
        * `schemesDir` is a path containing all of the schemes as a YAML file
        (technically a JSON file).

        This is primarily used for generating templates with
        `bahaghariUtils.tinted-theming.generateOutputFromSchemes` function.
      '';
    };
  };
}
