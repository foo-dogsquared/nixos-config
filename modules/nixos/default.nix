{ lib

# Include the private modules.
, isInternal ? false
}:

let
  modules = [
    ./programs/cardboard-wm.nix
    ./programs/kiwmi.nix
    ./programs/pop-launcher.nix
    ./programs/wezterm.nix
    ./services/archivebox.nix
    ./services/gallery-dl.nix
    ./services/yt-dlp.nix
    ./workflows
  ];
  privateModules = [
    ./profiles/archiving.nix
    ./profiles/desktop.nix
    ./profiles/dev.nix
    ./profiles/filesystem.nix
    ./profiles/gaming.nix
    ./profiles/i18n.nix
    ./profiles/server.nix
    ./profiles/vpn.nix
    ./tasks/backup-archive
    ./tasks/multimedia-archive
  ];
in
  modules
  ++ (lib.optionals isInternal privateModules)
