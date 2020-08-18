# Android is the mobile version of Linux.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.dev.android = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.android.enable {
    my.packages = with pkgs; [
      android-studio        # The apartment for Android development.
      dart                  # It's JavaScript except saner and slimmer.
      unstable.flutter               # It's Electron except saner and slimmer.
      unstable.kotlin                # It's Java except saner and slimmer.
    ];

    # Enable Android Debug Bridge for some device debugging.
    programs.adb.enable = true;
  };
}
