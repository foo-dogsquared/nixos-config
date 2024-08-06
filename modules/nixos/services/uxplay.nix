{ config, lib, pkgs, ... }:

let
  cfg = config.services.uxplay;
in
{
  options.services.uxplay = {
    enable = lib.mkEnableOption "uxplay, an Airplay mirroring server";

    package = lib.mkPackageOption pkgs "uxplay" { };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        Extra arguments to passed onto the service executable.
      '';
      default = [ ];
      example = [ "-p" "4747" ];
    };
  };

  config = lib.mkIf cfg.enable {
    # UXPlay requires a DNS-SD server so we'll enable Avahi.
    services.avahi.enable = lib.mkDefault true;
    services.avahi.publish.enable = lib.mkDefault true;
    services.avahi.publish.userServices = lib.mkDefault true;

    # We also have enabled mDNS since we're already using Avahi anyways.
    services.avahi.nssmdns4 = lib.mkDefault true;
    services.avahi.nssmdns6 = lib.mkDefault true;

    systemd.services.uxplay = {
      description = "Airplay mirroring server";
      after = [ "network.target" ];
      documentation = [ "man:uxplay(1)" ];
      wantedBy = [ "multi-user.target" ];
      script = "${lib.getExe' cfg.package "uxplay"} ${lib.escapeShellArgs cfg.extraArgs}";
      serviceConfig = {
        DynamicUser = true;
        User = "uxplay";
        Group = "uxplay";
        RuntimeDirectory = "uxplay";

        Restart = "on-failure";
        LockPersonality = true;
        NoNewPrivileges = true;
        MemoryDenyWriteExecute = true;

        CapabilityBoundSet = lib.mkForce [ ];
        PrivateTmp = true;
        PrivateUsers = true;
        PrivateDevices = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;

        RestrictRealtime = true;
        RestrictAddressFamilies = [
          "AF_LOCAL"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;

        SystemCallFilter = [ "@system-service" "~@privileged" ];
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
      };
      unitConfig = {
        StartLimitBurst = 5;
        StartLimitIntervalSec = 10;
      };
    };
  };
}
