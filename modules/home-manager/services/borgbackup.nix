# A home-manager port of NixOS' `services.borgbackup` module. I tried to make
# it as close to it as possible plus some other options such as adding pattern
# files (since it is my preference of indicating which files are included).
{ config, lib, pkgs, ... }:

let
  cfg = config.services.borgbackup;

  borgJobsModule = { name, lib, config, ... }: {
    options = {
      exportWrapperScript = lib.mkEnableOption "export wrapper script as part of the environment" // {
        default = true;
      };

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          Extra arguments to be passed to all Borg procedures in the resulting
          script.

          ::: {.caution}
          Be careful with this option as it can affect all commands. See the
          `extraArgs` equivalent of those specific operations first because
          adding values here.
          :::
        '';
        default = [ ];
        example = [
          "--remote-path=/path/to/borg/repo"
        ];
      };

      extraCreateArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          Additional arguments for `borg create`.
        '';
        default = [ ];
        example = [
          "--stats"
          "--checkpoint-interval" "600"
        ];
      };

      extraInitArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          Extra arguments to be passed to `borg init`, when applicable.
        '';
        default = [ ];
        example = [
          "--make-parent-dirs"
          "--append-only"
        ];
      };

      patternFiles = lib.mkOption {
        type = with lib.types; listOf path;
        description = ''
          List of paths containing patterns for the Borg job.
        '';
        default = [ ];
        example = lib.literalExpression ''
          [
            ./config/borg/patterns/home
            ./config/borg/patterns/server
            ./config/borg/patterns/games
          ]
        '';
      };

      doInit = lib.mkEnableOption "initialization of the BorgBackup repo";

      startAt = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = ''
          Indicates how much the backup procedure occurs.
        '';
        default = "daily";
        example = "04:30";
      };

      environment = lib.mkOption {
        type = with lib.types; attrsOf str;
        description = ''
          Extra environment variables to be set along to the backup service.
          You could indicate SSH-related settings here for example.
        '';
        default = { };
        example = lib.literalExpression ''
          {
            BORG_RSH = "ssh -i ''${config.home.homeDirectory}/.ssh/borg-key.pub";
          }
        '';
      };

      encryption.passCommand = lib.mkOption {
        type = with lib.types; nullOr str;
        description = ''
          Command used to retrieve the password of the repository.

          ::: {.note}
          Mutually exclusive with {option}`encryption.passphrase`.
          :::
        '';
        default = null;
        example = lib.literalExpression ''
          cat ''${config.home.homeDirectory}/borg-secret
        '';
      };

      encryption.passphrase = lib.mkOption {
        type = with lib.types; nullOr str;
        description = ''
          Passphrase used to lock the repository.

          ::: {.note}
          This will also store the password as plain-text file in the Nix store
          directory. If you don't want that, use
          {option}`encryption.passCommand` instead.

          Mutually exclusive with {option}`encryption.passCommand`.
          :::
        '';
        default = null;
      };
    };
  };

  mkPassEnv = v:
    # Prefer the pass command option since it is the safer option.
    if v.encryption.passCommand != null
    then { BORG_PASSCOMMAND = v.encryption.passCommand; }
    else if v.encryption.passphrase != null
    then { BORG_PASSPHRASE = v.encryption.passphrase; }
    else { };
  makeJobName = name: "borg-job-${name}";

  mkBorgWrapperScripts = n: v:
    let
      executableName = makeJobName n;
      setEnv = { BORG_REPO = v.repo; } // (mkPassEnv v) // v.environment;
      mkWrapperFlag = n: v:
        ''--set ${lib.escapeShellArg n} "${v}"'';
    in
    pkgs.runCommand "${n}-wrapper" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      makeWrapper "${lib.getExe' cfg.package "borg"} "$out/bin/${executableName}" \
        ${lib.concatStringsSep " \\\n" (lib.mapAttrsToList mkWrapperFlag setEnv)}
    '';

  mkBorgServiceUnit = n: v:
    lib.nameValuePair (makeJobName n) {
      Unit = {
        Description = "Periodic BorgBackup job '${n}'";
      };

      Service = {
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        Environment =
          lib.attrsToList (n: v: "${n}=${v}") (
            {
              inherit (v) extraArgs extraInitArgs extraCreateArgs;
            }
            // v.environment // (mkPassEnv v)
          )
          ++ [
            "BORG_REPO=${v.repo}"
          ];

        ExecStart =
          let
            borgScript = pkgs.writeShellApplication {
              name = "borg-job-${n}-script";
              runtimeInputs = [ cfg.package ];
              text = ''
                on_exit() {
                }
                trap on_exit EXIT
              '';
            };
          in
            lib.getExe borgScript;
      };
    };

  mkBorgTimerUnit = n: v:
    lib.nameValuePair (makeJobName n) {
      Unit.Description = "Periodic BorgBackup job '${n}'";

      Timer = {
        Persistent = true;
        RandomizedDelaySec = "1min";
        OnCalendar = v.startAt;
      };

      Install.WantedBy = [ "timers.target" ];
    };
in
{
  options.services.borgbackup = {
    enable = lib.mkEnableOption "periodic backups with BorgBackup";

    package = lib.mkPackageOption pkgs "borgbackup" { };

    jobs = lib.mkOption {
      type = with lib.types; attrsOf (submodule borgJobsModule);
      description = ''
        A set of Borg backup jobs to be done within the home environment.

        Each job can have a wrapper script `borg-job-{name}` as part of your
        home environment to make maintenance easier.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          personal = {
            doInit = true;
            encryption = {
              mode = "repokey";
              passCommand = "cat ''${config.xdg.configHome}/backup/secret";
            };
            patternFiles = [
              ./config/borg/patterns/data
              ./config/borg/patterns/games
            ];
            startAt = "05:30;
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        jobs' = lib.filterAttrs (n: v: v.exportWrapperScript) cfg.jobs;
      in
      lib.mapAttrsToList mkBorgWrapperScripts jobs';

    systemd.user.services =
      lib.mapAttrs' mkBorgServiceUnit cfg.jobs;

    systemd.user.timers =
      lib.mapAttrs' mkBorgTimerUnit cfg.jobs;
  };
}
