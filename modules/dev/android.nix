# Android is the mobile version of Linux.
{ config, options, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.dev.android;
in {
  options.modules.dev.android = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      android-studio # The apartment for Android development.
      dart # It's JavaScript except saner and slimmer.
      flutter # It's Electron except saner and slimmer.
      kotlin # It's Java except saner and slimmer.
      scrcpy # Cast your phone over TCP/IP!
    ];

    # Enable Android Debug Bridge for some device debugging.
    programs.adb.enable = true;

    # Install Anbox emulation.
    virtualisation.anbox.enable = true;

    my.user.extraGroups = [ "adbusers" ];
  };
}
