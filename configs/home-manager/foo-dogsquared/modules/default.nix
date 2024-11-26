# Only optional modules should be imported here.
{
  imports = [
    ./dotfiles.nix

    ./programs/browsers.nix
    ./programs/dconf.nix
    ./programs/doom-emacs.nix
    ./programs/email.nix
    ./programs/git.nix
    ./programs/jujutsu.nix
    ./programs/keys.nix
    ./programs/nixvim
    ./programs/custom-homepage.nix
    ./programs/shell.nix
    ./programs/terminal-multiplexer.nix
    ./programs/vs-code.nix
    ./services/backup

    ./setups/business.nix
    ./setups/desktop.nix
    ./setups/development.nix
    ./setups/fonts.nix
    ./setups/music.nix
    ./setups/research.nix
  ];
}
