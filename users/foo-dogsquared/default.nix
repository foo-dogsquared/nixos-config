{ config, options, lib, pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  # My specific usual stuff.
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "foo-dogsquared";
    userEmail = "foo.dogsquared@gmail.com";
  };

  # My custom modules.
  modules = {
    i18n.enable = true;
    dev = {
      enable = true;
      shell.enable = true;
    };
    desktop = {
      enable = true;
      graphics.enable = true;
      audio.enable = true;
    };
  };
}
