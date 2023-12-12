{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.dotfiles;

  dotfiles = config.lib.file.mkOutOfStoreSymlink config.home.mutableFile."library/dotfiles".path;
  getDotfiles = path: "${dotfiles}/${path}";
in
{
  options.users.foo-dogsquared.dotfiles.enable = lib.mkEnableOption "custom outside dotfiles for other programs";

  config = lib.mkIf cfg.enable {
    # Fetching my dotfiles,...
    home.mutableFile."library/dotfiles" = {
      url = "https://github.com/foo-dogsquared/dotfiles.git";
      type = "git";
    };

    # Add the custom scripts here.
    home.sessionPath = [
      "${config.home.mutableFile."library/dotfiles".path}/bin"
    ];

    # All of the personal configurations.
    xdg.configFile = {
      doom.source = getDotfiles "emacs";
      kitty.source = getDotfiles "kitty";
      nvim.source = getDotfiles "nvim";
      nyxt.source = getDotfiles "nyxt";
      wezterm.source = getDotfiles "wezterm";
    };
  };
}
