{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.dotfiles;

  projectsDir = config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR;

  dotfiles = "${projectsDir}/dotfiles";
  dotfiles' = config.lib.file.mkOutOfStoreSymlink config.home.mutableFile."${dotfiles}".path;
  getDotfiles = path: "${dotfiles'}/${path}";
in
{
  options.users.foo-dogsquared.dotfiles.enable =
    lib.mkEnableOption "custom outside dotfiles for other programs";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.mutableFile.${dotfiles} = {
        url = "https://github.com/foo-dogsquared/dotfiles.git";
        type = "git";
      };

      home.sessionPath = [
        "${config.home.mutableFile.${dotfiles}.path}/bin"
      ];

      xdg.configFile = {
        doom.source =
          lib.mkIf userCfg.programs.doom-emacs.enable (getDotfiles "emacs");
        kitty.source =
          lib.mkIf userCfg.setups.development.enable (getDotfiles "kitty");
        nyxt.source =
          lib.mkIf userCfg.programs.browsers.misc.enable (getDotfiles "nyxt");
        wezterm.source =
          lib.mkIf userCfg.setups.development.enable (getDotfiles "wezterm");
      };
    }

    (lib.mkIf (!userCfg.programs.nixvim.enable) {
      xdg.configFile.nvim.source = getDotfiles "nvim";
    })
  ]);
}
