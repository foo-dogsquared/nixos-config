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

    enableNetwork = lib.mkEnableOption "sharing of the host network" // lib.optionalAttrs isGlobal {
      default = if isGlobal then true else cfg.enableNetwork;
    };

    enableIsolation = lib.mkEnableOption "unsharing most of the system" // {
      default = if isGlobal then true else cfg.enableIsolation;
    };

    enableEnsureChildDiesWithParent = lib.mkEnableOption "ensuring child processes die with parent" // {
      default = if isGlobal then true else cfg.enableEnsureChildDiesWithParent;
    };
  };
in
{
  imports = [
    ./dbus-filter.nix
    ./filesystem.nix
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
              sandboxing.bubblewrap.extraArgs =
                cfg.extraArgs
                ++ lib.optionals stdenv.isLinux [
                  "--proc" "/proc"
                  "--dev" "/dev"
                ]
                ++ lib.mapAttrsToList
                  (var: metadata:
                    if metadata.action == "unset"
                    then "--unsetenv ${var}"
                    else "--setenv ${var} ${metadata.value}")
                  config.env;

              arg0 = lib.getExe' submoduleCfg.package "bwrap";
              prependArgs = lib.mkBefore
                (submoduleCfg.extraArgs
                  ++ [ "--" config.sandboxing.wraparound.executable ]
                  ++ config.sandboxing.wraparound.extraArgs);
            }

            (lib.mkIf submoduleCfg.enableNetwork {
              # In case isolation is also enabled, we'll have this still
              # enabled at least.
              sandboxing.bubblewrap.extraArgs = lib.mkAfter [ "--share-net" ];

              # The most common network-related files found on most
              # distributions. This should be enough in most cases. If not,
              # we'll probably let the launcher handle this.
              sandboxing.bubblewrap.binds.ro = [
                "/etc/ssh"
                "/etc/hosts"
                "/etc/resolv.conf"
              ];
            })

            (lib.mkIf submoduleCfg.enableIsolation {
              sandboxing.bubblewrap.extraArgs = lib.mkBefore [ "--unshare-all" ];
            })

            (lib.mkIf submoduleCfg.enableEnsureChildDiesWithParent {
              sandboxing.bubblewrap.extraArgs = lib.mkBefore [ "--die-with-parent" ];
            })
          ]);
        };
    in
    lib.mkOption {
      type = with lib.types; attrsOf (submodule bubblewrapModule);
    };
}
