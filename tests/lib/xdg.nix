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

  testGetXdgAutostartFile = {
    expr = self.xdg.getXdgAutostartFile pkgs.valent "valent";
    expected = "${pkgs.valent}/etc/xdg/autostart/valent.desktop";
  };

  # This should be a naive function so it should just naively get things.
  testGetXdgAutostartFile2 = {
    expr = self.xdg.getXdgAutostartFile pkgs.hello "non-existing-autostart";
    expected = "${pkgs.hello}/etc/xdg/autostart/non-existing-autostart.desktop";
  };
}
