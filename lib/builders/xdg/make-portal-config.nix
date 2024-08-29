{ lib, writeTextFile }:

/* Create an XDG Portals configuration with the given desktop name and its
 configuration. Similarly, the given desktop name is assumed to be already
 in its suitable form of a lowercase ASCII.
*/
{
  desktopName ? "common",

  # Nix-representable data to be exported as the portal configuration.
  config,
}:
writeTextFile {
  name = "xdg-portal-config${lib.optionalString (desktopName != "common") "-${desktopName}"}";
  text = lib.generators.toINI { } config;
  destination = "/share/xdg-desktop-portal/${lib.optionalString (desktopName != "common") "${desktopName}-"}portals.conf";
}
