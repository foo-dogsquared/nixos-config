{ config, ... }:

{
  services.yt-dlp = {
    enable = true;

    extraArgs = [
      "--no-force-overwrites"
      "--write-info-json"

      "--embed-chapters"

      "--download-archive"
      "${config.xdg.userDirs.videos}/Archive"
    ];

    jobs = {
      art = {
        urls = [
          "https://www.youtube.com/@Jazza"
          "https://www.youtube.com/@bobross_thejoyofpainting"
          "https://www.youtube.com/@DavidRevoy"
        ];
        startAt = "monthly";
      };

      music = {
        extraArgs = [
          "--extract-audio"
        ];
        urls = [
          "https://www.youtube.com/@dragonforce"
          "https://www.youtube.com/channel/UCjZjUymRDAhp9c1rb0X6aww" # 500L/g
          "https://www.youtube.com/channel/UCOnUfJpp-Fg8X2TnuH_JD7w" # ALAMAT
        ];
        startAt = "daily";
      };

      miscellanea = {
        urls = [
          "https://www.youtube.com/@SabatonHistory"
          "https://www.youtube.com/channel/UCUaiGrBfRCaC6pL7ZnZjWbg" # JK Brickworks
          "https://www.youtube.com/channel/UCdJdEguB1F1CiYe7OEi3SBg" # JonTronShow
          "https://www.youtube.com/channel/UCm9K6rby98W8JigLoZOh6FQ" # LockPickingLawyer
        ];
        startAt = "weekly";
      };
    };
  };

  test.stubs.yt-dlp = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/yt-dlp-archive-service-art.service
    assertFileExists home-files/.config/systemd/user/yt-dlp-archive-service-art.timer

    assertFileExists home-files/.config/systemd/user/yt-dlp-archive-service-music.service
    assertFileExists home-files/.config/systemd/user/yt-dlp-archive-service-music.timer

    assertFileExists home-files/.config/systemd/user/yt-dlp-archive-service-miscellanea.service
    assertFileExists home-files/.config/systemd/user/yt-dlp-archive-service-miscellanea.timer

    assertPathNotExists home-files/.config/yt-dlp/config
  '';
}
