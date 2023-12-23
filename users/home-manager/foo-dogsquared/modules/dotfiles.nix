{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.dotfiles;

  dotfiles = config.lib.file.mkOutOfStoreSymlink config.home.mutableFile."library/dotfiles".path;
  getDotfiles = path: "${dotfiles}/${path}";
in
{
  options.users.foo-dogsquared.dotfiles.enable =
    lib.mkEnableOption "custom outside dotfiles for other programs";

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
      doom.source =
        lib.mkIf userCfg.programs.doom-emacs.enable (getDotfiles "emacs");
      kitty.source =
        lib.mkIf userCfg.setups.development.enable (getDotfiles "kitty");
      nvim.source =
        lib.mkIf userCfg.setups.development.enable (getDotfiles "nvim");
      nyxt.source =
        lib.mkIf userCfg.programs.browsers.misc.enable (getDotfiles "nyxt");
      wezterm.source =
        lib.mkIf userCfg.setups.development.enable (getDotfiles "wezterm");
    };
  };
}
