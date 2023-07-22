{ lib

  # Import the private modules
, isInternal ? false
}:

let
  modules = [
    ./files/mutable-files.nix
    ./programs/pop-launcher.nix
    ./services/archivebox.nix
    ./services/bleachbit.nix
    ./services/distant.nix
    ./services/gallery-dl.nix
    ./services/matcha.nix
    ./services/plover.nix
    ./services/yt-dlp.nix
  ];
  privateModules = [
    ./profiles/desktop.nix
    ./profiles/dev.nix
    ./profiles/editors.nix
    ./profiles/i18n.nix
    ./profiles/research.nix
  ];
in
modules
++ (lib.optionals isInternal privateModules)
