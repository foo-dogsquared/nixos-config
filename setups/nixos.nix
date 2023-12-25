# This is a custom data for this project where it lists the images found in
# this flake. This can range from NixOS configurations intended to be deployed
# for servers and desktops to installers.
#
# The data is then used for the image creation functions found in `flake.nix`.
# Each of the entry should correspond to one of the hosts in `./hosts/`
# directory.
{ lib, inputs }:

{
  ni = {
    systems = [ "x86_64-linux" ];
    format = null;
    modules = [
      inputs.nur.nixosModules.nur
      inputs.nix-index-database.nixosModules.nix-index

      {
        nixpkgs.overlays = [
          # Neovim nightly!
          inputs.neovim-nightly-overlay.overlays.default

          # Emacs unstable version!
          inputs.emacs-overlay.overlays.default

          # Helix master!
          inputs.helix-editor.overlays.default

          # Access to NUR.
          inputs.nur.overlay
        ];
      }
    ];
  };

  plover = {
    systems = [ "x86_64-linux" ];
    format = null;
    domain = "foodogsquared.one";
    deploy = {
      hostname = "plover.foodogsquared.one";
      auto-rollback = true;
      magic-rollback = true;
    };
  };

  void = {
    systems = [ "x86_64-linux" ];
    format = "vm";
  };

  bootstrap = {
    systems = [ "aarch64-linux" "x86_64-linux" ];
    format = "install-iso";
    nixpkgs-channel = "nixos-unstable-small";
  };

  graphical-installer = {
    systems = [ "aarch64-linux" "x86_64-linux" ];
    format = "install-iso";
  };

  winnowing = {
    systems = [ "x86_64-linux" ];
    format = null;
    modules = [
      inputs.nixos-wsl.nixosModules.default
    ];
  };
}
