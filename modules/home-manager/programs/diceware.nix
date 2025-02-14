{ config, lib, pkgs, ... }:

let
  cfg = config.programs.diceware;

  settingsFormat = pkgs.formats.ini { };
in
{
  options.programs.diceware = {
    enable = lib.mkEnableOption "configuring diceware, a passphrase generator";

    package = lib.mkPackageOption pkgs "diceware" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Settings in INI format to be generated at
        {file}`$XDG_CONFIG_HOME/diceware/diceware.ini`.
      '';
      example = lib.literalExpression ''
        {
          diceware = {
            num = 7;
            caps = false;
            specials = 2;
            delimiter = "MYDELIMITER";
            randomsource = "system";
            wordlist = "en_securedrop";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [ cfg.package ];
    }

    (lib.mkIf (cfg.settings != { }) {
      xdg.configFile."diceware/diceware.ini".source =
        settingsFormat.generate "diceware-user-settings" cfg.settings;
    })
  ]);
}
