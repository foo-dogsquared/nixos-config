{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.password-utilities;
in
{
  options.users.foo-dogsquared.programs.password-utilities = {
    enable = lib.mkEnableOption "password utilities setup";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [
        gopass # An improved version of the password manager for hipsters.
      ];

    programs.diceware = {
      enable = true;
      settings.diceware = {
        num = 7;
        specials = 4;
      };
    };
  };
}
