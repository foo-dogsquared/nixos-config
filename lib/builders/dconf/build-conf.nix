{ lib, stdenvNoCC }:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  excludeDrvArgNames = [
    "settings"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      name ? "dconf-conf",

      # The attribute containing the actual DConf settings.
      settings ? { },

      ...
    }
    @args:
    let
      settingsFile = lib.generators.toDconfINI settings;
    in
    {
      inherit settingsFile;
      allowSubstitutes = args.allowSubstitutes or false;
      preferLocalBuild = args.preferLocalBuild or true;

      buildCommand = ''
        mkdir -p $out && cp "$settingsFile" "$out/${name}"
      '';
    };
}
