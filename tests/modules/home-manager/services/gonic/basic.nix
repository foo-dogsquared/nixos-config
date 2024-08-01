{ config, lib, pkgs, ... }:

{
  services.gonic = {
    enable = true;
    package = pkgs.gonic;

    settings = {
      music-path = [ config.xdg.userDirs.music ];
      podcast-path = [ "${config.xdg.userDirs.music}/Podcasts" ];
    };
  };

  test.stubs.gonic = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/gonic.service
  '';
}
