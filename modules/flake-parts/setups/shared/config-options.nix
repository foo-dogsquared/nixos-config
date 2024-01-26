{ lib, systems, ... }: {
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
  };
}
