{ config, lib, pkgs, ... }:

let
  cfg = config.programs.jujutsu;

  settingsFormat = pkgs.formats.toml { };
in {
  options.programs.jujutsu = {
    enable = lib.mkEnableOption "Jujutsu, a Git-compatible DVCS";

    package = lib.mkPackageOption pkgs "jujutsu" { };

    executableName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = ''
        The name of the executable Jujutsu wrapper.
      '';
      default = "jj";
      example = "jj-custom";
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      description = ''
        Nix-configured settings to be used by the wrapper. This option is
        ignored if {option}`programs.jujutsu.configFile` is not `null`.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          user.name = "Your Name";
          user.email = "youremail@example.com";
          ui.color = "never";
          ui.diff.tool = "vimdiff";
          merge-tools.vimdiff.diff-invocation-mode = "file-by-file";
        }
      '';
    };

    configFile = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        The configuration file to be used for the Jujutsu wrapper. If the value
        is `null`, it will generate one from
        {option}`programs.jujutsu.settings`.
      '';
      default = null;
      example = lib.literalExpression "./config/jujutsu.toml";
    };
  };

  config = lib.mkIf cfg.enable {
    basePackages = [ cfg.package ];
    wrappers.jujutsu = lib.mkMerge [
      {
        inherit (cfg) executableName;
        arg0 = lib.getExe' cfg.package "jj";
      }

      (lib.mkIf (cfg.configFile != null) {
        env.JJ_CONFIG.value = cfg.configFile;
      })

      (lib.mkIf (cfg.settings != { } && cfg.configFile == null) {
        env.JJ_CONFIG.value =
          settingsFormat.generate "wrapper-manager-jujutsu-config" cfg.settings;
      })
    ];
  };
}
