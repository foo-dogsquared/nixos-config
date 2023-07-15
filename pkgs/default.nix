{ pkgs ? import <nixpkgs> { }, overrides ? (self: super: { }) }:

with pkgs;

let
  packages = self:
    let callPackage = newScope self;
    in rec {
      awesome-cli = callPackage ./awesome-cli { };
      decker = callPackage ./decker { };
      cosmic-launcher = callPackage ./cosmic-launcher { };
      clidle = callPackage ./clidle.nix { };
      domterm = callPackage ./domterm { };
      freerct = callPackage ./freerct.nix { };
      distant = callPackage ./distant.nix { };
      gnome-search-provider-recoll =
        callPackage ./gnome-search-provider-recoll.nix { };
      guile-config = callPackage ./guile-config.nix { };
      hush-shell = callPackage ./hush-shell.nix { };
      ictree = callPackage ./ictree.nix { };
      kiwmi = callPackage ./kiwmi { };
      lwp = callPackage ./lwp { };
      moac = callPackage ./moac.nix { };
      mopidy-beets = callPackage ./mopidy-beets.nix { };
      mopidy-funkwhale = callPackage ./mopidy-funkwhale.nix { };
      mopidy-internetarchive = callPackage ./mopidy-internetarchive.nix { };
      nautilus-annotations = callPackage ./nautilus-annotations { };
      neuwaita-icon-theme = callPackage ./neuwaita-icon-theme { };
      pop-launcher-plugin-brightness = callPackage ./pop-launcher-plugin-brightness { };
      pop-launcher-plugin-duckduckgo-bangs =
        callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
      pop-launcher-plugin-jetbrains = callPackage ./pop-launcher-plugin-jetbrains { };
      swh = callPackage ./software-heritage { python3Packages = python310Packages; };
      speki = callPackage ./speki { };
      tic-80 = callPackage ./tic-80 { };
      smile = callPackage ./smile { };
      vpaint = libsForQt5.callPackage ./vpaint.nix { };
      vgc = qt6Packages.callPackage ./vgc { };
      watc = callPackage ./watc { };
      wzmach = callPackage ./wzmach { };
      xs = callPackage ./xs { };
    };
in
lib.fix' (lib.extends overrides packages)
