# All of the things concerning the custom packages from this flake are put over
# here.
{ inputs, ... }: {
  # In case somebody wants to use my stuff to be included in nixpkgs.
  flake.overlays = import ../../overlays // {
    default = final: prev: import ../../pkgs { pkgs = prev; };
    firefox-addons = final: prev: {
      inherit (final.nur.repos.rycee.firefox-addons) buildFirefoxXpiAddon;
      firefox-addons = final.callPackage ../../pkgs/firefox-addons { };
    };
  };

  perSystem = { system, pkgs, ... }: {
    # My custom packages, available in here as well. Though, I mainly support
    # "x86_64-linux". I just want to try out supporting other systems.
    packages =
      inputs.flake-utils.lib.flattenTree (import ../../pkgs { inherit pkgs; });
  };
}
