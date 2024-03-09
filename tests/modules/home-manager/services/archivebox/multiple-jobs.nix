{ config, ... }:

{
  services.archivebox = {
    enable = true;
    archivePath = "${config.xdg.userDirs.documents}/ArchiveBox";

    jobs = {
      art = {
        links = [
          "https://www.davidrevoy.com/"
          "https://www.youtube.com/c/ronillust"
        ];
        startAt = "weekly";
      };

      research = {
        links = [
          "https://arxiv.org/rss/cs"
          "https://distill.pub/"
        ];
        extraArgs = [ "--depth" "1" ];
        startAt = "daily";
      };

      tech = {
        links = [
          "https://thisweek.gnome.org/index.xml"
          "https://pointieststick.com/feed"
          "https://planet.gnome.org/atom.xml"
          "https://planet.kde.org/atom.xml"
        ];
        startAt = "daily";
      };
    };
  };

  test.stubs.archivebox = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/archivebox-job-art.service
    assertFileExists home-files/.config/systemd/user/archivebox-job-art.timer

    assertFileExists home-files/.config/systemd/user/archivebox-job-research.service
    assertFileExists home-files/.config/systemd/user/archivebox-job-research.timer

    assertFileExists home-files/.config/systemd/user/archivebox-job-tech.service
    assertFileExists home-files/.config/systemd/user/archivebox-job-tech.timer
  '';
}
