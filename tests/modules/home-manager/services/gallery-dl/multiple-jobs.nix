{ config, ... }:

{
  services.gallery-dl = {
    enable = true;
    archivePath = "${config.xdg.userDirs.pictures}/gallery-dl";

    extraArgs = [
      # Record all downloaded files in an archive file.
      "--download-archive"
      "${config.services.gallery-dl.archivePath}/photos"

      "--date" "today-1week" # get only videos from a week ago
      "--output" "%(uploader)s/%(title)s.%(ext)s" # download them in the respective directory
    ];

    jobs = {
      art = {
        urls = [
          "https://www.pixiv.net/en/users/60562229"
          "https://www.deviantart.com/xezeno"
        ];
        startAt = "weekly";
      };

      webcomics = {
        urls = [
          "https://www.webtoons.com/en/comedy/mono-and-mochi/list?title_no=6019"
        ];
        startAt = "daily";
        extraArgs = [
          "--date" "today-2week" # get only videos from a week ago
        ];
      };
    };
  };

  test.stubs.gallery-dl = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/gallery-dl-job-art.service
    assertFileExists home-files/.config/systemd/user/gallery-dl-job-art.timer

    assertFileExists home-files/.config/systemd/user/gallery-dl-job-webcomics.service
    assertFileExists home-files/.config/systemd/user/gallery-dl-job-webcomics.timer
  '';
}
