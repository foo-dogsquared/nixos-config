# Module revolving around the specialized launcher. It is managed as a separate
# project in the launcher subdirectory. Just look into the source code as you
# would spelunk any other project. So far, the subproject itself doesn't have a
# good state of testing (which is just used as a program for this very purpose)
# so just use wrapper-manager's testing infra instead.
{ config, lib, options, pkgs, ... }:

let
  cfg = config.wraparound.bubblewrap.launcher;

  bubblewrapModuleFactory = { isGlobal ? false }: {
    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        Package containing the specialized Bubblewrap launcher used for this
        module.
      '';
      default = if isGlobal then
        pkgs.callPackage ./launcher/package.nix { }
      else
        cfg.package;
    };

    integrations = let
      mkLauncherEnableOption = service: serviceName:
        lib.mkEnableOption "launcher integration for ${serviceName}" // {
          default =
            if isGlobal then true else cfg.integrations.${service}.enable;
        };
    in {
      pipewire.enable = mkLauncherEnableOption "pipewire" "Pipewire";
      pulseaudio.enable = mkLauncherEnableOption "pulseaudio" "PulseAudio";
      wayland.enable =
        mkLauncherEnableOption "wayland" "Wayland desktop sessions";
      x11.enable = mkLauncherEnableOption "x11" "X11-based desktop sessions";
    };
  };
in {
  options.wraparound.bubblewrap.launcher =
    bubblewrapModuleFactory { isGlobal = true; };

  options.wrappers = let
    bubblewrapLauncherSubmodule = { config, lib, name, ... }:
      let
        submoduleCfg = config.wraparound.bubblewrap.launcher;
        envSuffix = word: "WRAPPER_MANAGER_BWRAP_LAUNCHER_${word}";
      in {
        options.wraparound.bubblewrap.launcher =
          bubblewrapModuleFactory { isGlobal = false; };

        config = lib.mkIf (config.wraparound.variant == "bubblewrap")
          (lib.mkMerge [
            {
              arg0 = lib.getExe' submoduleCfg.package
                "wrapper-manager-bubblewrap-launcher";
              prependArgs = lib.mkBefore (config.wraparound.bubblewrap.extraArgs
                ++ [ "--" config.wraparound.subwrapper.arg0 ]
                ++ config.wraparound.subwrapper.extraArgs);
              env = {
                "${envSuffix "BWRAP"}".value =
                  lib.getExe' config.wraparound.bubblewrap.package "bwrap";
                # We're just unsetting autoconfigure since we're configuring this
                # through the module system anyways and would allow the user to
                # have some more control over what can be enabled.
                "${envSuffix "AUTOCONFIGURE"}".value = lib.mkDefault "0";
              };
            }

            (lib.mkIf config.wraparound.bubblewrap.dbus.enable {
              env.${envSuffix "DBUS_PROXY"}.value =
                lib.getExe' config.wraparound.bubblewrap.dbus.filter.package
                "xdg-dbus-proxy";
              env.${envSuffix "DBUS_PROXY_ARGS"}.value =
                lib.concatStringsSep " "
                config.wraparound.bubblewrap.dbus.filter.extraArgs;
              env.${envSuffix "DBUS_PROXY_BWRAP_ARGS"}.value =
                lib.concatStringsSep " "
                config.wraparound.bubblewrap.dbus.filter.bwrapArgs;
            })

            (lib.mkIf submoduleCfg.integrations.pulseaudio.enable {
              env.${envSuffix "PULSEAUDIO"}.value = "1";
            })

            (lib.mkIf submoduleCfg.integrations.pipewire.enable {
              env.${envSuffix "PIPEWIRE"}.value = "1";
            })

            (lib.mkIf submoduleCfg.integrations.x11.enable {
              env.${envSuffix "X11"}.value = "1";
            })

            (lib.mkIf submoduleCfg.integrations.wayland.enable {
              env.${envSuffix "WAYLAND"}.value = "1";
            })
          ]);
      };
  in lib.mkOption {
    type = with lib.types; attrsOf (submodule bubblewrapLauncherSubmodule);
  };
}
