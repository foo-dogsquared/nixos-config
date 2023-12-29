{ config, lib, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.dconf;
in
{
  options.users.foo-dogsquared.programs.dconf.enable =
    lib.mkEnableOption "dconf configuration";

  config = lib.mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps =
          lib.optional userCfg.programs.browsers.firefox.enable "firefox.desktop"
          ++ lib.optional userCfg.setups.desktop.enable "thunderbird.desktop"
          ++ lib.optional userCfg.setups.development.enable "org.wezfurlong.wezterm.desktop"
          ++ lib.optional userCfg.programs.doom-emacs.enable "emacs.desktop";
      };

      "org/gnome/calculator" = {
        button-mode = "basic";
        show-thousands = true;
        base = 10;
        word-size = 64;
      };
    };
  };
}
