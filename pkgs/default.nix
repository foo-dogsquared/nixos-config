{ pkgs ? import <nixpkgs> { } }:

with pkgs;
lib.makeScope newScope (self: {
  # My custom nixpkgs extensions.
  foodogsquaredLib = import ../lib { inherit pkgs; };
  inherit (self.foodogsquaredLib.builders)
    makeXDGMimeAssociationList makeXDGPortalConfiguration makeXDGDesktopEntry
    buildHugoSite;
  inherit (self.foodogsquaredLib.fetchers)
    fetchInternetArchive;

  # My custom packages.
  awesome-cli = callPackage ./awesome-cli { };
  base16-builder-go = callPackage ./base16-builder-go { };
  blender-blendergis = python3Packages.callPackage ./blender-blendergis { };
  blender-machin3tools = python3Packages.callPackage ./blender-machin3tools { };
  clidle = callPackage ./clidle.nix { };
  ctrld = callPackage ./ctrld { };
  domterm = libsForQt5.callPackage ./domterm { };
  fastn = callPackage ./fastn { };
  flatsync = callPackage ./flatsync { };
  freerct = callPackage ./freerct.nix { };
  distant = callPackage ./distant.nix { };
  gnome-search-provider-recoll =
    callPackage ./gnome-search-provider-recoll.nix { };
  hush-shell = callPackage ./hush-shell.nix { };
  lazyjj = callPackage ./lazyjj { };
  lwp = callPackage ./lwp { };
  moac = callPackage ./moac.nix { };
  mopidy-beets = callPackage ./mopidy-beets.nix { };
  mopidy-funkwhale = callPackage ./mopidy-funkwhale.nix { };
  mopidy-internetarchive = callPackage ./mopidy-internetarchive.nix { };
  nautilus-annotations = callPackage ./nautilus-annotations { };
  pop-launcher-plugin-brightness = callPackage ./pop-launcher-plugin-brightness { };
  pop-launcher-plugin-duckduckgo-bangs =
    callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
  pop-launcher-plugin-jetbrains = callPackage ./pop-launcher-plugin-jetbrains { };
  pigeon-mail = callPackage ./pigeon-mail { };
  swh = callPackage ./software-heritage { python3Packages = python310Packages; };
  speki = callPackage ./speki { };
  tic-80 = callPackage ./tic-80 { };
  smile = callPackage ./smile { };
  sessiond = callPackage ./sessiond { };
  uwsm = callPackage ./uwsm { };
  vgc = qt5.callPackage ./vgc { };
  watc = callPackage ./watc { };
  willow = callPackage ./willow { };
  wzmach = callPackage ./wzmach { };
  xs = callPackage ./xs { };
})
