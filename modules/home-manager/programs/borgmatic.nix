# A replacement module for the Borgmatic home-manager module. It is quite
# limited and also feels janky to use.
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.borgmatic;

  settingsFormat = pkgs.formats.yaml { };

  borgmaticBackupsModule = { name, lib, ... }: {
    options = {
      settings = lib.mkOption {
        type = settingsFormat.type;
        default = { };
        example = lib.literalExpression ''
          {
            source_directories = [
              "''${config.xdg.configHome}"
              "''${config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR}"
              "''${config.home.homeDirectory}/.thunderbird"
              "''${config.home.homeDirectory}/Zotero"
            ];

            repositories = [
              {
                path = "ssh://k8pDxu32@k8pDxu32.repo.borgbase.com/./repo";
                label = "borgbase";
              }

              {
                path = "/var/lib/backups/local.borg";
                label = "local";
              }
            ];

            keep_daily = 7;
            keep_weekly = 4;
            keep_monthly = 6;

            checks = [
              { name = "repository"; }
              { name = "archives"; frequency = "2 weeks"; }
            ];
          }
        '';
      };

      validateConfig =
        lib.mkEnableOption "validation step for the resulting configuration" // {
          default = true;
        };
    };
  };

  mkBorgmaticConfig = n: v:
    lib.nameValuePair "borgmatic.d/${n}.yaml" {
      source = let
        settingsFile = settingsFormat.generate "borgmatic-config-${n}" v.settings;

        borgmaticValidateCmd =
          if lib.versionOlder cfg.package.version "1.7.15" then
            "borgmatic config validate --config ${settingsFile}"
          else
            "validate-borgmatic-config --config ${settingsFile}";
      in
        if v.validateConfig then
          pkgs.runCommand "generate-borgmatic-config-with-validation" {
            buildInputs = [ cfg.package ];
            preferLocalBuild = true;
          } ''
            ${borgmaticValidateCmd} && install ${settingsFile} $out
          ''
        else
          settingsFile;
    };
  in
{
  disabledModules = [ "programs/borgmatic.nix" ];
  options.programs.borgmatic = {
    enable = lib.mkEnableOption "configuring Borg backups with Borgmatic";

    package = lib.mkPackageOption pkgs "borgmatic" { };

    backups = lib.mkOption {
      type = with lib.types; attrsOf (submodule borgmaticBackupsModule);
      default = { };
      example = lib.literalExpression ''
        {
          personal = {
            validateConfig = true;
            settings = {
              source_directories = [
                config.xdg.configHome
                config.xdg.userDirs.documents
                config.xdg.userDirs.photos
              ];

              repositories = lib.singleton {
                path = "ssh://alskdjalskdjalsdkj";
                label = "remote-hetzner-box";
              };

              keep_daily = 7;
              keep_weekly = 6;
              keep_monthly = 6;
            }
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile = lib.mapAttrs' mkBorgmaticConfig cfg.backups;
  };
}
