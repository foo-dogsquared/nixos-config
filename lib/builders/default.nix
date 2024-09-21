{ pkgs, lib, self }:

{
  makeXDGMimeAssociationList = pkgs.callPackage ./xdg/make-association-list.nix { };
  makeXDGPortalConfiguration = pkgs.callPackage ./xdg/make-portal-config.nix { };
  makeXDGDesktopEntry = pkgs.callPackage ./xdg/make-desktop-entry.nix { };
  buildHugoSite = pkgs.callPackage ./hugo-build-site { };
}
