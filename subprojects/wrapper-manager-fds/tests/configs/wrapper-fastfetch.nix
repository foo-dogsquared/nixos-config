{ config, lib, pkgs, ... }:

{
  wrappers.fastfetch = {
    arg0 = lib.getExe' pkgs.fastfetch "fastfetch";
    appendArgs = [ "--logo" "Guix" ];
    env.NO_COLOR = "1";
    xdg.desktopEntry.enable = true;
  };

  build.extraPassthru.tests = {
    actuallyBuilt = let
      wrapper = config.build.toplevel;
    in pkgs.runCommand "wrapper-manager-fastfetch-actually-built" { } ''
      [ -e "${wrapper}/share/applications/fastfetch.desktop" ] && [ -x "${wrapper}/bin/${config.wrappers.fastfetch.executableName}" ] && touch $out
    '';
  };
}
