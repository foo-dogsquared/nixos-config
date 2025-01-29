{ config, lib, pkgs, ... }:

let
  section = "one/foodogsquared/SomeMadeUpCrap";
  key = "somemadeupkey";
  value = true;
in {
  wrappers.dconf-test = {
    arg0 = lib.getExe' pkgs.dconf "dconf";
    dconf = {
      enable = true;
      settings.${section}.${key} = value;
    };
  };

  build.extraPassthru.tests = {
    dconfCheck = pkgs.runCommand "dconf-wrapped-test" { } ''
      export HOME=$TMPDIR

      # We've hardcoded the value for now since Nix toString function makes the
      # boolean either "1" or an empty string.
      [ "$(${
        lib.getExe' config.build.toplevel "dconf-test"
      } read '/${section}/${key}')" = 'true' ] && touch $out
    '';
  };
}
