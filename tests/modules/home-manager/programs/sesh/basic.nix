{ config, lib, ... }: {
  programs.sesh = {
    enable = true;
    settings = {
      default_session = {
        startup_command = "nvim -c ':Telescope find_files'";
        preview_command = "eza --all --git --icons --color=always {}";
      };

      session = [
        {
          name = "Downloads";
          path = config.xdg.userDirs.downloads;
          startup_command = "ls";
        }

        {
          name = "tmux config";
          path = "~/c/dotfiles/tmux_config";
          startup_command = "nvim tmux.conf";
          preview_command = "bat --color=always ~/c/dotfiles/.config/tmux/tmux.conf";
        }
      ];
    };
  };

  test.stubs.sesh = { };

  nmt.script = ''
    assertFileExists home-files/.config/sesh/sesh.toml
  '';
}
