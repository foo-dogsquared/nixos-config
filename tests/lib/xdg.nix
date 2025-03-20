{ pkgs, lib, self }:

lib.runTests {
  testGetXdgDesktop = {
    expr = self.xdg.getXdgDesktop pkgs.wezterm "org.wezfurlong.wezterm";
    expected = "${pkgs.wezterm}/share/applications/org.wezfurlong.wezterm.desktop";
  };

  # This should be a naive function so it should just naively get things.
  testGetXdgDesktop2 = {
    expr = self.xdg.getXdgDesktop pkgs.hello "non-existing-desktop";
    expected = "${pkgs.hello}/share/applications/non-existing-desktop.desktop";
  };
}
