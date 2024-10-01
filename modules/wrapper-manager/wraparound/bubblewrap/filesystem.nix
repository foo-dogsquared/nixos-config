# Essentially a poor man's version of NixOS filesystem module except that is
# made for Bubblewrap environment. Everything here should only make use of
# Bubblewrap's filesystem options from the command-line application.
{ config, lib, pkgs, ... }:

let
  cfg = config.wraparound.bubblewrap;

  fileOperationsWithPerms = [
    "file" "dir" "remount-ro"
    "bind-data" "ro-bind-data"
  ];
  fileOperationsWithoutPerms = [
    "symlink"
    "bind" "bind-try"
    "dev-bind" "dev-bind-try"
    "ro-bind" "ro-bind-try"
  ];

  bubblewrapModuleFactory = { isGlobal ? false }: let
    filesystemSubmodule = { config, lib, name, ... }: {
      options = {
        source = lib.mkOption {
          type = lib.types.str;
          description = ''
            The source of the path to be copied from.
          '';
          example = lib.literalExpression "./files/example.file";
        };

        destination = lib.mkOption {
          type = lib.types.str;
          description = ''
            The source of the path to be copied from.
          '';
          default = name;
          example = lib.literalExpression "./files/example.file";
        };

        permissions = lib.mkOption {
          type = with lib.types; nullOr (strMatching "[0-7]{0,4}");
          description = ''
            The permissions of the node in octal. If the value is `null`, it
            will be handled by Bubblewrap executable. For more details for each
            operation, see {manpage}`bwrap(1)`.
          '';
          default = null;
          example = "0755";
        };

        operation = lib.mkOption {
          type = lib.types.enum (fileOperationsWithPerms ++ fileOperationsWithoutPerms);
          description = ''
            Specify what filesystem-related operations to be done for the given
            filesystem object. Only certain operations accept permissions given
            from {option}`wraparound.bubblewrap.filesystem.<name>.permissions`.
          '';
          default = "ro-bind-try";
          example = "bind";
        };

        lock = lib.mkEnableOption "locking the file";
      };
    };

    bindsType = with lib.types; listOf (oneOf [ str package ]);
  in {
    enableSharedNixStore = lib.mkEnableOption null // {
      default = if isGlobal then true else cfg.enableSharedNixStore;
      description = ''
        Whether to share the entire Nix store directory.
      '';
    };

    sharedNixPaths = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = if isGlobal then ''
        A global list of store paths (including its dependencies) to be shared
        per-Bubblewrap-enabled-wrappers.
      '' else ''
        A list of store paths to be mounted (as read-only bind-mounts). Note
        that this also includes the listed store objects' dependencies.
      '';
      example = lib.literalExpression ''
        with pkgs; [
          gtk3
        ]
      '';
    };

    binds = {
      ro = lib.mkOption {
        type = bindsType;
        default = [ ];
        description =
          if isGlobal
          then ''
            Global list of read-only mounts to be given to all
            Bubblewrap-enabled wrappers.
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
        type = bindsType;
        default = [ ];
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
        type = bindsType;
        default = [ ];
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

    filesystem = lib.mkOption {
      type = with lib.types; attrsOf (submodule filesystemSubmodule);
      description =
        if isGlobal then ''
          Set of filesystem configurations to be copied to per-wrapper.
        '' else ''
          Set of wrapper-specific filesystem configurations in the Bubblewrap
          environment.
        '';
      default = { };
      example = lib.literalExpression ''
        {
          "/etc/hello" = {
            source = ./files/hello;
            permissions = "0700";
            operation = "file";
          };

          "/etc/xdg" = {
            permissions = "0700";
            operation = "dir";
          };

          "/srv/data" = {
            source = "/srv/data";
            operation = "symlink";
          };

          "/srv/logs".operation = "dir";
        }
      '';
    };
  };

  # TODO: There has to be a better way to get this info without relying on
  # pkgs.closureInfo builder, right?
  getClosurePaths = rootPaths:
    let
      sharedNixPathsClosureInfo = pkgs.closureInfo { inherit rootPaths; };
      closurePaths = lib.readFile "${sharedNixPathsClosureInfo}/store-paths";
    in
      lib.lists.filter (p: p != "") (lib.splitString "\n" closurePaths);
in
{
  options.wraparound.bubblewrap = bubblewrapModuleFactory { isGlobal = true; };

  options.wrappers =
    let
      bubblewrapModule = { config, lib, name, ... }: let
        submoduleCfg = config.wraparound.bubblewrap;
      in {
        options.wraparound.bubblewrap = bubblewrapModuleFactory { isGlobal = false; };

        config = lib.mkIf (config.wraparound.variant == "bubblewrap") (lib.mkMerge [
          {
            wraparound.bubblewrap.binds = cfg.binds;
            wraparound.bubblewrap.sharedNixPaths = cfg.sharedNixPaths;
            wraparound.bubblewrap.filesystem = cfg.filesystem;
          }

          {
            wraparound.bubblewrap.filesystem =
              let
                renameNixStorePaths = path:
                  if lib.isDerivation path then path.pname else path;
                makeFilesystemMapping = operation: bind:
                  lib.nameValuePair (renameNixStorePaths bind) {
                    inherit operation;
                    source = builtins.toString bind;
                    destination = builtins.toString bind;
                  };
                filesystemMappings =
                  lib.lists.map (makeFilesystemMapping "ro-bind-try") submoduleCfg.binds.ro
                  ++ lib.lists.map (makeFilesystemMapping "bind-try") submoduleCfg.binds.rw
                  ++ lib.lists.map (makeFilesystemMapping "dev-bind-try") submoduleCfg.binds.dev;
              in
              builtins.listToAttrs filesystemMappings;

            wraparound.bubblewrap.extraArgs =
              let
                makeFilesystemArgs = _: metadata:
                  let
                    src = metadata.source;
                    dst = metadata.destination;
                    hasPermissions = metadata.permissions != null;
                    isValidOperationWithPerms = lib.elem metadata.operation fileOperationsWithPerms;
                  in
                  # Take note of the ordering here such as `--perms` requiring
                    # to be before the file operation flags.
                  lib.optionals (hasPermissions && isValidOperationWithPerms) [ "--perms ${metadata.permissions}" ]
                  ++ (
                    if lib.elem metadata.operation [ "dir" "remount-ro" ]
                    then [ "--${metadata.operation} ${dst}" ]
                    else [ "--${metadata.operation} ${src} ${dst}" ]
                  )
                  ++ lib.optionals metadata.lock [ "--lock-file ${dst}" ];
              in
                lib.lists.flatten (lib.mapAttrsToList makeFilesystemArgs submoduleCfg.filesystem);
          }

          (lib.mkIf submoduleCfg.enableSharedNixStore {
            wraparound.bubblewrap.binds.ro = [ builtins.storeDir ] ++ lib.optionals (builtins.storeDir != "/nix/store") [ "/nix/store" ];
          })

          (lib.mkIf (submoduleCfg.sharedNixPaths != [ ]) {
            wraparound.bubblewrap.extraArgs =
              let
                closurePaths = getClosurePaths submoduleCfg.sharedNixPaths;
              in
                builtins.map (p: "--ro-bind ${p} ${p}") closurePaths;
          })

          (lib.mkIf submoduleCfg.dbus.enable {
            wraparound.bubblewrap.dbus.filter.bwrapArgs =
              let
                closurePaths = getClosurePaths submoduleCfg.sharedNixPaths;
              in
                builtins.map (p: "--ro-bind ${p} ${p}") closurePaths;
          })
        ]);
      };
    in
      lib.mkOption {
        type = with lib.types; attrsOf (submodule bubblewrapModule);
      };
}
