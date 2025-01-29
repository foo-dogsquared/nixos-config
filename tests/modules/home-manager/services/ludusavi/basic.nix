{ config, ... }:

{
  services.ludusavi = {
    enable = true;
    extraArgs = [ "--force" "--compression zstd" "--compression-level 15" ];
    settings = {
      manifest.url =
        "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
      backup.path = "${config.xdg.cacheHome}/ludusavi/backups";
      restore.path = "${config.xdg.cacheHome}/ludusavi/backups";
    };
  };

  test.stubs.ludusavi = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/ludusavi.service
    assertFileExists home-files/.config/systemd/user/ludusavi.timer
  '';
}
