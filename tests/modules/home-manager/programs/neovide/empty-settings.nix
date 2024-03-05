{ ... }:

{
  programs.neovide.enable = true;

  test.stubs.neovide = { };

  nmt.script = ''
    assertPathNotExists home-files/.config/neovide/config.toml
  '';
}
