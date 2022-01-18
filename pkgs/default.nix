{ pkgs ? import <nixpkgs> { }, overrides ? (self: super: { }) }:

with pkgs;

let
  packages = self:
    let callPackage = newScope self;
  in {
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
    junction = callPackage ./junction.nix { };
    libcs50 = callPackage ./libcs50.nix { };
    llama = callPackage ./llama.nix { };
    neo = callPackage ./neo.nix { };
    pop-launcher = callPackage ./pop-launcher.nix { };
    pop-launcher-plugin-duckduckgo-bangs =
      callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
    photon-rss = callPackage ./photon-rss.nix { };
    ratt = callPackage ./ratt.nix { };
    tic-80 = callPackage ./tic-80 { };
    sioyek = libsForQt5.callPackage ./sioyek.nix { };
    vpaint = libsForQt5.callPackage ./vpaint.nix { };
  };
in lib.fix (lib.extends overrides packages)
