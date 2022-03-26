{ pkgs ? import <nixpkgs> { }, overrides ? (self: super: { }) }:

with pkgs;

let
  packages = self:
    let callPackage = newScope self;
    in {
      auto-editor = callPackage ./auto-editor.nix { };
      blueprint-compiler = callPackage ./blueprint-compiler.nix { };
      butler = callPackage ./butler.nix { };
      clidle = callPackage ./clidle.nix { };
      distant = callPackage ./distant.nix { };
      devdocs-desktop = callPackage ./devdocs-desktop.nix { };
      doggo = callPackage ./doggo.nix { };
      emulsion-palette = callPackage ./emulsion-palette.nix { };
      gol-c = callPackage ./gol-c.nix { };
      gnome-search-provider-browser-tabs = callPackage ./gnome-search-provider-browser-tabs.nix { };
      gnome-search-provider-recoll = callPackage ./gnome-search-provider-recoll.nix { };
      gnome-shell-extension-burn-my-windows =
        callPackage ./gnome-shell-extension-burn-my-windows.nix { };
      gnome-extension-manager = callPackage ./gnome-extension-manager.nix { };
      gnome-shell-extension-desktop-cube =
        callPackage ./gnome-shell-extension-desktop-cube.nix { };
      gnome-shell-extension-fly-pie =
        callPackage ./gnome-shell-extension-fly-pie.nix { };
      gnome-shell-extension-pop-shell =
        callPackage ./gnome-shell-extension-pop-shell.nix { };
      guile-config = callPackage ./guile-config.nix { };
      guile-hall = callPackage ./guile-hall.nix { };
      hoppscotch-cli = callPackage ./hoppscotch-cli.nix { };
      ictree = callPackage ./ictree.nix { };
      junction = callPackage ./junction.nix { };
      libcs50 = callPackage ./libcs50.nix { };
      moac = callPackage ./moac.nix { };
      mopidy-beets = callPackage ./mopidy-beets.nix { };
      mopidy-funkwhale = callPackage ./mopidy-funkwhale.nix { };
      mopidy-internetarchive = callPackage ./mopidy-internetarchive.nix { };
      pop-launcher = callPackage ./pop-launcher.nix { };
      pop-launcher-plugin-duckduckgo-bangs =
        callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
      tic-80 = callPackage ./tic-80 { };
      segno = libsForQt5.callPackage ./segno.nix { };
      sioyek = libsForQt5.callPackage ./sioyek.nix { };
      vpaint = libsForQt5.callPackage ./vpaint.nix { };
    };
in lib.fix (lib.extends overrides packages)
