{ config, lib, pkgs, ... }:

{
  services.matcha = {
    enable = true;
    package = pkgs.matcha-rss-digest;

    settings = {
      markdown_dir_path = "${config.xdg.userDirs.documents}/Matcha";
      feeds = [
        "http://hnrss.org/best"
        "https://waitbutwhy.com/feed"
        "http://tonsky.me/blog/atom.xml"
        "http://www.joelonsoftware.com/rss.xml"
        "https://www.youtube.com/feeds/videos.xml?channel_id=UCHnyfMqiRRG1u-2MsSQLbXA"

      ];
      markdown_file_prefix = "doggo";
    };
  };

  test.stubs.matcha-rss-digest = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/matcha.timer
    assertFileExists home-files/.config/systemd/user/matcha.service
  '';
}
