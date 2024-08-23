{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.jujutsu;
in
{
  options.users.foo-dogsquared.programs.jujutsu.enable =
    lib.mkEnableOption "foo-dogsquared's Jujutsu configuration";

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        user.name = config.accounts.email.accounts.personal.realName;
        user.email = config.accounts.email.accounts.personal.address;

        "merge-tools.diffoscope" = {
          merge-args = [ "$left" "$right" ];
          program = lib.getExe' pkgs.diffoscope "diffoscope";
        };
      };
    };
  };
}
