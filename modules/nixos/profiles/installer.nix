# A dedicated profile for installers with some niceties in it. This is also
# used for persistent live installers so you'll have to exclude setting up shop
# and do that in the respective NixOS configuration instead.
{ pkgs, modulesPath, ... }:

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
}
