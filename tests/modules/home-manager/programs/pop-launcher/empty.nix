{ pkgs, ... }:

{
  programs.pop-launcher.enable = true;

  test.stubs.pop-launcher = { };

  nmt.script = ''
    assertDirectoryEmpty home-files/.local/share/pop-launcher
  '';
}
