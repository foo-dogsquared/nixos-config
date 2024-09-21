{ lib, ... }:

{
  options.state =
    let
      packagesSubmodule = { lib, ... }: {
        options = {
          packages = lib.mkOption {
            type = with lib.types; attrsOf package;
            default = { };
            description = ''
              Source of truth containing a set of packages. Useful for options
              where there are no specific options for a package or as a unified
              source of truth for different module options requiring a package.
            '';
            example = lib.literalExpression ''
              {
                diff = pkgs.vimdiff;
                pager = pkgs.bat;
                editor = pkgs.neovim;
              }
            '';
          };
        };
      };
  in lib.mkOption {
    type = lib.types.submodule packagesSubmodule;
  };
}
