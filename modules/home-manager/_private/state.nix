{ lib, ... }:

{
  options.state = lib.mkOption {
    type = lib.types.submodule {
      freeformType = with lib.types; attrsOf anything;
      options = {
        ignoreDirectories = lib.mkOption {
          type = with lib.types; listOf str;
          description = ''
            A state variable holding a list of directory names to be excluded
            in processes involving walking through directories (e.g., desktop
            indexing).
          '';
          default = [ ];
          example = [
            "node_modules"
            ".direnv"
          ];
        };
      };
    };
    description = ''
      A set of values to be held in the home-manager configuration. Pretty much
      used for anything that requires consistency or deduplicate the source of
      truth for module values.
    '';
    example = {
      sampleValue = 10;
      dev.ignoreDirectories = [
        ".git"
        "node_modules"
        ".direnv"
      ];
    };
  };
}
