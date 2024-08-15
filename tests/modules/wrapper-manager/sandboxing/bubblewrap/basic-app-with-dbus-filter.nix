# Based from the examples from NixPak.
{ config, lib, pkgs, ... }:

{
  build.isBinary = false;
  wrappers.hello = {
    sandboxing.variant = "bubblewrap";
    sandboxing.wraparound.arg0 = lib.getExe' pkgs.hello "hello";
    sandboxing.bubblewrap.dbus = {
      enable = true;
      filter.addresses = {
        "org.freedesktop.systemd1".policies.level = "talk";
        "org.gtk.vfs.*".policies.level = "talk";
        "org.gtk.vfs".policies.level = "talk";
      };
    };
  };
}
