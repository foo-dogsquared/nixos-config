{ lib, ... }:

{
  imports = [
    ./boxxy.nix
    ./bubblewrap
  ];

  options.wrappers =
    let
      sandboxingType = { name, lib, config, options, ... }: {
        options.sandboxing = {
          variant = lib.mkOption {
            type = with lib.types; nullOr (enum []);
            description = ''
              The sandboxing framework to be applied to the wrapper. A value of
              `null` will essentially disable it.
            '';
            default = null;
            example = "bubblewrap";
          };

          wraparound = {
            executable = options.arg0;
            extraArgs = options.extraArgs;
          };
        };
      };
    in
    lib.mkOption {
      type = with lib.types; attrsOf (submodule sandboxingType);
    };
}
