# This service is adapted from the NixOS module.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.mopidy;

  mopidyConf = pkgs.writeText "mopidy.conf" cfg.configuration;
  mopidyEnv = pkgs.buildEnv {
    name = "mopidy-with-extensions-${pkgs.mopidy.version}";
    # TODO: Improve this that doesn't use `lib.misc`.
    paths = lib.closePropagation cfg.extensionPackages;
    pathsToLink = [ "/${pkgs.mopidyPackages.python.sitePackages}" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${pkgs.mopidy}/bin/mopidy $out/bin/mopidy --prefix PYTHONPATH : $out/${pkgs.mopidyPackages.python.sitePackages}
    '';
  };
in {
  options.services.mopidy = {
    enable = lib.mkEnableOption "Mopidy music player daemon";

    dataDir = lib.mkOption {
      default = "${config.xdg.dataHome}/mopidy";
      type = with lib.types; either path str;
      description = "The directory where Mopidy stores its state.";
    };

    extensionPackages = lib.mkOption {
      default = [];
      type = with lib.types; listOf package;
      example = lib.literalExpression "with pkgs; [ mopidy-spotify mopidy-mpd mopidy-mpris ]";
      description = ''
        Mopidy extensions that should be loaded by the service.
      '';
    };

    # TODO: Revise the configuration to a proper Nix setting.
    configuration = lib.mkOption {
      default = "";
      type = lib.types.lines;
      description = "The configuration Mopidy uses in the service.";
    };

    extraConfigFiles = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = ''
        Extra config files to be read to the service.
        Note that later files overrides earlier configuration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.mopidy" pkgs lib.platforms.linux)
    ];

    systemd.user.services.mopidy = {
      Unit = {
        Description = "mopidy music player daemon";
        After = [ "network.target" "sound.target" ];
        Documentation = [ "https://mopidy.com/" ];
      };

      Service = {
        ExecStart = "${mopidyEnv}/bin/mopidy --config ${lib.concatStringsSep ":" ([mopidyConf] ++ cfg.extraConfigFiles)}";
      };

      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.mopidy-scan = {
      Unit = {
        After = [ "network.target" "sound.target" ];
        Description = "mopidy local files scanner";
        Documentation = [ "https://mopidy.com/" ];
      };

      Service = {
        ExecStart = "${mopidyEnv}/bin/mopidy --config ${lib.concatStringsSep ":" ([mopidyConf] ++ cfg.extraConfigFiles)} local scan";
        Type = "oneshot";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
