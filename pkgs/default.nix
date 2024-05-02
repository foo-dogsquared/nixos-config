{ pkgs ? import <nixpkgs> { } }:

with pkgs;
lib.makeScope newScope (self: {
  awesome-cli = callPackage ./awesome-cli { };
  base16-builder-go = callPackage ./base16-builder-go { };
  blender-blendergis = python3Packages.callPackage ./blender-blendergis { };
  blender-machin3tools = python3Packages.callPackage ./blender-machin3tools { };
  clidle = callPackage ./clidle.nix { };
  domterm = libsForQt5.callPackage ./domterm { };
  fastn = callPackage ./fastn { };
  freerct = callPackage ./freerct.nix { };
  distant = callPackage ./distant.nix { };
  gnome-search-provider-recoll =
    callPackage ./gnome-search-provider-recoll.nix { };
  hush-shell = callPackage ./hush-shell.nix { };
  lwp = callPackage ./lwp { };
  moac = callPackage ./moac.nix { };
  mopidy-beets = callPackage ./mopidy-beets.nix { };
  mopidy-funkwhale = callPackage ./mopidy-funkwhale.nix { };
  mopidy-internetarchive = callPackage ./mopidy-internetarchive.nix { };
  nautilus-annotations = callPackage ./nautilus-annotations { };
  niri = callPackage ./niri { };
  pop-launcher-plugin-brightness = callPackage ./pop-launcher-plugin-brightness { };
  pop-launcher-plugin-duckduckgo-bangs =
    callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
  pop-launcher-plugin-jetbrains = callPackage ./pop-launcher-plugin-jetbrains { };
  swh = callPackage ./software-heritage { python3Packages = python310Packages; };
  speki = callPackage ./speki { };
  tic-80 = callPackage ./tic-80 { };
  smile = callPackage ./smile { };
  sessiond = callPackage ./sessiond { };
  uwsm = callPackage ./uwsm { };
  vgc = qt6Packages.callPackage ./vgc { };
  watc = callPackage ./watc { };
  wzmach = callPackage ./wzmach { };
  xs = callPackage ./xs { };
})
