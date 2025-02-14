{ ... }:

{
  programs.diceware.enable = true;

  test.stubs.diceware = { };

  nmt.script = ''
    assertPathNotExists home-files/.config/diceware/diceware.ini
  '';
}
