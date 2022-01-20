# This service is adapted from the NixOS module.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.mopidy;

  customToINI = with lib; generators.toINI {
    mkKeyValue = generators.mkKeyValueDefault {
      mkValueString = v:
        if isList v then "\n  " + concatStringsSep "\n  " v
        else generators.mkValueStringDefault {} v;
    } " = ";
  };

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

    extensionPackages = lib.mkOption {
      default = [ ];
      defaultText = lib.literalExpression "[ ]";
      type = with lib.types; listOf package;
      example = lib.literalExpression
        "with pkgs; [ mopidy-spotify mopidy-mpd mopidy-mpris ]";
      description = ''
        Mopidy extensions that should be loaded by the service.
      '';
    };

    configuration = lib.mkOption {
      default = {};
      type = lib.types.attrs;
      description = "The configuration Mopidy uses in the service.";
      example = lib.literalExpression ''
        {
          file = {
            media_dirs = [
              "$XDG_MUSIC_DIR|Music"
              "~/library|Library"
            ];
            follow_symlinks = true;
            excluded_file_extensions = [
              ".html"
              ".zip"
              ".jpg"
              ".jpeg"
              ".png"
            ];
          };

          # Please don't put your mopidy-spotify configuration in the public. :)
          # Think of your Spotify Premium subscription!
          spotify = {
            client_id = "CLIENT_ID";
            client_secret = "CLIENT_SECRET";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.mopidy" pkgs
        lib.platforms.linux)
    ];

    xdg.configFile."mopidy/mopidy.conf".text = customToINI cfg.configuration;

    systemd.user.services.mopidy = {
      Unit = {
        Description = "mopidy music player daemon";
        After = [ "network.target" "sound.target" ];
        Documentation = [ "https://mopidy.com/" ];
      };

      Service = {
        ExecStart = "${mopidyEnv}/bin/mopidy";
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
        ExecStart = "${mopidyEnv}/bin/mopidy local scan";
        Type = "oneshot";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
