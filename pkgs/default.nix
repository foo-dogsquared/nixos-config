{ pkgs ? import <nixpkgs> { }, overrides ? (self: super: { }) }:

with pkgs;

let
  packages = self:
    let callPackage = newScope self;
    in rec {
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
      gnome-shell-extension-burn-my-windows = callPackage ./gnome-shell-extension-burn-my-windows { };
      gnome-shell-extension-fly-pie =
        callPackage ./gnome-shell-extension-fly-pie.nix { };
      gnome-shell-extension-pop-shell =
        callPackage ./gnome-shell-extension-pop-shell.nix { };
      gnome-shell-extension-paperwm-latest = gnomeExtensions.paperwm.overrideAttrs (prev: {
        rev = "unstable-2022-10-24";
        src = fetchFromGitHub {
          owner = "paperwm";
          repo = "PaperWM";
          rev = "13ccdfa64d56da2e20f4adda2c0166109aa54397";
          sha256 = "sha256-wUYXyv+UMWKb9IB+poZWeXadQpdrOsbv9qcPAsH++xU=";
        };
      });
      gradience = callPackage ./gradience { libadwaita = libadwaita-latest; };
      guile-config = callPackage ./guile-config.nix { };
      guile-hall = callPackage ./guile-hall.nix { };
      gnome-info-collect = callPackage ./gnome-info-collect { };
      hush-shell = callPackage ./hush-shell.nix { };
      ictree = callPackage ./ictree.nix { };
      kiwmi = callPackage ./kiwmi { };
      libadwaita-latest = libadwaita.overrideAttrs (super: self: {
        version = "1.2.0";
        src = fetchFromGitLab {
          domain = "gitlab.gnome.org";
          owner = "GNOME";
          repo = "libadwaita";
          rev = "1.2.0";
          hash = "sha256-3lH7Vi9M8k+GSrCpvruRpLrIpMoOakKbcJlaAc/FK+U=";
        };
      });
      libcs50 = callPackage ./libcs50.nix { };
      license-cli = callPackage ./license-cli { };
      lwp = callPackage ./lwp { };
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
      python-material-color-utilities = callPackage ./python-material-color-utilities { };
      swh = callPackage ./software-heritage { python3Packages = python310Packages; };
      text-engine = callPackage ./text-engine.nix { };
      tic-80 = callPackage ./tic-80 { };
      thokr = callPackage ./thokr.nix { };
      segno = callPackage ./segno.nix { };
      smile = callPackage ./smile { };
      vipsdisp = callPackage ./vipsdisp { };
      vpaint = libsForQt5.callPackage ./vpaint.nix { };
      vgc = libsForQt5.callPackage ./vgc { };
      watc = callPackage ./watc { };
      wayback = callPackage ./wayback.nix { };
      wzmach = callPackage ./wzmach { };
      xs = callPackage ./xs { };
    };
in
lib.fix' (lib.extends overrides packages)
