{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.fonts;
in {
  options.users.foo-dogsquared.setups.fonts.enable =
    lib.mkEnableOption "foo-dogsquared's font setup";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # My favorite set of fonts.
      source-code-pro
      source-sans-pro
      source-han-sans
      source-serif-pro
      source-han-serif
      source-han-mono

      # Some more monospace thingies.
      monaspace
      iosevka
      jetbrains-mono
    ];
  };
}
