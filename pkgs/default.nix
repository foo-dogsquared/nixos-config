{ pkgs ? import <nixpkgs> { }, overrides ? (self: super: { }) }:

with pkgs;

let
  packages = self:
    let callPackage = newScope self;
    in {
      adwcustomizer = callPackage ./adwcustomizer { libadwaita = libadwaita-latest; };
      artem = callPackage ./artem.nix { };
      auto-editor = callPackage ./auto-editor.nix { };
      awesome-cli = callPackage ./awesome-cli { };
      cosmic-launcher = callPackage ./cosmic-launcher { };
      cursedgl = callPackage ./cursedgl { };
      clidle = callPackage ./clidle.nix { };
      domterm = callPackage ./domterm { };
      freerct = callPackage ./freerct.nix { };
      furtherance = callPackage ./furtherance { };
      distant = callPackage ./distant.nix { };
      doggo = callPackage ./doggo.nix { };
      gol-c = callPackage ./gol-c.nix { };
      gnome-search-provider-recoll =
        callPackage ./gnome-search-provider-recoll.nix { };
      gnome-extension-manager = callPackage ./gnome-extension-manager.nix { };
      gnome-shell-extension-fly-pie =
        callPackage ./gnome-shell-extension-fly-pie.nix { };
      gnome-shell-extension-pop-shell =
        callPackage ./gnome-shell-extension-pop-shell.nix { };
      guile-config = callPackage ./guile-config.nix { };
      guile-hall = callPackage ./guile-hall.nix { };
      hush-shell = callPackage ./hush-shell.nix { };
      ictree = callPackage ./ictree.nix { };
      libadwaita-latest = libadwaita.overrideAttrs (super: self: {
        version = "2022-07-27";
        src = fetchFromGitLab {
          domain = "gitlab.gnome.org";
          owner = "GNOME";
          repo = "libadwaita";
          rev = "68bf0fbcfb9134bbc13345d16243ff15b1989693";
          hash = "sha256-HWtDpOsHMR2kG5nr6pfznhDoyRpGihLCA7hsT99QqdA=";
        };
      });
      libcs50 = callPackage ./libcs50.nix { };
      license-cli = callPackage ./license-cli { };
      moac = callPackage ./moac.nix { };
      mopidy-beets = callPackage ./mopidy-beets.nix { };
      mopidy-funkwhale = callPackage ./mopidy-funkwhale.nix { };
      mopidy-internetarchive = callPackage ./mopidy-internetarchive.nix { };
      nautilus-annotations = callPackage ./nautilus-annotations { };
      neuwaita-icon-theme = callPackage ./neuwaita-icon-theme { };
      onagre = callPackage ./onagre { };
      pop-launcher = callPackage ./pop-launcher.nix { };
      pop-launcher-plugin-brightness = callPackage ./pop-launcher-plugin-brightness { };
      pop-launcher-plugin-duckduckgo-bangs =
        callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
      pop-launcher-plugin-jetbrains = callPackage ./pop-launcher-plugin-jetbrains { };
      swh = callPackage ./software-heritage { python3Packages = python310Packages; };
      text-engine = callPackage ./text-engine.nix { };
      tic-80 = callPackage ./tic-80 { };
      thokr = callPackage ./thokr.nix { };
      segno = callPackage ./segno.nix { };
      smile = callPackage ./smile { };
      vpaint = libsForQt5.callPackage ./vpaint.nix { };
      vgc = libsForQt5.callPackage ./vgc { };
      watc = callPackage ./watc { };
      wayback = callPackage ./wayback.nix { };
      wzmach = callPackage ./wzmach { };
      ymuse = callPackage ./ymuse { };
    };
in
lib.fix (lib.extends overrides packages)
