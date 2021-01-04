# (Neo)Vim is love, (Neo)Vim is life.
{ config, options, lib, pkgs, ... }:

with lib;

let cfg = config.modules.editors.neovim;
in {
  options.modules.editors.neovim = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs;
      [
        neovim
        editorconfig-core-c # Editorconfig is a MUST, you feel me?!
      ];
  };
}
