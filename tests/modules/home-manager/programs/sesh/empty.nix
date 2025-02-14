{ ... }:

{
  programs.diceware.enable = true;

  test.stubs.sesh = { };

  nmt.script = ''
    assertPathNotExists home-files/.config/diceware/diceware.ini
  '';
}
