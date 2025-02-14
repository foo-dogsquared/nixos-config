{ config, lib, ... }: {
  programs.diceware = {
    enable = true;
    settings.diceware = {
      num = 7;
      specials = 2;
    };
  };

  test.stubs.diceware = { };

  nmt.script = ''
    assertFileExists home-files/.config/diceware/diceware.ini
  '';
}
