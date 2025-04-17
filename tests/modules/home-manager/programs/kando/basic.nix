{ config, lib, pkgs, ... }:

{
  programs.kando = {
    enable = true;

    settings = {
      hello = "there";
      a = "bc";
      _1 = 23;
    };

    menuSettings = {
      shortcut = "Ctrl+Space";
      shortcutId = "example-menu";
    };
  };

  nmt.script = ''
    assertFileExists home-files/.config/kando/config.json
    assertFileExists home-files/.config/kando/menus.json
  '';
}
