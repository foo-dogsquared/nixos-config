{ config, options, lib, pkgs, ... }:

let
  cfg = config.services.recoll;

  # The key-value generator for Recoll config format. For future references,
  # see the example configuration from the package (i.e.,
  # `$out/share/recoll/examples/recoll.conf`).
  mkRecollConfKeyValue = lib.generators.mkKeyValueDefault {
    mkValueString = v:
      if v == true then
        "1"
      else if v == false then
        "0"
      else
        lib.generators.mkValueStringDefault { } v;
  } " = ";

  # A modified version of 'lib.generators.toINI' that also accepts top-level
  # attributes as non-attrsets.
  toRecollConf = with lib;
    { listsAsDuplicateKeys ? false }:
    attr:
    let
      toKeyValue = generators.toKeyValue {
        inherit listsAsDuplicateKeys;
        mkKeyValue = mkRecollConfKeyValue;
      };
      mkSectionName = name: strings.escape [ "[" "]" ] name;
      config = mapAttrsToList (k: v:
        if isAttrs v then
          ''
            [${mkSectionName k}]
          '' + toKeyValue v
        else
          toKeyValue { "${k}" = v; }) attr;
    in concatStringsSep "\n" config;

  # A specific type for Recoll config format. Taken from `pkgs.formats`
  # implementation from nixpkgs. See the 'Nix-representable formats' from the
  # NixOS manual for more information.
  recollConfFormat = { }: {
    type = with lib.types;
      let
        valueType =
          nullOr (oneOf [ bool float int path str (attrsOf valueType) ]) // {
            description = "Recoll config value";
          };
      in attrsOf valueType;

    generate = name: value: pkgs.writeText name (toRecollConf { } value);
  };

  # The actual object we're going to use for this module. This is for the sake
  # of consistency (and dogfooding the settings format implementation).
  settingsFormat = recollConfFormat { };
in {
  options.services.recoll = {
    enable = lib.mkEnableOption "Recoll file index service";

    startAt = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      example = "00/2:00";
      description = ''
        When or how often the periodic update should run. Must be the format
        described from systemd.time(7).
      '';
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        The configuration to be written at
        <filename>''${config.services.recoll.configDir}/recoll.conf</filename>.

        See recoll.conf(5) manual page for more details.
      '';
      example = lib.literalExpression ''
        {
          topdirs = "~/Downloads ~/Documents ~/projects";

          "~/Downloads" = {
            "skippedNames+" = "*.iso";
          };

          "~/projects" = {
            "skippedNames+" = "node_modules target result";
          };
        }
      '';
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.recoll";
      example = ''''${xdg.configHome."recoll"}'';
      description = "The directory to contain Recoll configuration files.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.recoll" pkgs
        lib.platforms.linux)
    ];

    home.packages = [ pkgs.recoll ];

    home.sessionVariables = { RECOLL_CONFDIR = cfg.configDir; };

    home.file."${cfg.configDir}/recoll.conf".source =
      settingsFormat.generate "recoll-${config.home.username}" cfg.settings;

    systemd.user.services.recollindex = {
      Unit = {
        Description = "Recoll index update";
        Documentation = [
          "man:recoll"
          "man:recollindex"
          "https://www.lesbonscomptes.com/recoll/usermanual/"
        ];
      };

      Service = {
        ExecStart = "${pkgs.recoll}/bin/recollindex";
        Environment = [ "RECOLL_CONFDIR=${cfg.configDir}" ];
      };
    };

    systemd.user.timers.recollindex = {
      Unit = {
        Description = "Recoll index update";
        PartOf = [ "default.target" ];
      };

      Timer = {
        Persistent = true;
        OnCalendar = cfg.startAt;
      };

      Install.WantedBy = [ "timers.target" ];
    };
  };
}
