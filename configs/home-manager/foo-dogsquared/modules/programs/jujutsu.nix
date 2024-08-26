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

        ui.diff-editor = "diffedit3";

        "merge-tools.diffoscope" = {
          merge-args = [ "$left" "$right" ];
          program = lib.getExe' pkgs.diffoscope "diffoscope";
        };

        "merge-tools.diffedit3" = {
          merge-args = [ "$left" "$right" "$output" ];
          program = lib.getExe' config.services.diffedit3.package "diffedit3";
        };
      };
    };
  };
}
