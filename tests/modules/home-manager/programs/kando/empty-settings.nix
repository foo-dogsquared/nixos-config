{ config, lib, pkgs, ... }:

{
  programs.kando.enable = true;

  nmt.script = ''
    assertPathNotExists home-files/.config/kando/config.json
    assertPathNotExists home-files/.config/kando/menus.json
  '';
}
