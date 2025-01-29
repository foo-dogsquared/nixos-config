{ config, lib, helpers, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.devenvs;
in {
  options.nixvimConfigs.fiesta.setups.qol.enable =
    lib.mkEnableOption "quality-of-life improvements";

  config = lib.mkIf cfg.enable {
    plugins.mini = {
      enable = true;
      modules = {
        ai = {
          n_lines = 50;
          search_method = "cover_or_next";
        };
        surround = { };
        align = { };
        bracketed = { };
      };
    };
  };
}
