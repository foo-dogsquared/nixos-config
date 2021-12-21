{ pkgs ? import <nixpkgs> { } }:

with pkgs; {
  doggo = callPackage ./doggo.nix { };
  gnome-shell-extension-pop-shell =
    callPackage ./gnome-shell-extension-pop-shell.nix { };
  gnome-shell-extension-burn-my-windows =
    callPackage ./gnome-shell-extension-burn-my-windows.nix { };
  gnome-shell-extension-fly-pie =
    callPackage ./gnome-shell-extension-fly-pie.nix { };
  libcs50 = callPackage ./libcs50.nix { };
  llama = callPackage ./llama.nix { };
  neo = callPackage ./neo.nix { };
  pop-launcher = callPackage ./pop-launcher.nix { };
  pop-launcher-plugin-duckduckgo-bangs =
    callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
  tic-80 = callPackage ./tic-80 { };
  sioyek = libsForQt5.callPackage ./sioyek.nix { };
}
