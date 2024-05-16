{ config, lib, ... }: {
  programs.zed-editor = {
    enable = true;
    settings = {
      autosave = "off";
      confirm_quit = true;
    };
  };

  test.stubs.zed-editor = { };

  nmt.script = ''
    assertFileExists home-files/.config/zed/settings.json
  '';
}
