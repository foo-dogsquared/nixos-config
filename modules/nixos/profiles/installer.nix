# A dedicated profile for installers with some niceties in it.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ripgrep
    git
    lazygit
    neovim
    zellij
  ];
}
