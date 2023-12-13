# System-wide i18n options. This is primarily used for desktop installations.
# Unless there is really good reasons for setting i18n options on the server,
# this module will stay aiming for desktop.
{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.i18n;
in
{
  options.profiles.i18n = {
    enable = lib.mkEnableOption "main i18n config";
    setup = lib.mkOption {
      type = lib.types.enum [ "fcitx5" "ibus" ];
      description = ''
        The primary input method engine to be used and its related
        configuration and setup.
      '';
      default = "fcitx5";
      example = "ibus";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # I don't speak all of the languages. It's just nice to have some
      # additional language packs for it. ;p
      i18n.supportedLocales = lib.mkForce [ "all" ];

      # The most minimal set of packages for most locales.
      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-lgc-plus
        noto-fonts-extra
        noto-fonts-emoji
        noto-fonts-emoji-blob-bin

        source-code-pro
        source-sans-pro
        source-han-sans
        source-serif-pro
        source-han-serif
        source-han-mono
      ];
    }

    (lib.mkIf (cfg.setup == "ibus") {
      i18n.inputMethod = {
        enabled = "ibus";
        ibus.engines = with pkgs.ibus-engines; [
          mozc
          rime
          hangul
          table
          table-others
          typing-booster
          uniemoji
        ];
      };
    })

    (lib.mkIf (cfg.setup == "fcitx5") {
      i18n.inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-lua
          fcitx5-mozc
          fcitx5-rime
          fcitx5-table-extra
          fcitx5-table-other
          fcitx5-unikey
        ];
      };
    })
  ]);
}
