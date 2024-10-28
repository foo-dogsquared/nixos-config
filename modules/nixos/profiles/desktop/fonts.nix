# A subprofile for desktop handling the fonts.
{ config, lib, pkgs, ... }:

{
  fonts.enableDefaultPackages = lib.mkDefault true;
  fonts.fontDir.enable = lib.mkDefault true;

  fonts.fontconfig = {
    enable = lib.mkDefault true;
    includeUserConf = true;

    defaultFonts = {
      monospace = [ "Iosevka" "Jetbrains Mono" "Source Code Pro" ];
      sansSerif = [ "Source Sans Pro" "Noto Sans" ];
      serif = [ "Source Serif Pro" "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  fonts.packages = with pkgs; [
    # Some monospace fonts.
    iosevka
    monaspace
    jetbrains-mono

    # Noto font family with the MR. WORLDWIDE settings.
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-lgc-plus
    noto-fonts-extra
    noto-fonts-emoji
    noto-fonts-emoji-blob-bin

    # Adobe Source font family
    source-code-pro
    source-sans-pro
    source-han-sans
    source-serif-pro
    source-han-serif
    source-han-mono

    # Math fonts
    stix-two # Didn't know rivers can have sequels.
    xits-math # NOTE TO SELF: I wouldn't consider to name the fork with its original project's name backwards.
  ];
}
