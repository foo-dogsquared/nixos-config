{ lib, pkgs, ... }:

{
  services.plover = {
    enable = true;
    package = pkgs.plover-dev;
    settings = {
      "Output Configuration" = {
        undo_levels = 100;
      };

      "Stroke Display" = {
        show = true;
      };
    };
  };

  test.stubs.plover-dev = { };

  nmt.script = ''
    assertFileExists home-files/.config/plover/plover.cfg
    assertFileExists home-files/.config/systemd/user/plover.service
  '';
}
