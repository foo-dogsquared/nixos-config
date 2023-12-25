/*
  This is project data for deploying home-manager users with this flake. Each
  of the users defined here should correspond to one of the home-manager users
  at `./users/home-manager/`.

  Schema:

  * systems
      A list of host platforms to be deployed. When given no systems, it will
      be deployed with `x86_64-linux`.
  * modules
      A list of home-manager modules to be included. Take note there is a
      baseline configuration defined at `flake.nix`. You should add modules
      very minimally here such as additional overlays, modules, and so forth.
  * home-manager-channel
      The home-manager branch to be used. By default, it uses the
      `home-manager` flake input which follows the `home-manager-unstable`
      input.
  * nixpkgs-channel
      The nixpkgs branch to be included. By default, it uses the `nixpkgs`
      flake input which follows the `nixos-unstable` input.
  * deploy
      An attribute set of options for deploy-rs nodes.
  * username
      The username of the home-manager user. By default, it will use the
      attribute name.
  * home-directory
      The home directory of the home-manager user. By default, it is
      set to "/home/${username}".
*/

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

          # Helix master!
          inputs.helix-editor.overlays.default

          # Get all of the NUR.
          inputs.nur.overlay
        ];
      })
    ];
  };

  plover.systems = [ "x86_64-linux" ];
}
