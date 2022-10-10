# System-wide i18n options.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.profiles.i18n;
in
{
  options.profiles.i18n = {
    enable = lib.mkEnableOption "main i18n config";
    ibus.enable = lib.mkEnableOption "i18n config with ibus";
    fcitx5.enable = lib.mkEnableOption "i18n config with fcitx5";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = let enabledi18nConfigs = lib.countAttrs (_: setup: lib.isAttrs setup && setup.enable) cfg; in
        [{
          assertion = enabledi18nConfigs <= 1;
          message = ''
            Only one i18n setup should be enabled at any given time.
          '';
        }];

      # I don't speak all of the listed languages. It's just nice to have some
      # additional language packs for it. ;p
      i18n.supportedLocales = lib.mkBefore [
        "en_US.UTF-8/UTF-8"
        "ja_JP.UTF-8/UTF-8"
        "ko_KR.UTF-8/UTF-8"
        "zh_CN.UTF-8/UTF-8"
        "zh_HK.UTF-8/UTF-8"
        "zh_SG.UTF-8/UTF-8"
        "tl_PH.UTF-8/UTF-8"
        "fr_FR.UTF-8/UTF-8"
        "it_IT.UTF-8/UTF-8"
      ];

      environment.systemPackages = with pkgs; [
        goldendict
      ];

      # The most minimal set of packages for most locales.
      fonts.fonts = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        source-code-pro
        source-sans-pro
        source-han-sans
        source-serif-pro
        source-han-serif
        source-han-mono
      ];
    }

    (lib.mkIf cfg.ibus.enable {
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

    (lib.mkIf cfg.fcitx5.enable {
      i18n.inputMethod = {
        enabled = "fcitx5";
        fcitx5 = {
          enableRimeData = true;
          addons = with pkgs; [
            fcitx5-lua
            fcitx5-mozc
            fcitx5-rime
            fcitx5-table-extra
            fcitx5-table-other
            fcitx5-unikey
          ];
        };
      };
    })
  ]);
}
