{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.nushell;
in
{
  options.users.foo-dogsquared.programs.nushell.enable =
    lib.mkEnableOption "Nushell setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.nushell = {
        enable = true;
        plugins = with pkgs.nushellPlugins; [
          dbus
          query
          skim
        ];
        extraConfig = ''
          $env.config.show_banner = false
        '';
      };
    }

    (lib.mkIf config.programs.fzf.enable {
      # TODO:
      # - Learn how to define functions in Nushell.
      # - Learn how to attach bindings in Nushell.
      # - Port interactive selections from fzf.
      home.file."${config.xdg.cacheHome}/nu
      programs.nushell.extraConfig = ''

      '';
    })
  ]);
}
