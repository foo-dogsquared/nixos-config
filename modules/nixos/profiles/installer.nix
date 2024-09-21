# A dedicated profile for installers with some niceties in it. This is also
# used for persistent live installers so you'll have to exclude setting up shop
# and do that in the respective NixOS configuration instead.
{ pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/installation-device.nix"
  ];

  # Include some modern niceties.
  environment.systemPackages = with pkgs; [
    disko
    ripgrep
    git
    lazygit
    neovim
    zellij
  ];

  # Yeah, that's right, this is also a Guix System installer because SCREW YOU,
  # NIXOS USERS!
  services.guix.enable = lib.mkDefault true;
}
