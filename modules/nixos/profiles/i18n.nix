# System-wide i18n options.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.profiles.i18n;
in {
  options.profiles.i18n.enable = lib.mkEnableOption "i18n-related options";

  config = lib.mkIf cfg.enable {
    # I don't speak all of the listed languages. It's just nice to have some
    # additional language packs for it. ;p
    i18n.supportedLocales = [
      "en_US.UTF-8"
      "ja_JP.UTF-8"
      "ko_KR.UTF-8"
      "zh_CN.UTF-8"
      "zh_HK.UTF-8"
      "zh_SG.UTF-8"
      "tl_PH.UTF-8"
      "fr_FR.UTF-8"
      "it_IT.UTF-8"
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
  };
}
