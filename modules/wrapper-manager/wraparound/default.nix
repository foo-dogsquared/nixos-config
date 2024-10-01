{ lib, ... }:

{
  imports = [
    ./boxxy.nix
    ./bubblewrap
  ];

  options.wrappers =
    let
      wraparoundType = { name, lib, config, options, ... }: {
        options.wraparound = {
          variant = lib.mkOption {
            type = with lib.types; nullOr (enum []);
            description = ''
              The wraparound variant to be applied to the wrapper. A value of
              `null` will essentially disable it.
            '';
            default = null;
            example = "bubblewrap";
          };

          subwrapper = {
            arg0 = options.arg0;
            extraArgs = options.appendArgs;
          };
        };
      };
    in
    lib.mkOption {
      type = with lib.types; attrsOf (submodule wraparoundType);
    };
}
