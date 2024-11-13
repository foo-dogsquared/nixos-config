# Based from the examples from NixPak.
{ config, lib, pkgs, ... }:

{
  build.variant = "shell";
  wrappers.hello = {
    wraparound.variant = "bubblewrap";
    wraparound.subwrapper.arg0 = lib.getExe' pkgs.hello "hello";
    wraparound.bubblewrap.dbus = {
      enable = true;
      filter.addresses = {
        "org.freedesktop.systemd1".policies.level = "talk";
        "org.gtk.vfs.*".policies.level = "talk";
        "org.gtk.vfs".policies.level = "talk";
      };
    };
  };
}
