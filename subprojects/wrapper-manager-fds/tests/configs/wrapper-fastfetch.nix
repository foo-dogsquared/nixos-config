{
  config,
  lib,
  pkgs,
  wrapperManagerLib,
  ...
}:

{
  build.variant = "shell";

  wrappers.fastfetch = {
    arg0 = lib.getExe' pkgs.fastfetch "fastfetch";
    appendArgs = [
      "--logo"
      "Guix"
    ];
    env.NO_COLOR.value = "1";
    xdg.desktopEntry.enable = true;
  };

  environment.pathAdd = wrapperManagerLib.getBin (with pkgs; [
    hello
  ]);

  build.extraPassthru.tests = {
    actuallyBuilt =
      let
        wrapper = config.build.toplevel;
      in
      pkgs.runCommand "wrapper-manager-fastfetch-actually-built" { } ''
        [ -e "${wrapper}/share/applications/fastfetch.desktop" ] && [ -x "${wrapper}/bin/${config.wrappers.fastfetch.executableName}" ] && touch $out
      '';
  };
}
