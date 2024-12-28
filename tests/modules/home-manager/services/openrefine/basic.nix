{ config, lib, pkgs, ... }:

{
  services.openrefine = {
    enable = true;
    package = pkgs.openrefine;
  };

  test.stubs.openrefine = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/openrefine.service
  '';
}
