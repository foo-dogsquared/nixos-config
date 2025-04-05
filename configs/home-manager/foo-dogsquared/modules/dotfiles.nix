{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.dotfiles;

  projectsDir = config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR;

  dotfiles = "${projectsDir}/packages/dotfiles";
  dotfiles' = config.lib.file.mkOutOfStoreSymlink
    config.home.mutableFile."${dotfiles}".path;
  getDotfiles = path: "${dotfiles'}/${path}";
in {
  options.users.foo-dogsquared.dotfiles.enable =
    lib.mkEnableOption "custom outside dotfiles for other programs";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.mutableFile.${dotfiles} = {
        url = "https://github.com/foo-dogsquared/dotfiles.git";
        type = "git";
      };

      home.sessionPath = [ "${config.home.mutableFile.${dotfiles}.path}/bin" ];
    }

    (lib.mkIf (userCfg.programs.doom-emacs.enable) {
      xdg.configFile.doom.source = getDotfiles "emacs";
    })

    (lib.mkIf (userCfg.setups.development.enable) {
      xdg.configFile = {
        kitty.source = getDotfiles "kitty";
        wezterm.source = getDotfiles "wezterm";
      };
    })

    (lib.mkIf (userCfg.programs.browsers.misc.enable) {
      xdg.configFile.nyxt.source = getDotfiles "nyxt";
    })

    # Comes with a heavy assumption that the Neovim configuration found in this
    # home-manager environment will not write to the XDG config directory.
    (lib.mkIf (config.programs.neovim.enable) {
      xdg.configFile.nvim.source = getDotfiles "nvim";

      programs.neovim.extraPackages = with pkgs; [
        luarocks
        shfmt
        cmake

        # Just assume that there is no clipboard thingy that is already managed
        # within this home-manager configuration.
        wl-clipboard
        xclip
      ];
    })

    (lib.mkIf config.programs.nushell.enable {
      home.file."${config.xdg.dataHome}/nushell/vendor/autoload".source =
        getDotfiles "nu/autoload";
    })

    (lib.mkIf config.programs.helix.enable {
      xdg.configFile.helix.source = getDotfiles "helix";
    })
  ]);
}
