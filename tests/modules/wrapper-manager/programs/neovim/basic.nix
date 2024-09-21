{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
  };

  build.extraPassthru.tests = {
    runWithNeovim = let
      wrapper = config.build.toplevel;
    in pkgs.runCommand ''
      [ -x ${lib.getExe' wrapper "nvim"} ] && touch $out
    '';
  };
}
