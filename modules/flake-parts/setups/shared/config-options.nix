{ lib, name, systems, ... }: {
  options = {
    systems = lib.mkOption {
      type = with lib.types; listOf str;
      default = systems;
      defaultText = "config.systems";
      example = [ "x86_64-linux" "aarch64-linux" ];
      description = ''
        A list of platforms that the NixOS configuration is supposed to be
        deployed on.
      '';
    };

    modules = lib.mkOption {
      type = with lib.types; listOf raw;
      default = [ ];
      description = ''
        A list of NixOS modules specific for that host.
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
  };
}
