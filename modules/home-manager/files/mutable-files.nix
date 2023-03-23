{ config, options, lib, pkgs, ... }:

let
  cfg = config.home.mutableFile;

  fileType = baseDir: { name, config, options, ... }: {
    options = {
      url = lib.mkOption {
        type = lib.types.str;
        description = lib.mkDoc ''
          The URL of the file to be fetched.
        '';
        example = "https://github.com/foo-dogsquared/dotfiles.git";
      };

      path = lib.mkOption {
        type = lib.types.str;
        description = lib.mkDoc ''
          The path of the mutable file. By default, it will be relative to the
          home directory.
        '';
        example = lib.literalExpression "\${config.xdg.userDirs.documents}/top-secret";
        default = name;
        apply = p:
          if lib.hasPrefix "/" p then p else "${baseDir}/${p}";
      };

      extractPath = lib.mkOption {
        type = with lib.types; nullOr str;
        description = lib.mkDoc ''
          The path within the archive to be extracted. This is only used if the
          type is `archive`. If the value is `null` then it will extract the
          whole archive into the directory.
        '';
        default = null;
        example = "path/inside/of/the/archive";
      };

      type = lib.mkOption {
        type = lib.types.enum [ "git" "fetch" "archive" ];
        description = lib.mkDoc ''
          Type that configures the behavior for fetching the URL.

          This accept only certain keywords.

          - For `fetch`, the file will be fetched with `curl`.
          - For `git`, it will be fetched with `git clone`.
          - For `archive`, the file will be fetched with `curl` and extracted
          before putting the file.

          The default type is `fetch`.
        '';
        default = "fetch";
        example = "git";
      };

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = lib.mkDoc ''
          A list of extra arguments to be included with the fetch command. Take
          note of the commands used for each type as documented from
          `config.home.mutableFile.<name>.type`.
        '';
        default = [];
        example = [ "--depth" "1" ];
      };
    };
  };
in
{
  options.home.mutableFile = lib.mkOption {
    type = with lib.types; attrsOf (submodule (fileType config.home.homeDirectory));
    description = lib.mkDoc ''
      An attribute set of mutable files and directories to be declaratively put
      into the home directory. Take note this is not exactly pure (or
      idempotent) as it will only do its fetching when the designated file is
      missing.
    '';
    default = { };
    example = lib.literalExpression ''
      {
        "library/dotfiles" = {
          url = "https://github.com/foo-dogsquared/dotfiles.git";
          type = "git";
        };

        "library/projects/keys" = {
          url = "https://example.com/file.zip";
          type = "archive";
        };
      }
    '';
  };

  config = lib.mkIf (cfg != { }) {
    systemd.user.services.fetch-mutable-files = {
      Unit = {
        Description = "Fetch mutable home-manager-managed files";
        After = [ "default.target" "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        # We'll assume this service will have lots of things to download so it
        # is best to make the temp directory to only last with the service.
        PrivateUsers = true;
        PrivateTmp = true;

        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart =
          let
            mutableFilesCmds = lib.mapAttrsToList
              (path: value:
                let
                  url = lib.escapeShellArg value.url;
                  path = lib.escapeShellArg value.path;
                  extraArgs = lib.escapeShellArgs value.extraArgs;
                in
                ''
                  ${lib.optionalString (value.type == "git") "[ -d ${path} ] || git clone ${extraArgs} ${url} ${path}"}
                  ${lib.optionalString (value.type == "fetch") "[ -e ${path} ] || curl ${extraArgs} ${url} --output ${path}"}
                  ${lib.optionalString (value.type == "archive") ''
                    [ -e ${path} ] || {
                      filename=$(curl ${extraArgs} --output-dir /tmp --silent --show-error --write-out '%{filename_effective}' --remote-name --remote-header-name --location ${url})
                      ${if (value.extractPath != null) then
                          ''arc extract "/tmp/$filename" ${lib.escapeShellArg value.extractPath} ${path}''
                        else
                          ''arc unarchive "/tmp/$filename" ${path}''
                      }
                    }
                  ''}
                '')
              cfg;

            script = pkgs.writeShellScript "fetch-mutable-files" ''
              ${lib.concatStringsSep "\n" mutableFilesCmds}
            '';
          in builtins.toString script;
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
