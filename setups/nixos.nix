/*
  This is a custom data for this project where it lists the images found in
  this flake. This can range from NixOS configurations intended to be deployed
  for servers and desktops to installers.

  The data is then used for the image creation functions found in `flake.nix`.
  Each of the entry should correspond to one of the hosts in `./configs/nixos/`
  directory.

  Schema:

  * systems
      A list of systems that is expected to be deployed. This is required and
      will have a default list of "x86_64-linux" when no system is given.
  * format
      The image format to be generated from nixos-generators. You can give it
      as `null` when not intended to be listed as part of the images which is
      often the case for desktop NixOS systems.
  * modules
      A list of extra NixOS modules to be passed. You'll want to see the
      baseline host configuration defined in `flake.nix`.
  * deploy
      An attribute set of arguments similar to the `deploy` CLI. When this
      attribute is present, it will be assumed as part of NixOS configurations
      even with `format = null` which is often the case for bare metal NixOS
      servers that also has a suitable image format for deployment.
  * hostname
      The hostname of the host. By default, it assumes the hostname being given
      from the attribute name.
  * domain
      The domain set for the host. Normally given to server systems.
*/
{ lib, inputs }:

{
  # The main desktop.
  ni = {
    systems = [ "x86_64-linux" ];
    format = null;
    modules = [
      inputs.nur.nixosModules.nur

      ({ config, ... }: {
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
      })
    ];
  };

  # A remote server.
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

  # TODO: Remove extra newlines that are here for whatever reason.
  #{{{
  void = {
    systems = [ "x86_64-linux" ];
    format = "vm";
  };
  #}}}

  # The barely customized non-graphical installer.
  bootstrap = {
    systems = [ "aarch64-linux" "x86_64-linux" ];
    format = "install-iso";
    nixpkgs-channel = "nixos-unstable-small";
  };

  # The barely customized graphical installer.
  graphical-installer = {
    systems = [ "aarch64-linux" "x86_64-linux" ];
    format = "install-iso";
  };

  # The WSL system (that is yet to be used).
  winnowing = {
    systems = [ "x86_64-linux" ];
    format = null;
    modules = [
      # Well, well, well...
      inputs.nixos-wsl.nixosModules.default

      ({ config, ... }: {
        nixpkgs.overlays = [
          # Make the most of it.
          inputs.neovim-nightly-overlay.overlays.default
        ];
      })
    ];
  };
}
# vim:foldmethod=marker
