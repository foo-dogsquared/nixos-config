{
  config,
  lib,
  pkgs,
  yourMomName,
  ...
}:

{
  wrappers.neofetch = {
    arg0 = lib.getExe' pkgs.neofetch "neofetch";
    executableName = yourMomName;
    appendArgs = [
      "--ascii_distro"
      "guix"
      "--title_fqdn"
      "off"
      "--os_arch"
      "off"
    ];
  };

  build.extraPassthru.tests = {
    actuallyBuilt =
      let
        wrapper = config.build.toplevel;
      in
      pkgs.runCommand "wrapper-manager-neofetch-actually-built" { } ''
        [ -x "${wrapper}/bin/${config.wrappers.neofetch.executableName}" ] && touch $out
      '';
  };
}
