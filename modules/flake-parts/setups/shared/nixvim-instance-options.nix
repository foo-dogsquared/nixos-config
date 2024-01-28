{ lib, ... }: {
  options.nixvim = {
    instance = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "fiesta";
      description = ''
        The name of the NixVim configuration from
        {option}`setups.nixvim.configs.<name>` to be included as part
        of the NixOS system.
      '';
    };

    additionalModules = lib.mkOption {
      type = with lib.types; listOf raw;
      default = [ ];
      description = ''
        A list of additional NixVim modules to be included.
      '';
    };
  };
}
