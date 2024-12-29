{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.hledger;
in
{
  options.users.foo-dogsquared.programs.hledger.enable =
    lib.mkEnableOption "hledger setup";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hledger
      hledger-ui
      hledger-web
      hledger-utils
    ];
  };
}
