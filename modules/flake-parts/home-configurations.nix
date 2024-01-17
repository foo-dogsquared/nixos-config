{ lib, flake-parts-lib, ... }:

{
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      homeConfigurations = lib.mkOption {
        type = with lib.types; lazyAttrsOf raw;
        default = {};
        description = ''
          Instantiated home-manager configurations.

          `homeConfigurations is for specific home environments. If you want to
          add reusable components, add them to {option}`homeModules`.
        '';
        example = lib.literalExpression ''
          {
            foodogsquared = inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = inputs.nixpkgs.legacyPackages.''${system};
              modules = [
                inputs.sops-nix.homeManagerModules.sops
                ./home.nix
              ];
            };
          }
        '';
      };
    };
  };
}
