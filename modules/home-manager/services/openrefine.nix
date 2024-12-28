{ config, lib, pkgs, ... }:

let
  cfg = config.services.openrefine;

  settingsFormat = pkgs.formats.ini { };
in
{
  options.services.openrefine = {
    enable = lib.mkEnableOption "OpenRefine server";

    package = lib.mkPackageOption pkgs "openrefine" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      example = lib.literalExpression ''
      '';
    };

    extraFlags = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      example = lib.literalExpression ''
        [
          "--port" "29345"
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.openrefine = {
      Unit = {
        Description = "OpenRefine server";
        Documentation = [ "https://openrefine.org/docs" ];

        After = [
          "network-online.target"
          "default.target"
        ];
      };

      Service = {
        ExecStart = ''
          ${lib.getExe' cfg.package "refine"} ${lib.concatStringsSep " " cfg.extraFlags}
        '';
        Restart = "on-failure";
      };
    };
  };
}
