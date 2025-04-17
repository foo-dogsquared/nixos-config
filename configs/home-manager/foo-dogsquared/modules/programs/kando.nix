{ config, lib, pkgs, ... }@attrs:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.kando;
in
{
  options.users.foo-dogsquared.programs.kando = {
    enable = lib.mkEnableOption "Kando setup";
  };

  config = lib.mkIf cfg.enable {
    programs.kando = {
      enable = true;

      settings = {
        enableVersionCheck = false;
      };
    };
  };
}
