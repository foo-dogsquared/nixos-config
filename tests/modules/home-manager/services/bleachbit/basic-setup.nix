{ lib, ... }:

{
  services.bleachbit = {
    enable = true;
    startAt = "weekly";
    cleaners =
      [ "firefox.cookies" "firefox.history" "discord.logs" "zoom.logs" ];
  };

  test.stubs.bleachbit = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/bleachbit.service
    assertFileExists home-files/.config/systemd/user/bleachbit.timer
  '';
}
