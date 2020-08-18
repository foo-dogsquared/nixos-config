# Author:  Henrik Lissner <henrik@lissner.net>
# Modified by: Gabriel Arazas <foo.dogsquared@gmail.com>
# URL:     https://github.com/foo-dogsquared/nixos-config
# License: MIT
#
# This is ground zero, where the absolute essentials go, to be present on all systems I use nixos on.
# Most of which are single user systems (the ones that aren't are configured from their hosts/*/default.nix).

device: username:
{ pkgs, options, lib, config, ... }:

{
  networking.hostName = lib.mkDefault device;
  my.username = username;

  imports = [
    ./modules
    "${./hosts}/${device}"
  ] ++ (if builtins.pathExists(/etc/nixos/cachix.nix) then [
    /etc/nixos/cachix.nix
  ] else []) ++ (if builtins.pathExists(/etc/nixos/hardware-configuration.nix) then [
    /etc/nixos/hardware-configuration.nix
  ] else []);

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
  nixpkgs.config.allowUnfree = true;  # forgive me Stallman senpai

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

    gnumake               # for our own makefile
    cachix                # less time buildin' mo time nixin'
  ];

  # Default settings for primary user account.
  # `my` is defined in 'modules/default.nix'.
  my.user = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "video" "networkmanager" "libvirtd" ];
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
