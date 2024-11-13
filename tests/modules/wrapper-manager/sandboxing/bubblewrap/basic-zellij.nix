{ config, lib, pkgs, ... }:

{
  locale.enable = true;
  wrappers.zellij = {
    wraparound.variant = "bubblewrap";
    wraparound.subwrapper.arg0 = lib.getExe' pkgs.zellij "zellij";
  };
  build.extraPassthru.tests = {
    zellijWrapperCheck =
      let
        wrapper = config.build.toplevel;
      in pkgs.runCommand { } ''
          [ -x ${lib.getExe' wrapper "zellij"} ] && touch $out

      '';
  };
}
