# The D-Bus integration for Bubblewrap-wrapped wrappers. As noted from the
# Bubblewrap's README, it encourages to use something like xdg-dbus-proxy to
# limit reach to overarching services such as systemd's so we're doing it here.
{ config, lib, options, pkgs, ... }:

let
  cfg = config.sandboxing.bubblewrap;

  dbusFilterType = { lib, ... }:
    let
      ruleBasedPoliciesType = with lib.types; listOf str;
    in
    {
      options = {
        level = lib.mkOption {
          type = with lib.types; nullOr (enum [ "see" "talk" "own" ]);
          description = ''
            Basic policy action level for a given name.
          '';
          default = null;
          example = "see";
        };

        call = lib.mkOption {
          type = ruleBasedPoliciesType;
          description = ''
            A list of rules to be specified for calls on the given name.
          '';
          default = [ ];
          example = [ "*@com.example.*" ];
        };

        broadcast = lib.mkOption {
          type = ruleBasedPoliciesType;
          description = ''
            A list of rules to be specified for broadcasts on the given name;
          '';
          default = [ ];
          example = [ ];
        };
      };
    };

  bubblewrapModuleFactory = { isGlobal ? false }: {
    dbus = {
      enable = lib.mkEnableOption "D-Bus integration" // {
        default = if isGlobal then false else cfg.dbus.enable;
      };

      filter = {
        package = lib.mkPackageOption pkgs "xdg-dbus-proxy" { } // lib.optionalAttrs isGlobal {
          default = cfg.filter.package;
        };
      };
    };

  };
in
{
  options.sandboxing.bubblewrap =
    lib.recursiveUpdate
      (bubblewrapModuleFactory { isGlobal = true; })
      {
        dbus.filter.policies = lib.mkOption {
          type = with lib.types; attrsOf (submodule dbusFilterType);
          description = ''
            A global set of D-Bus addresses with their policies set with
            {command}`xdg-dbus-proxy` for each D-Bus address specified on the
            Bubblewrap-enabled wrappers. See {manpage}`xdg-dbus-proxy(1)` for
            more details.
          '';
          default = { };
          example = {
            "org.systemd.Systemd".level = "talk";
            "org.example.*".level = "own";
            "org.foo.Bar" = {
              call = [ "*" ];
              broadcast = [ ];
            };
          };
        };
      };

  options.wrappers =
    let
      addressesModule = { config, lib, ... }: {
        options = {
          path = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = ''
              Path of the unix socket domain. A value of `null` means
              the launcher takes care of it.
            '';
          };

          policies = options.sandboxing.bubblewrap.dbus.filter.policies // {
            default = cfg.dbus.filter.policies;
          };

          extraArgs = lib.mkOption {
            type = with lib.types; listOf str;
            description = ''
              List of proxy-specific arguments to be passed to
              {command}`xdg-dbus-proxy`.
            '';
            default = [ ];
          };
        };

        config.extraArgs =
          let
            makePolicyArgs = dbusName: policyMetadata:
              lib.optionals (policyMetadata.level != null) [ "--${policyMetadata.level}=${dbusName}" ]
              ++ builtins.map (rule: "--call=${dbusName}=${rule}") policyMetadata.call
              ++ builtins.map (rule: "--broadcast=${dbusName}=${rule}") policyMetadata.broadcast;
          in
            lib.mapAttrsToList makePolicyArgs config.dbus.filter.policies;
      };

      bubblewrapModule = { config, lib, pkgs, name, ... }:
        let
          submoduleCfg = config.sandboxing.bubblewrap;
        in
          {
            options.sandboxing.bubblewrap =
              lib.recursiveUpdate
                (bubblewrapModuleFactory { isGlobal = false; })
                {
                  dbus.filter = {
                    extraArgs = lib.mkOption {
                      type = with lib.types; listOf str;
                      description = ''
                        List of arguments to be passed to {command}`xdg-dbus-proxy`.
                      '';
                      default = [ ];
                    };

                    addresses = lib.mkOption {
                      type = with lib.types; attrsOf (submodule addressesModule);
                      description = ''
                        A set of addresses to be applied with the filter through
                        {command}`xdg-dbus-proxy`.
                      '';
                      default = { };
                      example = {
                        "org.example.Bar" = {
                        };
                      };
                    };
                  };
                };

              config = lib.mkIf (config.sandboxing.variant == "bubblewrap") {
                sandboxing.bubblewrap.dbus.filter.extraArgs =
                  let
                    makeDbusProxyArgs = address: metadata:
                      [ address metadata.path ] ++ metadata.extraArgs;
                  in
                  lib.lists.flatten (lib.mapAttrsToList makeDbusProxyArgs submoduleCfg.dbus.filter.addresses);
              };
            };
    in
      lib.mkOption {
        type = with lib.types; attrsOf (submodule bubblewrapModule);
      };
}
