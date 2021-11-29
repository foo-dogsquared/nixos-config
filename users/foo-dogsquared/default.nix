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
    alacritty.enable = true;
    i18n.enable = true;
    dev.enable = true;
  };
}
