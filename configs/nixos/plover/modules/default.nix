# Take note only optional modules should be imported here.
{
  imports = [
    # Of course, what is a server without a backup? A professionally-handled
    # production system. However, we're not professionals so we do have
    # backups.
    ./services/backup.nix

    # The database of choice which is used by most self-managed services on
    # this server.
    ./services/database.nix

    # The primary DNS server that is completely hidden.
    ./services/dns-server

    # The single-sign on setup.
    ./services/idm.nix

    # The reverse proxy of choice.
    ./services/reverse-proxy.nix

    # The firewall of choice.
    ./services/firewall.nix

    # The rest of the self-hosted applications.
    ./services/atuin.nix
    ./services/fail2ban.nix
    ./services/gitea.nix
    ./services/grafana.nix
    ./services/monitoring.nix
    ./services/vouch-proxy.nix
    ./services/vaultwarden.nix
    ./services/wezterm-mux-server.nix
  ];
}
