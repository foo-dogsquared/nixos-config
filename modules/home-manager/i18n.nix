# Instant setup for using internationalized languages.
{ config, options, lib, pkgs, ... }:

let cfg = config.modules.i18n;
in {
  options.modules.i18n.enable =
    lib.mkEnableOption "fcitx5 as input method engine";

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-extra
      noto-fonts-emoji
    ];

    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk # Add support for GTK-based programs.
        libsForQt5.fcitx5-qt # Add support for QT-based programs.
        fcitx5-lua # Add Lua support.
        fcitx5-rime # Chinese input addon.
        fcitx5-mozc # Japanese input addon.
      ];
    };

    # The i18n module has already set session variables but just to be sure...
    systemd.user.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
    };
  };
}
