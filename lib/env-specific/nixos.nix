# All of the functions suitable only for NixOS.
{ pkgs, lib, self }:

{
  # Checks if the NixOS configuration is part of the nixos-generator build.
  # Typically, we just check if there's a certain attribute that is imported
  # from it.
  hasNixosFormat = config:
    lib.hasAttrByPath [ "formatAttr" ] config;

  # Checks if the NixOS config is being built for a particular format.
  isFormat = config: format:
    (config.formatAttr or "") == format;

  # Create a separate environment similar to NixOS `system.path`. This is
  # typically used to create isolated environments for custom desktop sessions
  # which makes it possible to have them installed side-by-side with their own
  # set of applications and everything (except for overlapping NixOS services
  # that will just add them into the NixOS environment itself).
  mkNixoslikeEnvironment = config: args:
    pkgs.buildEnv (args // {
      inherit (config.environment) pathsToLink extraOutputsToInstall;
      ignoreCollisions = true;
      postBuild =
       ''
         # Remove wrapped binaries, they shouldn't be accessible via PATH.
         find $out/bin -maxdepth 1 -name ".*-wrapped" -type l -delete

         if [ -x $out/bin/glib-compile-schemas -a -w $out/share/glib-2.0/schemas ]; then
             $out/bin/glib-compile-schemas $out/share/glib-2.0/schemas
         fi

         ${config.environment.extraSetup}
       '';
    });

  # Given an environment (built with `pkgs.buildEnv`), create a systemd
  # environment attrset meant to be used as part of the desktop service.
  mkSystemdDesktopEnvironment = env: {
    PATH = "${lib.getBin env}\${PATH:+:$PATH}";
    XDG_DATA_DIRS = "${env}/share\${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}";
    XDG_CONFIG_DIRS = "${env}/etc/xdg\${XDG_CONFIG_DIRS:+:$XDG_CONFIG_DIRS}";
  };
}
