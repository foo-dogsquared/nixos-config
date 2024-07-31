{
  config,
  lib,
  pkgs,
  ...
}:

let
  # We're only setting up options for the most common keys typically used to
  # set up a desktop entry. Everything else is acceptable under a freeform
  # module anyways.
  xdgDesktopEntry =
    {
      name,
      lib,
      pkgs,
      ...
    }:
    {
      freeformType = with lib.types; attrsOf anything;

      options = {
        name = lib.mkOption {
          type = lib.types.nonEmptyStr;
          description = "The name of the desktop file.";
          default = name;
          example = "firefox";
        };

        desktopName = lib.mkOption {
          type = lib.types.nonEmptyStr;
          description = "Specific name of the application.";
          default = name;
          example = "Firefox";
        };

        exec = lib.mkOption {
          type = with lib.types; nullOr nonEmptyStr;
          description = "Program with execute along with its arguments.";
          default = null;
          example = "firefox %U";
        };

        genericName = lib.mkOption {
          type = with lib.types; nullOr nonEmptyStr;
          description = "Generic name of the application.";
          default = null;
          example = "Web browser";
        };

        terminal = lib.mkOption {
          type = lib.types.bool;
          description = "Whether the program runs in a terminal window.";
          default = false;
          example = true;
        };

        categories = lib.mkOption {
          type = with lib.types; listOf nonEmptyStr;
          description = "List of categories should the application be shown in a menu.";
          default = [ ];
          example = [
            "Applications"
            "Network"
          ];
        };

        mimeTypes = lib.mkOption {
          type = with lib.types; listOf nonEmptyStr;
          description = "The MIME types supported by the application.";
          default = [ ];
          example = [
            "text/html"
            "text/xml"
          ];
        };
      };
    };
in
{
  options.xdg.desktopEntries = lib.mkOption {
    type = with lib.types; attrsOf (submodule xdgDesktopEntry);
    description = ''
      A set of desktop entries to be exported along with the wrapped package.
      The attribute name will be used as the filename of the generated desktop
      entry file.
    '';
    default = { };
    example = lib.literalExpression ''
      {
        firefox = {
          name = "Firefox";
          genericName = "Web browser";
          exec = "firefox %u";
          terminal = false;
          categories = [ "Application" "Network" "WebBrowser" ];
          mimeTypes = [ "text/html" "text/xml" ];
          extraConfig."X-GNOME-Autostart-Phase" = "WindowManager";
          keywords = [ "Web" "Browser" ];
          startupNotify = false;
          startupWMClass = "MyOwnClass";
        };
      }
    '';
  };

  options.wrappers = lib.mkOption {
    type =
      let
        xdgDesktopEntryWrapperSubmodule =
          {
            name,
            config,
            lib,
            ...
          }:
          {
            options.xdg.desktopEntry = {
              enable = lib.mkEnableOption "automatic creation of a desktop entry for the wrapper";
              settings = lib.mkOption {
                type = lib.types.submodule xdgDesktopEntry;
                description = ''
                  Settings to be passed to the `makeDesktopItem` builder.
                '';
                example = lib.literalExpression ''
                  {
                    mimeTypes = [ "text/html" "text/xml" ];
                    categories = [ "Applications" "Network" ];
                  }
                '';
              };
            };

            config.xdg.desktopEntry.settings = lib.mkIf config.xdg.desktopEntry.enable {
              name = lib.mkDefault config.executableName;
              desktopName = lib.mkDefault name;
              type = lib.mkDefault "Application";

              # Welp, we could set it to the absolute location of the wrapper
              # executable in the final output but it's a big pain the ass to do
              # so we're opting to the executable name instead. This current
              # way of doing it is simply the next best (and the simplest) thing.
              # We just have to make sure the build step for the wrapper script
              # is consistent throughout the entire module environment.
              #
              # Besides, if the user wants a desktop entry along with the wrapper
              # script, it will be included alongside in whatever environment
              # they are using it for anyways.
              exec = config.executableName;
            };
          };
      in
      with lib.types;
      attrsOf (submodule xdgDesktopEntryWrapperSubmodule);
  };

  config = {
    xdg.desktopEntries =
      let
        wrappersWithDesktopEntries = lib.filterAttrs (_: v: v.xdg.desktopEntry.enable) config.wrappers;
      in
      lib.mapAttrs (_: v: v.xdg.desktopEntry.settings) wrappersWithDesktopEntries;
  };
}
