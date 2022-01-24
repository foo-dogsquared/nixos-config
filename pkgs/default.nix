{ pkgs ? import <nixpkgs> { }, overrides ? (self: super: { }) }:

with pkgs;

let
  packages = self:
    let callPackage = newScope self;
    in {
      poppler_21_08 = poppler.overrideAttrs (super: rec {
        version = "21.08.0";
        src = fetchurl {
          url = "https://poppler.freedesktop.org/poppler-${version}.tar.xz";
          sha256 = "sha256-6c9dxZZLzkuwJk0cT4EicGyRBYi0Ic/DCryX1rI+YC0=";
        };
      });
      gstreamer_1_18_5 = gst_all_1.gstreamer.overrideAttrs (super: rec {
        version = "1.18.5";
        src = fetchurl {
          url =
            "https://gstreamer.freedesktop.org/src/${super.pname}/${super.pname}-${version}.tar.xz";
          sha256 = "sha256-VYYiMqY0Wbv1ar694whcqa7CEbR46JHazqTW34yv6Ao=";
        };
      });
      gstreamer_plugins_base_1_18_5 = gst_all_1.gst-plugins-base.overrideAttrs
        (super: rec {
          version = "1.18.5";
          src = fetchurl {
            url =
              "https://gstreamer.freedesktop.org/src/${super.pname}/${super.pname}-${version}.tar.xz";
            sha256 = "sha256-lgt69FhXANsP3VuENVThHiVk/tngYfWR+uiKe+ZEb6M=";
          };
        });
      doggo = callPackage ./doggo.nix { };
      gnome-shell-extension-burn-my-windows =
        callPackage ./gnome-shell-extension-burn-my-windows.nix { };
      gnome-shell-extension-desktop-cube =
        callPackage ./gnome-shell-extension-desktop-cube.nix { };
      gnome-shell-extension-fly-pie =
        callPackage ./gnome-shell-extension-fly-pie.nix { };
      gnome-shell-extension-pop-shell =
        callPackage ./gnome-shell-extension-pop-shell.nix { };
      guile-config = callPackage ./guile-config.nix { };
      guile-hall = callPackage ./guile-hall.nix { };
      guix-binary = callPackage ./guix-binary.nix { };
      junction = callPackage ./junction.nix { };
      libcs50 = callPackage ./libcs50.nix { };
      mopidy-beets = callPackage ./mopidy-beets.nix { };
      mopidy-funkwhale = callPackage ./mopidy-funkwhale.nix { };
      mopidy-internetarchive = callPackage ./mopidy-internetarchive.nix { };
      pop-launcher = callPackage ./pop-launcher.nix { };
      pop-launcher-plugin-duckduckgo-bangs =
        callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
      rnote = callPackage ./rnote.nix { };
      tic-80 = callPackage ./tic-80 { };
      sioyek = libsForQt5.callPackage ./sioyek.nix { };
      vpaint = libsForQt5.callPackage ./vpaint.nix { };
    };
in lib.fix (lib.extends overrides packages)
