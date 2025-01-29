{ config, lib, pkgs, ... }:

{
  programs.zellij.enable = true;
  programs.zellij.configFile = ./config/config.kdl;

  build.extraPassthru.tests = {
    checkZellijConfigDir =
      let wrapper = lib.getExe' config.build.toplevel "zellij";
      in pkgs.runCommandLocal "zellij-check-config-dir" { } ''
        [ $(${wrapper} setup --check | awk -F':' '/^\[LOOKING FOR CONFIG FILE FROM]/ { gsub(/"|\s/, "", $2); print $2; }') = ${
          ./config/config.kdl
        } ] && touch $out
      '';
  };
}
