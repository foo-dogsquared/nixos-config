{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.dotfiles;

  projectsDir = config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR;

  dotfiles = "${projectsDir}/packages/dotfiles";
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
    }

    (lib.mkIf (userCfg.programs.doom-emacs.enable) {
      xdg.configFile.doom.source = getDotfiles "emacs";
    })

    (lib.mkIf (userCfg.setups.development.enable) {
      xdg.configFile = {
        kitty.source = getDotfiles "emacs";
        wezterm.source = getDotfiles "wezterm";
      };
    })

    (lib.mkIf (userCfg.programs.browsers.misc.enable) {
      xdg.configFile.nyxt.source = getDotfiles "nyxt";
    })

    (lib.mkIf (!userCfg.programs.nixvim.enable) {
      xdg.configFile.nvim.source = getDotfiles "nvim";
    })
  ]);
}
