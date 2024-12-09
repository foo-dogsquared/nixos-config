{ config, lib, options, pkgs, ... }:

let
  cfg = config.virtualisation.oci-containers;
  inherit (lib) escapeShellArg;

  networkVolume = { config, lib, ... }: {
    options = {
      labels = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = { };
        description = ''
          A list of labels to be attached to the network at runtime.
        '';
        example = {
          "foo" = "baz";
        };
      };

      ipv6 = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable IPv6 networking";
        example = false;
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
      lib.optionals config.ipv6 [ "--ipv6" ]
      ++ lib.mapAttrsToList (name: value: "--label ${name}=${value}") config.labels;
  };

  mkService = name: value: let
    removeScript =
      if cfg.backend == "podman"
      then "podman network rm --force ${name}"
      else "${cfg.backend} network rm -f ${name}";

    preStartScript = pkgs.writeShellScript "pre-start-oci-container-network-${name}" ''
      ${removeScript}
    '';
  in {
    path =
      if cfg.backend == "docker" then [ config.virtualisation.docker.package ]
      else if cfg.backend == "podman" then [ config.virtualisation.podman.package ]
      else throw "Unhandled backend: ${cfg.backend}";
    script = lib.concatStringsSep "  \\\n  " ([
      "exec ${cfg.backend} "
    ] ++ (map escapeShellArg value.preRunExtraOptions) ++ [
      "network create"
    ] ++ (map escapeShellArg value.extraOptions) ++ [
      name
    ]);
    postStop = removeScript;

    serviceConfig = {
      ExecStartPre = [ preStartScript ];
      Type = "oneshot";
      RemainAfterExit = true;
    };

    before = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
  };
in
{
  options.virtualisation.oci-containers.networks = lib.mkOption {
    type = with lib.types; attrsOf (submodule networkVolume);
    description = ''
      A set of networks to be created into the container engine at runtime.
    '';
    default = { };
    example = {
      penpot = { };
      foo.labels = { "bar" = "baz"; };
    };
  };

  config = lib.mkIf (cfg.networks != { }) {
    systemd.services = lib.mapAttrs' (n: v: lib.nameValuePair "${cfg.backend}-network-${n}" (mkService n v)) cfg.networks;
  };
}
