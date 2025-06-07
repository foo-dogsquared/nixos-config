{ lib, pkgs, ... }:

{
  services.plover = {
    enable = true;
    settings = {
      "Output Configuration" = { undo_levels = 100; };

      "Stroke Display" = { show = true; };
    };
  };

  nmt.script = ''
    assertFileExists home-files/.config/plover/plover.cfg
    assertFileExists home-files/.config/systemd/user/plover.service
  '';
}
