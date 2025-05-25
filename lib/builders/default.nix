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
  buildHugoSite = pkgs.callPackage ./hugo/build-site.nix { };

  /**
    A wrapper for building with mdbook.

    # Arguments

    Similar to `stdenv.mkDerivation` but with a few attributes specific for
    this builder function:

    `buildDir`
    : The output directory used in the build phase of the package.
    By default, it is set to `book`.

    # Type

    ```
    buildMdbookSite :: Attr -> Derivation
    ```

    # Examples

    ```nix
    buildMdbookSite {
      pname = "foodogsquared-hm-startpage";
      version = "0.3.0";
      src = lib.cleanSource ./.;

      meta = with lib; {
        description = "foodogsquared's homepage";
        license = licenses.gpl3Only;
      };
    }
    ```
  */
  buildMdbookSite = pkgs.callPackage ./mdbook/build-site.nix { };

  /**
    A wrapper for building with mkdocs.

    # Arguments

    Similar to `stdenv.mkDerivation` but with a few attributes specific for
    this builder function:

    `buildDir`
    : The output directory used in the build phase of the package.
    By default, it is set to `book`.

    # Type

    ```
    buildMdbookSite :: Attr -> Derivation
    ```

    # Examples

    ```nix
    buildMkdocsSite {
      pname = "foodogsquared-mkdocs-project-docs";
      version = "1.0.0";
      src = lib.cleanSource ./.;

      propagatedBuildInputs = with python3Packages; [
        mkdocs-material
      ];

      meta = with lib; {
        description = "foodogsquared's homepage";
        license = licenses.gpl3Only;
      };
    }
    ```
  */
  buildMkdocsSite = pkgs.callPackage ./mkdocs/build-site.nix { };

  /**
    Builder for Antora sites.

    # Arguments

    Similar to `stdenv.mkDerivation` but with a few attributes specific for
    this builder function:

    buildDir
    : The output directory used in the build phase of the package.
    By default, it is set to `build/site`.

    vendorHash
    : An optional string containing an SRI hash of the `package.json` of the
    source root. If this attribute is set, the builder includes NodeJS
    toolchain.

    npmRoot
    : The root directory where `package.json` is located. This attribute is
    only used when `vendorHash` is a non-null value.

    # Examples

    ```nix
    buildAntoraSite {
      pname = "fds-nix-module-wrapper-manager-docs-site";

      src = lib.cleanSource ./.;

      vendorHash = "";
    }
    ```
  */
  buildAntoraSite = pkgs.callPackage ./antora/build-site.nix { foodogsquaredLib = self; };

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
    A builder for creating a dconf configuration file.

    # Arguments

    Similar to `stdenv.mkDerivation` but with a few attributes specific for
    this builder function:

    settings
    : The dconf INI value as an attribute set to be passed onto
    `lib.generators.toDconfINI`.

    name
    : The name of the dconf file.

    # Type

    ```
    buildDconfConf :: Attrs -> Derivation
    ```

    # Example

    ```nix
    buildDconfConf (finalAttrs: {
      settings = {
        "org/gnome/wm/preferences".num-workspaces = lib.gvariant.mkInt32 6;
      };
    })
    ```
  */
  buildDconfConf = pkgs.callPackage ./dconf/build-conf.nix { };

  /**
    A builder for creating dconf databases.

    # Arguments

    Similar to `stdenv.mkDerivation` but with a few attributes specific for
    this builder function:

    paths
    : A list of directories containing the keyfiles.

    # Type

    ```
    buildDconfDb :: Attr -> Derivation
    ```

    # Examples

    ```nix
    buildDconfDb {
      paths = [
        ./config/dconf
      ];
      pname = "custom-gnome-dconf-db";
    }
    ```
  */
  buildDconfDb = pkgs.callPackage ./dconf/build-db.nix { };

  /**
    Builder function for creating dconf profile.

    # Arguments

    Similar to `stdenv.mkDerivation` but with a few attributes specific for
    this builder function:

    profile
    : A list of profile for dconf to consult as with its inputs documented from
    {manpage}`dconf(7)`.

    enableLocalUserProfile
    : Convenience parameter for setting user database as the first dconf
    database in the profile list. By default, it is set to `false`.

    # Examples

    ```nix
    buildDconfProfile {
      enableLocalUserProfile = true;
      profile = [
        "system-db:local"
        "system-db:site"
        "file-db:${buildDconfDb { ... }}"
      ];
    }
    ```
  */
  buildDconfProfile = pkgs.callPackage ./dconf/build-profile.nix { };

  /**
    Builder for creating a package containing dconf keyfiles and a dconf
    profile given a name. The output is typically composed as part of an
    environment (e.g., `programs.dconf.packages` in NixOS).

    ::: {.note}
    This doesn't build any dconf databases. That is where `buildDconfDb` comes
    in.
    :::

    # Arguments

    Similar to `stdenv.mkDerivation` but with a few attributes specific for
    this builder function:

    name
    : The name of the dconf profile.

    keyfiles
    : A list of directories containing the keyfiles to be exported at
    `$out/etc/dconf/db/$NAME.d`.

    profile
    : A list of configuration database for dconf to look into. This will be
    exported at `$out/etc/dconf/profile/$NAME`.

    enableLocalUserProfile
    : Enable setting `user-db:user` as the first item in the dconf profile.
    By default, this is set to `false`. This is only meant for convenience for
    building a profile list and can screw up the profile list if improperly
    used.

    enableSystemUserProfile
    : Enable setting `system-db:$NAME` as the second item in the dconf profile.
    By default, this is set to `false`. This is only meant for convenience for
    building a profile list and can screw up the profile list order if
    improperly used.

    # Examples

    ```nix
    buildDconfPackage {
      name = "one.foodogsquared.AHappyGNOME";
      keyfiles = [
        ./config/dconf
        ../../workflows/extended-gnome-config/config/dconf
      ];
      enableLocalUserProfile = true;
      enableSystemUserProfile = true;
      profile = [
        "system-db:local"
      ];
    }
    ```
  */
  buildDconfPackage = pkgs.callPackage ./dconf/build-package.nix { };

  /**
    A wrapper for building Docker images.

    # Arguments

    A sole attribute set with the following attributes:

    name
    : Name of the container.

    contents
    : The contents of the FDS environment to be built with.

    pathsToLink
    : A list of directories to be shared with all of the derivations listed
    from `contents`.

    enableTypicalSetup
    : Enable typical configuration.

    The rest of the attributes are considered as part of the
    `dockerTools.buildImage` argument.

    # Type

    ```
    buildDockerImage :: Attr -> Derivation
    ```

    # Example

    ```nix
    buildDockerImage {
      name = "typical-webdev";
      contents = with pkgs; [
        hello
        ruby
        npm
        pnpm
      ];
      enableTypicalSetup = true;
    }
    ```
  */
  buildDockerImage = pkgs.callPackage ./build-docker-image.nix { foodogsquaredLib = self; };
}
