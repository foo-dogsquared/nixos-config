# This is project data for deploying home-manager users with this flake. Each
# of the users defined here should correspond to one of the home-manager users
# at `./users/home-manager/`.
{ lib, inputs }:

{
  foo-dogsquared = {
    systems = [ "aarch64-linux" "x86_64-linux" ];
    modules = [
      inputs.nur.hmModules.nur

      ({ config, ... }: {
        nixpkgs.overlays = [
          # Neovim nightly!
          inputs.neovim-nightly-overlay.overlays.default

          # Emacs unstable version!
          inputs.emacs-overlay.overlays.default

          # Get all of the NUR.
          inputs.nur.overlay
        ];
      })
    ];
  };

  plover.systems = [ "x86_64-linux" ];
}
