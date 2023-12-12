# Only optional modules should be imported here.
{
  imports = [
    ./music-setup.nix
    ./dotfiles.nix

    ./programs/browsers.nix
    ./programs/email.nix
    ./programs/git.nix
    ./programs/keys.nix
    ./programs/shell.nix
    ./programs/terminal-multiplexer.nix

    ./services/desktop.nix
  ];
}
