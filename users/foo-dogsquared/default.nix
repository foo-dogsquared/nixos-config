{ config, options, lib, pkgs, ... }:

{
  programs.direnv.enable = true;
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "foo-dogsquared";
    userEmail = "foo.dogsquared@gmail.com";
  };
}
