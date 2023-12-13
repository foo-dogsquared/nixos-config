# Only optional modules should be imported here.
{
  imports = [
    ./dotfiles.nix

    ./programs/browsers.nix
    ./programs/email.nix
    ./programs/git.nix
    ./programs/keys.nix
    ./programs/research.nix
    ./programs/shell.nix
    ./programs/terminal-multiplexer.nix

    ./setups/desktop.nix
    ./setups/music.nix
  ];
}
