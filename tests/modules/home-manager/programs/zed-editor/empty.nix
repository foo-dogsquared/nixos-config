{ ... }:

{
  programs.zed-editor.enable = true;

  test.stubs.zed-editor = { };

  nmt.script = ''
    assertPathNotExists home-files/.config/zed/settings.json
  '';
}
