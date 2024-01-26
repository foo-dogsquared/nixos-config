{ lib, ... }: {
  options.nixvim = lib.mkOption {
    type = lib.types.submodule {
      options = {
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
    };
    default = { };
    description = ''
      An optional NixVim inclusion for the environment. Take note, this
      will override whatever Neovim configuration from your environment so
      be sure to only use this if you have none.
    '';
  };
}
