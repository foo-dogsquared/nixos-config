{ config, lib, pkgs, ... }:

{
  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = "Your name";
      user.email = "yourname@example.com";
    };
  };

  build.extraPassthru.tests = {
    runWithJujutsu = let wrapper = config.build.toplevel;
    in pkgs.runCommand ''
      [ -x ${lib.getExe' wrapper "jj"} ] && touch $out
    '';
  };
}

