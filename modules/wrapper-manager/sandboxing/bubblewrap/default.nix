# Bubblewrap integration within wrapper-manager. Several parts were inspired
# from the source code's given examples (at `demo` directory) as well as a few
# Nix projects integrating with it such as `nix-bubblewrap`
# (https://git.sr.ht/~fgaz/nix-bubblewrap) and NixPak
# (https://github.com/nixpak/nixpak).
#
# Similar to most of them, this is basically a builder for the right arguments
# to be passed to `bwrap`.
#
# As already mentioned from the Bubblewrap README, we'll have to be careful for
# handling D-Bus so we'll use xdg-dbus-proxy for that.
{ config, lib, pkgs, ... }:

let
  inherit (pkgs) stdenv;
  cfg = config.sandboxing.bubblewrap;

  bubblewrapModuleFactory = { isGlobal ? false }: {
    package = lib.mkPackageOption pkgs "bubblewrap" { } // lib.optionalAttrs isGlobal {
      default = cfg.package;
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description =
        if isGlobal
        then ''
          Global list of extra arguments to be given to all Bubblewrap-enabled
          wrappers.
        ''
        else ''
          List of extra arguments to be given to the Bubblewrap executable.
        '';
    };

    enableSharedNixStore = lib.mkEnableOption "sharing of the Nix store" // {
      default = if isGlobal then true else cfg.enableSharedNixStore;
    };

    enableNetwork = lib.mkEnableOption "sharing of the host network" // lib.optionalAttrs isGlobal {
      default = if isGlobal then true else cfg.enableNetwork;
    };

    enableIsolation = lib.mkEnableOption "unsharing most of the system" // {
      default = if isGlobal then true else cfg.enableIsolation;
    };

    binds = {
      ro = lib.mkOption {
        type = with lib.types; listOf path;
        default = if isGlobal then [ ] else cfg.binds.ro;
        description =
          if isGlobal
          then ''
            Global list of read-only mounts to be given to all Bubblewrap-enabled
            wrappers.
          ''
          else ''
            List of read-only mounts to the Bubblewrap environment.
          '';
        example = [
          "/etc/resolv.conf"
          "/etc/ssh"
        ];
      };

      rw = lib.mkOption {
        type = with lib.types; listOf path;
        default = if isGlobal then [ ] else cfg.binds.rw;
        description =
          if isGlobal
          then ''
            Global list of read-write mounts to be given to all
            Bubblewrap-enabled wrappers.
          ''
          else ''
            List of read-write mounts to the Bubblewrap environment.
          '';
      };

      dev = lib.mkOption {
        type = with lib.types; listOf path;
        default = if isGlobal then [ ] else cfg.binds.dev;
        description =
          if isGlobal 
          then ''
            Global list of devices to be mounted to all Bubblewrap-enabled
            wrappers.
          ''
          else ''
            List of devices to be mounted inside of the Bubblewrap environment.
          '';
      };
    };
  };
in
{
  imports = [
    ./dbus-filter.nix
  ];

  options.sandboxing.bubblewrap = bubblewrapModuleFactory { isGlobal = true; };

  options.wrappers =
    let
      bubblewrapModule = { name, config, lib, pkgs, ... }:
        let
          submoduleCfg = config.sandboxing.bubblewrap;
        in
        {
          options.sandboxing.variant = lib.mkOption {
            type = with lib.types; nullOr (enum [ "bubblewrap" ]);
          };

          options.sandboxing.bubblewrap = bubblewrapModuleFactory { isGlobal = false; };

          config = lib.mkIf (config.sandboxing.variant == "bubblewrap") (lib.mkMerge [
            {
              # TODO: All of the Linux-exclusive flags could be handled by the
              # launcher instead. ALSO MODULARIZE THIS CRAP!
              # Ordering of the arguments here matter(?).
              bubblewrap.extraArgs =
                cfg.extraArgs
                ++ lib.optionals stdenv.isLinux [
                  "--proc" "/proc"
                  "--dev" "/dev"
                ]
                ++ builtins.map (bind: "--ro-bind-try ${bind}") submoduleCfg.binds.ro
                ++ builtins.map (bind: "--bind ${bind}") submoduleCfg.binds.rw
                ++ builtins.map (bind: "--dev-bind-try ${bind}") submoduleCfg.binds.dev
                ++ builtins.map (var: "--unsetenv ${var}") config.unset
                ++ lib.mapAttrsToList (var: value: "--setenv ${var} ${value}") config.env;

              arg0 = lib.getExe' submoduleCfg.package "bwrap";
              prependArgs = lib.mkBefore (submoduleCfg.extraArgs ++ [ "--" submoduleCfg.wraparound.executable ] ++ submoduleCfg.wraparound.extraArgs);
            }

            (lib.mkIf submoduleCfg.enableSharedNixStore {
              bubblewrap.binds.ro = [ builtins.storeDir ] ++ lib.optionals (builtins.storeDir != "/nix/store") [ "/nix/store" ];
            })

            (lib.mkIf submoduleCfg.enableNetwork {
              # In case isolation is also enabled, we'll have this still
              # enabled at least.
              bubblewrap.extraArgs = lib.mkAfter [ "--share-net" ];
              bubblewrap.binds.ro = [
                "/etc/ssh"
                "/etc/hosts"
                "/etc/resolv.conf"
              ];
            })

            (lib.mkIf submoduleCfg.enableIsolation {
              bubblewrap.extraArgs = lib.mkBefore [ "--unshare-all" ];
            })
          ]);
        };
    in
    lib.mkOption {
      type = with lib.types; attrsOf (submodule bubblewrapModule);
    };
}
