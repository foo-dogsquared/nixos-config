{
  imports = [
    ./programs/blender.nix
    ./programs/distrobox.nix
    ./programs/gnome-session
    ./programs/pop-launcher.nix
    ./programs/sessiond
    ./programs/wezterm.nix
    ./services/archivebox.nix
    ./services/gallery-dl.nix
    ./services/uxplay.nix
    ./services/wezterm-mux-server.nix
    ./services/vouch-proxy.nix
    ./services/yt-dlp.nix
    ./xdg/mime-desktop-specific.nix
  ];
}
