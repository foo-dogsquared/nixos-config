# Bubblewrap integration within wrapper-manager. Several parts were inspired
# from the source code's given examples (at `demo` directory) as well as a few
# Nix projects integrating with it such as `nix-bubblewrap`
# (https://git.sr.ht/~fgaz/nix-bubblewrap) and NixPak
# (https://github.com/nixpak/nixpak).
#
# Similar to most of them, this is basically a builder for the right arguments
# to be passed to `bwrap`.
#
# Also similar to those projects, we also have a launcher (at `launcher`
# subdirectory) specializing in Bubblewrap-wrapped programs. The reasoning is
# it allows us to easily take care of things that are hard to do inside of Nix
# such as handling hardware configuration and the experience to have to do all
# of that in nixpkgs runtime shell (Bash) is a pain to develop.
#
# As already mentioned from the Bubblewrap README, we'll have to be careful for
# handling D-Bus so we'll use xdg-dbus-proxy for that.
{ config, lib, pkgs, ... }:

let
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

    enableNetwork = lib.mkEnableOption "sharing of the host network" // {
      default = if isGlobal then true else cfg.enableNetwork;
    };

    enableBundledCertificates = lib.mkEnableOption "bundling additional certificates from nixpkgs" // {
      default = if isGlobal then true else cfg.enableBundledCertificates;
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
    ./launcher.nix
    ./dbus-filter.nix
    ./filesystem.nix
  ];

  options.sandboxing.bubblewrap = bubblewrapModuleFactory { isGlobal = true; };

  options.wrappers =
    let
      bubblewrapModule = { name, config, lib, ... }:
        let
          submoduleCfg = config.sandboxing.bubblewrap;
          env' = lib.filterAttrs (n: _: !(lib.strings.hasPrefix "WRAPPER_MANAGER_BWRAP_LAUNCHER" n)) config.env;
        in
        {
          options.sandboxing.variant = lib.mkOption {
            type = with lib.types; nullOr (enum [ "bubblewrap" ]);
          };

          options.sandboxing.bubblewrap = bubblewrapModuleFactory { isGlobal = false; };

          config = lib.mkIf (config.sandboxing.variant == "bubblewrap") (lib.mkMerge [
            {
              # Ordering of the arguments here matter(?).
              sandboxing.bubblewrap.extraArgs =
                cfg.extraArgs
                ++ lib.mapAttrsToList
                  (var: metadata:
                    if metadata.action == "unset" then
                      "--unsetenv ${var}"
                    else if lib.elem metadata.action [ "prefix" "suffix" ] then
                      "--setenv ${lib.escapeShellArg var} ${lib.escapeShellArg (lib.concatStringsSep metadata.separator metadata.value)}"
                    else
                      "--setenv ${lib.escapeShellArg var} ${lib.escapeShellArg metadata.value}")
                  env';
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
                "/etc/ssl"
                "/etc/hosts"
                "/etc/resolv.conf"
              ];
            })

            (lib.mkIf submoduleCfg.enableBundledCertificates {
              sandboxing.bubblewrap.sharedNixPaths = [ pkgs.cacert ];
            })

            (lib.mkIf config.locale.enable {
              sandboxing.bubblewrap.sharedNixPaths = [ config.locale.package ];
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
