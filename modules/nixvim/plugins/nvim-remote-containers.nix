{ config, lib, pkgs, helpers, ... }:

let cfg = config.plugins.nvim-remote-containers;
in {
  options.plugins.nvim-remote-containers = {
    enable = lib.mkEnableOption "nvim-remote-containers";

    package =
      lib.mkPackageOption pkgs [ "vimPlugins" "nvim-remote-containers" ] { };
  };

  config = lib.mkIf cfg.enable {
    plugins.treesitter.enable = lib.mkDefault true;
    extraPlugins = [ cfg.package ];
  };
}
