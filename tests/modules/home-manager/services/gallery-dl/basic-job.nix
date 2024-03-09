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

    jobs.art = {
      urls = [
        "https://www.pixiv.net/en/users/60562229"
        "https://www.deviantart.com/xezeno"
      ];
      startAt = "weekly";
    };
  };

  test.stubs.gallery-dl = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/gallery-dl-job-art.service
    assertFileExists home-files/.config/systemd/user/gallery-dl-job-art.timer
  '';
}
