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

    branch = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "nixvim";
      example = "nixvim-stable";
      description = ''
        The branch of NixVim to be used for the module.

        ::: {.tip}
        A rule of thumb for properly setting up NixVim with the wider-scoped
        environment is it should match the nixpkgs version of it. For example,
        a NixOS system of `nixos-23.11` nixpkgs branch should be paired with a NixVim
        branch of `nixos-23.11`.
        :::
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
