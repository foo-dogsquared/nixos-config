{ lib, ... }:

{
  programs.pipewire.enable = true;

  test.stubs.pipewire = { };

  nmt.script = ''
    assertPathNotExists home-files/.config/pipewire/pipewire.conf
    assertPathNotExists home-files/.config/pipewire/pipewire.conf.d
  '';
}
