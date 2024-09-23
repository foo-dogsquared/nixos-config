{ lib, ... }:

{
  options.state =
    let
      pathsSubmodule = { lib, ... }: {
        options = {
          paths = lib.mkOption {
            type = with lib.types; attrsOf (either path (listOf str));
            default = { };
            description = ''
              Set of paths to hold as a single source of truth for path-related
              settings throughout the whole home environment.
            '';
            example = lib.literalExpression ''
              {
                cacheDir = config.xdg.cacheHome;
                ignoreDirectories = [ "''${config.home.homeDirectory}/Nodes" ];
                ignorePaths = [ ".gitignore" "node_modules" "result" ];
              }
            '';
          };
        };
      };
  in lib.mkOption {
    type = lib.types.submodule pathsSubmodule;
  };
}
