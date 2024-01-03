{ lib

  # Include the private modules.
, isInternal ? false
}:

let
  modules = [
    ./programs/blender.nix
    ./programs/cardboard-wm.nix
    ./programs/distrobox.nix
    ./programs/gnome-session
    ./programs/kiwmi.nix
    ./programs/pop-launcher.nix
    ./programs/wezterm.nix
    ./services/archivebox.nix
    ./services/gallery-dl.nix
    ./services/wezterm-mux-server.nix
    ./services/vouch-proxy.nix
    ./services/yt-dlp.nix
    ./workflows
  ];
  privateModules = [
    ./profiles/archiving.nix
    ./profiles/browsers.nix
    ./profiles/desktop.nix
    ./profiles/dev.nix
    ./profiles/filesystem.nix
    ./profiles/gaming.nix
    ./profiles/i18n.nix
    ./profiles/server.nix
    ./profiles/vpn.nix
  ];
in
modules
++ (lib.optionals isInternal privateModules)
