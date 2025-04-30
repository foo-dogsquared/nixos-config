{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.business;
in {
  options.users.foo-dogsquared.setups.business.enable =
    lib.mkEnableOption "business setup";

  config = lib.mkIf cfg.enable {
    users.foo-dogsquared.programs = {
      email = {
        enable = true;
        thunderbird.enable = true;
      };
    };

    home.packages = with pkgs; [
      libreoffice zoom-us
    ];

    # TODO: Create desktop entries for several web apps for generic thing?
  };
}
