{ config, lib, options, pkgs, ... }:

let
  cfg = config.sandboxing.bubblewrap.launcher;

  bubblewrapModuleFactory = { isGlobal ? false }: {
    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        Package containing the specialized Bubblewrap launcher used for this
        module.
      '';
      default = if isGlobal then pkgs.callPackage ./launcher/package.nix { } else cfg.package;
    };

    integrations = let
      mkLauncherEnableOption = service: serviceName: lib.mkEnableOption "launcher integration for ${serviceName}" // {
        default = if isGlobal then true else cfg.integrations.${service}.enable;
      };
      in {
        pipewire.enable = mkLauncherEnableOption "pipewire" "Pipewire";
        pulseaudio.enable = mkLauncherEnableOption "pulseaudio" "PulseAudio";
        wayland.enable = mkLauncherEnableOption "wayland" "Wayland desktop sessions";
        x11.enable = mkLauncherEnableOption "x11" "X11-based desktop sessions";
      };
  };
in
{
  options.sandboxing.bubblewrap.launcher = bubblewrapModuleFactory { isGlobal = true; };

  options.wrappers =
    let
      bubblewrapLauncherSubmodule = { config, lib, name, ... }: let
        submoduleCfg = config.sandboxing.bubblewrap.launcher;
        envSuffix = word: "WRAPPER_MANAGER_BWRAP_LAUNCHER_${word}";
      in {
        options.sandboxing.bubblewrap.launcher = bubblewrapModuleFactory { isGlobal = false; };

        config = lib.mkIf (config.sandboxing.variant == "bubblewrap") (lib.mkMerge [
          {
            arg0 = lib.getExe' submoduleCfg.package "wrapper-manager-bubblewrap-launcher";
            prependArgs = lib.mkBefore
              (config.sandboxing.bubblewrap.extraArgs
                ++ [ "--" config.sandboxing.wraparound.arg0 ]
                ++ config.sandboxing.wraparound.extraArgs);
            env = {
              "${envSuffix "BWRAP"}".value = lib.getExe' config.sandboxing.bubblewrap.package "bwrap";
              # We're just unsetting autoconfigure since we're configuring this
              # through the module system anyways and would allow the user to
              # have some more control over what can be enabled.
              "${envSuffix "AUTOCONFIGURE"}".value = "0";
            };
          }

          (lib.mkIf config.sandboxing.bubblewrap.dbus.enable {
            env.${envSuffix "DBUS_PROXY"}.value = lib.getExe' config.sandboxing.bubblewrap.dbus.filter.package "xdg-dbus-proxy";
            env.${envSuffix "DBUS_PROXY_ARGS"}.value = lib.concatStringsSep " " config.sandboxing.bubblewrap.dbus.filter.extraArgs;
            env.${envSuffix "DBUS_PROXY_BWRAP_ARGS"}.value = lib.concatStringsSep " " config.sandboxing.bubblewrap.dbus.filter.bwrapArgs;
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
    in
      lib.mkOption {
        type = with lib.types; attrsOf (submodule bubblewrapLauncherSubmodule);
      };
}
