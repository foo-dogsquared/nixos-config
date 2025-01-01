# Only optional modules should be imported here.
{
  imports = [
    ./hardware/qol.nix
    ./networking/setup.nix
    ./networking/wireguard.nix
    ./services/backup
    ./services/mail-archive.nix
    ./services/reverse-proxy.nix
    ./services/monitoring.nix
    ./services/download-media
    ./services/rss-reader
    ./services/dns-server
    ./services/penpot
    ./setups/desktop.nix
    ./setups/development.nix
    ./setups/gaming.nix
    ./setups/music.nix
  ];
}
