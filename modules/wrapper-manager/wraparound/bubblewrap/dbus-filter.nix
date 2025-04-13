# The D-Bus integration for Bubblewrap-wrapped wrappers. As noted from the
# Bubblewrap's README, it encourages to use something like xdg-dbus-proxy to
# limit reach to overarching services such as systemd's so we're doing it here.
{ config, lib, options, pkgs, ... }:

let
  cfg = config.wraparound.bubblewrap;

  dbusFilterType = { lib, ... }:
    let ruleBasedPoliciesType = with lib.types; listOf str;
    in {
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
        package = lib.mkPackageOption pkgs "xdg-dbus-proxy" { }
          // lib.optionalAttrs isGlobal { default = cfg.filter.package; };
      };
    };
  };
in {
  options.wraparound.bubblewrap =
    lib.recursiveUpdate (bubblewrapModuleFactory { isGlobal = true; }) {
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

  options.wrappers = let
    addressesModule = { config, lib, name, ... }: {
      options = {
        path = lib.mkOption {
          type = lib.types.str;
          default =
            "$XDG_RUNTIME_DIR/wrapper-manager-fds/$(echo $RANDOM | base64)";
          description = ''
            Path of the unix socket domain. A value of `null` means
            the launcher takes care of it.
          '';
        };

        policies = lib.mkOption {
          type = lib.types.submodule dbusFilterType;
          description = ''
            Policies to be set to that address.
          '';
          default = { };
          example = { level = "see"; };
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

      config.policies = cfg.dbus.filter.policies;
      config.extraArgs = let inherit (config) policies;
      in lib.optionals (policies.level != null)
      [ "--${policies.level}=${name}" ]
      ++ lib.map (rule: "--call=${name}=${rule}") policies.call
      ++ lib.map (rule: "--broadcast=${name}=${rule}") policies.broadcast;
    };

    bubblewrapModule = { config, lib, pkgs, name, ... }:
      let submoduleCfg = config.wraparound.bubblewrap;
      in {
        options.wraparound.bubblewrap =
          lib.recursiveUpdate (bubblewrapModuleFactory { isGlobal = false; }) {
            dbus.filter = {
              extraArgs = lib.mkOption {
                type = with lib.types; listOf str;
                description = ''
                  List of arguments to be passed to {command}`xdg-dbus-proxy`.
                '';
                default = [ ];
              };

              bwrapArgs = lib.mkOption {
                type = with lib.types; listOf str;
                description = ''
                  List of arguments to be passed to the Bubblewrap
                  environment of the D-Bus proxy.
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
                  "org.example.Bar".policies.level = "talk";
                  "org.freedesktop.systemd1".policies.level = "talk";
                  "org.gtk.vfs.*".policies.level = "talk";
                  "org.gtk.vfs".policies.level = "talk";
                };
              };
            };
          };

        config = lib.mkIf (config.wraparound.variant == "bubblewrap") {
          wraparound.bubblewrap.dbus.filter.extraArgs = let
            makeDbusProxyArgs = address: metadata:
              [ address (builtins.toString metadata.path) ]
              ++ metadata.extraArgs;
          in lib.lists.flatten (lib.mapAttrsToList makeDbusProxyArgs
            submoduleCfg.dbus.filter.addresses);

          wraparound.bubblewrap.sharedNixPaths =
            [ submoduleCfg.dbus.filter.package ];
        };
      };
  in lib.mkOption {
    type = with lib.types; attrsOf (submodule bubblewrapModule);
  };
}
