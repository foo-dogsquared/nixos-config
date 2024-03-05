{ config, lib, ... }: {
  programs.neovide = {
    enable = true;
    settings = {
      maximized = true;
      font = {
        normal = [ "MonoLisa Nerd Font" ];
        size = 18;
        features.MonoLisa = [
          "+ss01"
          "+ss07"
          "+ss11"
          "-calt"
          "+ss09"
          "+ss02"
          "+ss14"
          "+ss16"
          "+ss17"
        ];
      };
    };
  };

  test.stubs.neovide = { };

  nmt.script = ''
    assertFileExists home-files/.config/neovide/config.toml
  '';
}
