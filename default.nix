# Author:  Henrik Lissner <henrik@lissner.net>
# Modified by: Gabriel Arazas <foo.dogsquared@gmail.com>
# URL:     https://github.com/foo-dogsquared/nixos-config
# License: MIT
#
# This is ground zero, where the absolute essentials go, to be present on all systems I use nixos on.
# Contains cluser-wide configurations shared between all of the systems (located in `hosts/`).
# TODO: Convert into a flake-based configuration so it'll make my life easier.

device: username:
{ pkgs, options, lib, config, ... }:

{
  networking.hostName = lib.mkDefault device;
  my.username = username;

  imports = [ ./modules "${./hosts}/${device}" ]
    ++ (if builtins.pathExists (/etc/nixos/cachix.nix) then
      [ /etc/nixos/cachix.nix ]
    else
      [ ])
    ++ (if builtins.pathExists (/etc/nixos/hardware-configuration.nix) then
      [ /etc/nixos/hardware-configuration.nix ]
    else
      [ ])
    ++ (if builtins.pathExists (/mnt/etc/nixos/hardware-configuration.nix) then
      [ /mnt/etc/nixos/hardware-configuration.nix ]
    else
      [ ]);

  # GARBAGE DAY!
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nix.autoOptimiseStore = true;
  nix.nixPath = options.nix.nixPath.default ++ [
    # So we can use absolute import paths
    "bin=/etc/dotfiles/config/bin"
    "config=/etc/dotfiles/config"
  ];

  # Add custom packages & unstable channel, so they can be accessed via pkgs.*
  nixpkgs.overlays = import ./packages;
  nixpkgs.config.allowUnfree = true; # forgive me Stallman senpai

  # These are the things I want installed on all my systems.
  environment.systemPackages = with pkgs; [
    # Just the bear necessities~
    coreutils
    exfat
    git
    hfsprogs
    killall
    ntfs3g
    sshfs
    udiskie
    unzip
    vim
    wget

    gnumake # for our own makefile
    cachix # less time buildin' mo time nixin'

    # nix-shell with the modified Nix path.
    (writeScriptBin "nix-shell" ''
      #!${stdenv.shell}
      NIX_PATH="nixpkgs-overlays=/etc/dotfiles/packages/default.nix:$NIX_PATH" ${nix}/bin/nix-shell "$@"
    '')
  ];

  # Default settings for primary user account.
  # `my` is defined in 'modules/default.nix'.
  my.user = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "video" "libvirtd" ];
    shell = pkgs.zsh;
  };
}
