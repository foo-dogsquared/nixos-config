{ systems }:

{ lib, name, config, ... }: {
  options = {
    systems = lib.mkOption {
      type = with lib.types; listOf str;
      default = systems;
      defaultText = "config.systems";
      example = [ "x86_64-linux" "aarch64-linux" ];
      description = ''
        A list of platforms that the environment config is supposed to be
        deployed on.
      '';
    };

    modules = lib.mkOption {
      type = with lib.types; listOf raw;
      default = [ ];
      description = ''
        A list of modules specific for that environment.
      '';
    };

    configName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = name;
      example = "plover";
      description = ''
        The name of the configuration to be used. Useful for creating variants
        of the same declarative environment.
      '';
    };

    firstSetupArgs = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = {};
      example = lib.literalExpression ''
        {
          baseSpecificConfigModules = [
            ./whatwhatwut/base.nix
          ];
        }
      '';
      description = ''
        A set of module arguments intended to be set as part of the module
        argument namespace `firstSetupArgs` in the configuration.

        :::{.note}
        Functionally similar to {option}`specialArgs` but only different in
        intent and also for organization purposes.
        :::
      '';
    };
  };

  config.modules = lib.singleton {
    _module.args = { inherit (config) firstSetupArgs; };
  };
}
