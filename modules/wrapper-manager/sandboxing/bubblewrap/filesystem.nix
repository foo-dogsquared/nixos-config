# Essentially a poor man's version of NixOS filesystem module except that is
# made for Bubblewrap environment. Everything here should only make use of
# Bubblewrap's filesystem options from the command-line application.
{ config, lib, pkgs, ... }:

let
  cfg = config.sandboxing.bubblewrap;

  fileOperationsWithPerms = [
    "file" "dir"
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
          type = lib.types.path;
          description = ''
            The source of the path to be copied from.
          '';
          example = lib.literalExpression "./files/example.file";
        };

        permissions = lib.mkOption {
          type = with lib.types; nullOr (strMatch "[0-7]{0,4}");
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
            from {option}`sandboxing.bubblewrap.filesystem.<name>.permissions`.
          '';
          default = "ro-bind-try";
          example = "bind";
        };

        lock = lib.mkEnableOption "locking the file";
      };
    };
  in {
    enableSharedNixStore = lib.mkEnableOption null // {
      default = if isGlobal then false else cfg.enableSharedNixStore;
      description = ''
        Whether to share the entire Nix store directory.

        ::: {.caution}
        Typically, this is not recommended especially for Bubblewrap
        environments. If you want to bind some of the items from the Nix store,
        it is recommended to use {option}`sharedNixPaths` instead.
        :::
      '';
    };

    sharedNixPaths = lib.mkOption {
      type = with lib.types; listOf package;
      default = if isGlobal then [ ] else cfg.sharedNixPaths;
      description = ''
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
        type = with lib.types; listOf path;
        default = if isGlobal then [ ] else cfg.binds.ro;
        description =
          if isGlobal
          then ''
            Global list of read-only mounts to be given to all Bubblewrap-enabled
            wrappers.
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
        type = with lib.types; listOf path;
        default = if isGlobal then [ ] else cfg.binds.rw;
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
        type = with lib.types; listOf path;
        default = if isGlobal then [ ] else cfg.binds.dev;
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
      default = if isGlobal then { } else cfg.filesystem;
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
  getClosurePaths = rootpaths:
    let
      sharedNixPathsClosureInfo = pkgs.closureInfo { inherit rootpaths; };
      closurePaths = lib.readFile "${sharedNixPathsClosureInfo}/store-paths";
    in
      lib.lists.filter (p: p != "") (lib.splitStrings "\n" closurePaths);
in
{
  options.sandboxing.bubblewrap = bubblewrapModuleFactory { isGlobal = true; };
  config.sandboxing.bubblewrap.binds.ro = getClosurePaths cfg.sharedNixPaths;

  config.sandboxing.bubblewrap.filesystem =
    let
      makeFilesystemMapping = operation: bind:
        lib.nameValuePair bind { inherit operation; source = bind; };
      filesystemMappings =
        lib.lists.map (makeFilesystemMapping "ro-bind-try") cfg.binds.ro
        ++ lib.lists.map (makeFilesystemMapping "bind") cfg.binds.rw
        ++ lib.lists.map (makeFilesystemMapping "dev-bind-try") cfg.binds.dev;
    in
    builtins.listToAttrs filesystemMappings;

  options.wrappers =
    let
      bubblewrapModule = { config, lib, name, ... }: let
        submoduleCfg = config.sandboxing.bubblewrap;
      in {
        options.sandboxing.bubblewrap = bubblewrapModuleFactory { isGlobal = false; };

        config = lib.mkIf (config.sandboxing.variant == "bubblewrap") (lib.mkMerge [
          {
            sandboxing.bubblewrap.binds.ro = getClosurePaths submoduleCfg.sharedNixPaths;

            sandboxing.bubblewrap.filesystem =
              let
                makeFilesystemMapping = operation: bind:
                  lib.nameValuePair bind { inherit operation; source = bind; };
                filesystemMappings =
                  lib.lists.map (makeFilesystemMapping "ro-bind-try") submoduleCfg.binds.ro
                  ++ lib.lists.map (makeFilesystemMapping "bind") submoduleCfg.binds.rw
                  ++ lib.lists.map (makeFilesystemMapping "dev-bind-try") submoduleCfg.binds.dev;
              in
              builtins.listToAttrs filesystemMappings;

            sandboxing.bubblewrap.extraArgs =
              let
                makeFilesystemArgs = dst: metadata:
                  let
                    src = metadata.source;
                    hasPermissions = metadata.permissions != null;
                    isValidOperationWithPerms = lib.elem metadata.operation fileOperationsWithPerms;
                  in
                  lib.optionals (hasPermissions && isValidOperationWithPerms) [ "--perms ${metadata.permissions}" ]
                  ++ (
                    if metadata.operation == "dir"
                    then [ "--${metadata.operation} ${dst}" ]
                    else [ "--${metadata.operation} ${src} ${dst}" ]
                  )
                  ++ lib.optionals metadata.lock [ "--lock-file ${dst}" ];
              in
              lib.lists.flatten
                (lib.mapAttrsToList makeFilesystemArgs submoduleCfg.filesystem);
            }

            (lib.mkIf submoduleCfg.enableSharedNixStore {
              sandboxing.bubblewrap.binds.ro = [ builtins.storeDir ] ++ lib.optionals (builtins.storeDir != "/nix/store") [ "/nix/store" ];
            })
        ]);
      };
    in
      lib.mkOption {
        type = with lib.types; attrsOf (submodule bubblewrapModule);
      };
}
