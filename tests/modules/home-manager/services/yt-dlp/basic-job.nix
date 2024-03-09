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

    jobs.art = {
      urls = [
        "https://www.youtube.com/@Jazza"
        "https://www.youtube.com/@bobross_thejoyofpainting"
        "https://www.youtube.com/@DavidRevoy"
      ];
      startAt = "weekly";
    };
  };

  test.stubs.yt-dlp = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/yt-dlp-job-art.service
    assertFileExists home-files/.config/systemd/user/yt-dlp-job-art.timer
  '';
}
