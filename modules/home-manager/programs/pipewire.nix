{ config, lib, pkgs, ... }:

let
  cfg = config.programs.pipewire;
  settingsFormat = pkgs.formats.json { };

  generatePipewireConfig = name: settings:
    lib.nameValuePair "pipewire/pipewire.conf.d/${name}.conf" {
      source = settingsFormat.generate "hm-pipewire-override-settings-${name}" settings;
    };
in
{
  options.programs.pipewire = {
    enable = lib.mkEnableOption "Pipewire configuration";
    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        The configuration file to be generated at
        {file}`$XDG_CONFIG_HOME/pipewire/pipewire.conf`. For more details,
        please see {manpage}`pipewire.conf(5)`.
      '';
    };
    overrides = lib.mkOption {
      type = with lib.types; attrsOf settingsFormat.type;
      default = { };
      description = ''
        A set of user overrides to be generated in
        {file}`$XDG_CONFIG_HOME/pipewire/pipewire.conf.d/$OVERRIDE.conf`.

        ::: {.note}
        Both the `settings` and `overrides` can be used at the same time but
        they will be merged in some order. You can see more details about it in
        {manpage}`pipewire.conf(5)`.
        :::
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile =
      lib.optionalAttrs (cfg.settings != { })
        {
          "pipewire/pipewire.conf".source = settingsFormat.generate "hm-pipewire-settings" cfg.settings;
        }
      // lib.mapAttrs' generatePipewireConfig cfg.overrides;
  };
}
