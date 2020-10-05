# (Neo)Vim is love, (Neo)Vim is life.
{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.editors.neovim = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.editors.neovim.enable { 
    my.packages = with pkgs; [
        editorconfig-core-c     # Editorconfig is a MUST, you feel me?!
      ];

    my.home = {
      programs.neovim = {
        enable = true;
        withPython3 = true;
        withRuby = true;
      };
    };
  };
}
