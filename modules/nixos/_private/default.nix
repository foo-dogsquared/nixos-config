{
  imports = [
    ./extra-arguments.nix
    ./shared-setups/server
    ./state
    ./suites/archiving.nix
    ./suites/browsers.nix
    ./suites/desktop.nix
    ./suites/dev.nix
    ./suites/filesystem.nix
    ./suites/gaming.nix
    ./suites/i18n.nix
    ./suites/server.nix
    ./suites/vpn.nix
    ./workflows
  ];
}
