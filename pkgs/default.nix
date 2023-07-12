{ pkgs ? import <nixpkgs> { }, overrides ? (self: super: { }) }:

with pkgs;

let
  packages = self:
    let callPackage = newScope self;
    in rec {
      auto-editor = callPackage ./auto-editor.nix { };
      awesome-cli = callPackage ./awesome-cli { };
      decker = callPackage ./decker { };
      cosmic-launcher = callPackage ./cosmic-launcher { };
      cursedgl = callPackage ./cursedgl { };
      clidle = callPackage ./clidle.nix { };
      domterm = callPackage ./domterm { };
      freerct = callPackage ./freerct.nix { };
      firefox-addons = callPackage ./firefox-addons { };
      distant = callPackage ./distant.nix { };
      gol-c = callPackage ./gol-c.nix { };
      gnome-search-provider-recoll =
        callPackage ./gnome-search-provider-recoll.nix { };
      gnome-shell-extension-burn-my-windows = callPackage ./gnome-shell-extension-burn-my-windows { };
      gnome-shell-extension-fly-pie =
        callPackage ./gnome-shell-extension-fly-pie.nix { };
      gnome-shell-extension-pop-shell =
        callPackage ./gnome-shell-extension-pop-shell.nix { };
      gnome-shell-extension-paperwm-latest = gnomeExtensions.paperwm.overrideAttrs (prev: {
        rev = "unstable-2022-11-13";
        src = fetchFromGitHub {
          owner = "paperwm";
          repo = "PaperWM";
          rev = "db9d63302b593c7a663791b577a306d3f432e18a";
          sha256 = "sha256-yPyomT+OmOe4mFJMNCq2FBgNHzuAvZ70itFA0s5BwV8=";
        };
      });
      guile-config = callPackage ./guile-config.nix { };
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
      segno = callPackage ./segno.nix { };
      smile = callPackage ./smile { };
      vpaint = libsForQt5.callPackage ./vpaint.nix { };
      vgc = qt6Packages.callPackage ./vgc { };
      watc = callPackage ./watc { };
      wayback = callPackage ./wayback.nix { };
      wzmach = callPackage ./wzmach { };
      xs = callPackage ./xs { };
    };
in
lib.fix' (lib.extends overrides packages)
