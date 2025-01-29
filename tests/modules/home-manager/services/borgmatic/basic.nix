{ config, lib, pkgs, ... }:

{
  services.borgmatic.jobs.personal = { settings = { hello = "WORLD"; }; };

  test.stubs.borgmatic = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/borgmatic-job-personal.service
    assertFileExists home-files/.config/systemd/user/borgmatic-job-personal.timer
  '';
}
