# Essentially a poor man's version of NixOS filesystem module except that is
# made for Bubblewrap environment. Everything here should only make use of
# Bubblewrap's filesystem options from the command-line application.
{ config, lib, ... }:

let
  cfg = config.sandboxing.bubblewrap;

  bubblewrapModuleFactory = { isGlobal ? false }: let
    filesystemSubmodule = { config, lib, name, ... }: {
      options = {
        source = lib.mkOption {
          type = lib.types.path;
          description = ''
            The source of the path to be copied from.
          '';
          example = lib.literalExpression "./files/example.file";
        };

        perms = lib.mkOption {
          type = with lib.types; nullOr (strMatch "[0-7]{0,4}");
          description = ''
            The permissions of the node in octal.
          '';
          default = null;
          example = "0755";
        };

        symlink = lib.mkEnableOption "create the file as a symlink";
        createDir = lib.mkEnableOption "create the directory in the Bubblewrap environment";
        bindMount = lib.mkEnableOption "bind-mount the given source to the Bubblewrap environment";
        bindMountReadOnly = lib.mkEnableOption "bind-mount read-only the given source to the Bubblewrap environment";
      };
    };
  in {
    options.filesystem = lib.mkOption {
      type = with lib.types; attrsOf (submodule filesystemSubmodule);
      description =
        if isGlobal then ''
          Set of filesystem configurations to be copied to per-wrapper.
        '' else ''
          Set of wrapper-specific filesystem configurations in the Bubblewrap
          environment.
        '';
      default = if isGlobal then { } else cfg.filesystem;
      example = lib.literalExpression ''
        {
          "/etc/hello" = {
            source = ./files/hello;
            perms = "0700";
          };

          "/etc/xdg" = {
            source = ./configs;
            perms = "0700";
          };

          "/srv/data" = {
            source = "/srv/data";
            symlink = true;
          };

          "/srv/logs".createDir = true;
        }
      '';
    };
  };
in
{
  options.sandboxing.bubblewrap = bubblewrapModuleFactory { isGlobal = true; };

  options.wrappers =
    let
      bubblewrapModule = { config, lib, name, ... }: let
        submoduleCfg = config;
      in {
        options.sandboxing.bubblewrap = bubblewrapModuleFactory { isGlobal = false; };

        config = lib.mkIf (config.sandboxing.variant == "bubblewrap") {
          bubblewrap.extraArgs =
            lib.lists.flatten
              (lib.mapAttrsToList
                (dst: metadata:
                  lib.optionals (metadata.perms != null) [ "--perms ${metadata.perms}" ]
                  ++ (let
                    inherit (metadata) source;
                  in
                    if metadata.createDir
                    then [ "--dir ${dst}"]
                    else if metadata.symlink
                    then [ "--symlink ${source} ${dst}"]
                    else if metadata.bindMount
                    then [ "--bind-data ${source} ${dst}" ]
                    else if metadata.bindMountReadOnly
                    then [ "--ro-bind-data ${source} ${dst}" ]
                    else [ "--file ${source} ${dst}"]))
                submoduleCfg.filesystem);
        };
      };
    in
      lib.mkOption {
        type = with lib.types; attrsOf (submodule bubblewrapModule);
      };
}
