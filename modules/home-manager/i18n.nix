{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.i18n;
in
  {
    options.modules.i18n.enable = lib.mkEnableOption "Enable fcitx5 as input method engine.";

    config = lib.mkIf cfg.enable {
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
    };
  }
