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
    ./programs/hledger.nix
    ./programs/kando.nix
    ./programs/keys.nix
    ./programs/nixvim
    ./programs/nushell.nix
    ./programs/custom-homepage.nix
    ./programs/shell.nix
    ./programs/password-utilities.nix
    ./programs/terminal-multiplexer.nix
    ./programs/terminal-emulator.nix
    ./programs/vs-code.nix
    ./services/archivebox
    ./services/backup

    ./setups/business.nix
    ./setups/desktop.nix
    ./setups/development.nix
    ./setups/fonts.nix
    ./setups/music
    ./setups/research.nix
    ./setups/workflows-specific.nix
  ];
}
