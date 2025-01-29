{ config, lib, options, pkgs, ... }:

let
  cfg = config.virtualisation.oci-containers;
  inherit (lib) escapeShellArg;

  volumeModule = { config, lib, ... }: {
    options = {
      labels = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = { };
        description = ''
          A list of labels to be attached to the volume at runtime.
        '';
        example = { "foo" = "baz"; };
      };

      extraOptions = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          A list of extra arguments to be passed to {command}`${options.virtualisation.oci-containers.backend.default} run`.
        '';
        default = [ ];
      };

      preRunExtraOptions = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          A list of extra arguments to be passed to {command}`${options.virtualisation.oci-containers.backend.default}`.
        '';
        default = [ ];
      };
    };

    config.extraOptions =
      lib.mapAttrsToList (name: value: "--label ${name}=${value}")
      config.labels;
  };

  mkService = name: value:
    let
      removeScript = if cfg.backend == "podman" then
        "podman volume rm --force ${name}"
      else
        "${cfg.backend} volume rm -f ${name}";

      preStartScript =
        pkgs.writeShellScript "pre-start-oci-container-volume-${name}" ''
          ${removeScript}
        '';
    in {
      path = if cfg.backend == "docker" then
        [ config.virtualisation.docker.package ]
      else if cfg.backend == "podman" then
        [ config.virtualisation.podman.package ]
      else
        throw "Unhandled backend: ${cfg.backend}";
      script = lib.concatStringsSep "  \\\n  " ([ "exec ${cfg.backend} " ]
        ++ (map escapeShellArg value.preRunExtraOptions) ++ [ "volume create" ]
        ++ (map escapeShellArg value.extraOptions) ++ [ name ]);
      postStop = removeScript;

      serviceConfig = {
        ExecStartPre = [ preStartScript ];
        Type = "oneshot";
        RemainAfterExit = true;
      };

      before = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
    };
in {
  options.virtualisation.oci-containers.volumes = lib.mkOption {
    type = with lib.types; attrsOf (submodule volumeModule);
    description = ''
      An array of options to be made with the container engine.
    '';
    default = { };
    example = {
      penpot = { };
      foo.labels = { bar = "baz"; };
    };
  };

  config = lib.mkIf (cfg.volumes != { }) {
    systemd.services = lib.mapAttrs'
      (n: v: lib.nameValuePair "${cfg.backend}-volume-${n}" (mkService n v))
      cfg.volumes;
  };
}
