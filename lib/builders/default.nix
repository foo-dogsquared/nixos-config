{ pkgs, lib, self }:

{
  /**
    Create a derivation containing an XDG MIME association listing.

    # Arguments

    It's a sole attribute set with the following attributes:

    config
    : Nix-representable settings in INI format.

    desktopName
    : An optional string containing the desktop name. By default, it's empty
    representing the global settings. Otherwise, it's considered to be
    desktop-specific.

    addedAssociations
    : An attrset of MIME associations. This is not set if it's a
    desktop-specific configuration.

    removedAssociations
    : An attrset of MIME associations. This is not set if it's a
    desktop-specific configuration.

    defaultApplications
    : An attrset of MIME associations for default applications.

    settings
    : Nix-representable settings in INI format. Mutually exclusive with the
    proper associations attribute and ignores proper checking if set. By
    default, it is empty.

    # Type

    ```
    makeXDGMimeAssociationList :: Attr -> Derivation
    ```

    # Examples

    ```nix
    makeXDGMimeAssociationList {
      defaultApplications = { "application/pdf" = "firefox.desktop"; };
      addedAssociations = {
      };
    }
    ```
  */
  makeXDGMimeAssociationList =
    pkgs.callPackage ./xdg/make-association-list.nix { };

  /**
    Create a derivation containing an XDG Portal configuration.

    # Arguments

    It's a sole attribute set with the following attributes:

    config
    : The settings as a Nix-representable settings in INI format.

    desktopName
    : The name of the desktop name. By default, it is set to `common` which is
    considered as the global namespace. Otherwise, you can just set
    desktop-specific settings.

    # Type

    ```
    makeXDGPortalConfiguration :: Attr -> Derivation
    ```

    # Examples

    ```nix
    makeXDGPortalConfiguration {
      desktopName = "one.foodogsquared.SampleDesktop";
      config.preferred = {
        default = "gtk";
        "org.freedesktop.impl.portal.Screencast" = "gnome";
      };
    }
    ```
  */
  makeXDGPortalConfiguration =
    pkgs.callPackage ./xdg/make-portal-config.nix { };

  /**
    Create a derivation containing an XDG desktop entry file. Unlike
    `pkgs.makeDesktopItem`, it's more freeform.

    # Arguments

    It's a sole attribute set with the following attributes:

    name
    : Name of the desktop entry. Only used as part of the package name and the
    default value of the destination path.

    config
    : Nix-representable data to be exported as the desktop entry.

    validate
    : Add a validation check for the exported desktop entry.

    destination 
    : Destination path relative to the output path.

    # Type

    ```
    makeXDGDesktopEntry :: Attr -> Derivation
    ```

    # Examples

    ```nix
    makeXDGDesktopEntry {
      name = "horizontal-hunger";
      validate = false;
      config = { "Desktop Entry".Exec = "Hello"; };
    }
    ```
  */
  makeXDGDesktopEntry = pkgs.callPackage ./xdg/make-desktop-entry.nix { };

  /**
    A wrapper for building Hugo projects.

    # Arguments

    Similar to `pkgs.buildGoModule`.

    # Type

    ```
    buildHugoSite :: Attr -> Derivation
    ```

    # Examples

    ```nix
    buildHugoSite {
      pname = "foodogsquared-hm-startpage";
      version = "0.3.0";
      src = lib.cleanSource ./.;

      vendorHash = "sha256-Mi61QK1yKWIneZ+i79fpJqP9ew5r5vnv7ptr9YGq0Uk=";

      preBuild = ''
        install -Dm0644 ${
          ../tinted-theming/base16/bark-on-a-tree.yaml
        } ./data/foodogsquared-homepage/themes/_dark.yaml
        install -Dm0644 ${
          ../tinted-theming/base16/albino-bark-on-a-tree.yaml
        } ./data/foodogsquared-homepage/themes/_light.yaml
      '';

      meta = with lib; {
        description = "foodogsquared's homepage";
        license = licenses.gpl3Only;
      };
    }
    ```
  */
  buildHugoSite = pkgs.callPackage ./hugo-build-site { };

  /**
    An convenient function for building with the custom extended stdenv.

    # Arguments

    Similar to `pkgs.buildEnv`.

    # Type

    ```
    buildFDSEnv :: Attr -> Derivation
    ```

    # Examples

    ```nix
    buildFDSEnv {
      paths = with pkgs; [ hello ];
      pathsToLink = [ "/bin" "/share" ];
    }
    ```
  */
  buildFDSEnv =
    pkgs.callPackage ./build-fds-env.nix { extendedStdenv = self.stdenv; };

  /**
    A wrapper for creating dconf databases.

    # Arguments

    A sole attribute set with the following attributes:

    dir
    : The directory of the dconf keyfiles.

    name
    : The name of the dconf database. By default, it is based from the directory name.

    keyfiles
    : A list of keyfiles to be included in the dconf database compilation.

    # Type

    ```
    buildDconfDb :: Attr -> Derivation
    ```

    # Examples

    ```nix
    buildDconfDb {
      dir = ./config/dconf;
      name = "custom-gnome";
    }
    ```
  */
  buildDconfDb = pkgs.callPackage ./build-dconf-db.nix { };
}
