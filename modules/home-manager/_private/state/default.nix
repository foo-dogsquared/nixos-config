{ lib, ... }:

{
  imports = [ ./ports.nix ./paths.nix ./packages.nix ];

  options.state = lib.mkOption {
    type = lib.types.submodule {
      freeformType = with lib.types; attrsOf anything;
      default = { };
    };
    description = ''
      A set of values to be held in the home-manager configuration. Pretty much
      used for anything that requires consistency or deduplicate the source of
      truth for module values.
    '';
    example = {
      sampleValue = 10;
      paths.ignoreDirectories = [ ".git" "node_modules" ".direnv" ];
    };
  };
}
