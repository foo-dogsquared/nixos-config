{ config, lib, pkgs, ... }:

let
  cfg = config.home.mutableFile;

  # An attribute set to be used to get the fetching script.
  fetchScript = path: value:
    let
      url = lib.escapeShellArg value.url;
      path = lib.escapeShellArg value.path;
      extraArgs = lib.escapeShellArgs value.extraArgs;
    in
    {
      git = ''
        [ -d ${path} ] || git clone ${extraArgs} ${url} ${path}
      '';
      fetch = ''
        [ -e ${path} ] || curl ${extraArgs} ${url} --output ${path}"
      '';
      archive =
        let
          extractScript =
            if (value.extractPath == null) then
              ''arc unarchive "/tmp/$filename" ${path}''
            else
              ''arc extract "/tmp/$filename" ${lib.escapeShellArg value.extractPath} ${path}'';
        in
        ''
          [ -e ${path} ] || {
            filename=$(curl ${extraArgs} --output-dir /tmp --silent --show-error --write-out '%{filename_effective}' --remote-name --remote-header-name --location ${url})
            ${extractScript}
          }
        '';
      gopass = ''
        [ -e ${path} ] || gopass clone ${extraArgs} ${url} --path ${path} ${extraArgs}
      '';
      custom = ''
        [ -e ${path} ] || ${extraArgs}
      '';
    };

  fileType = baseDir: { name, config, options, ... }: {
    options = {
      url = lib.mkOption {
        type = lib.types.str;
        description = ''
          The URL of the file to be fetched.
        '';
        example = "https://github.com/foo-dogsquared/dotfiles.git";
      };

      path = lib.mkOption {
        type = lib.types.str;
        description = ''
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
        description = ''
          The path within the archive to be extracted. This is only used if the
          type is `archive`. If the value is `null` then it will extract the
          whole archive into the directory.
        '';
        default = null;
        example = "path/inside/of/the/archive";
      };

      type = lib.mkOption {
        type = lib.types.enum [ "git" "fetch" "archive" "gopass" "custom" ];
        description = ''
          Type that configures the behavior for fetching the URL.

          This accept only certain keywords.

          - For `fetch`, the file will be fetched with {command}`curl`.
          - For `git`, it will be fetched with {command}`git clone`.
          - For `archive`, the file will be fetched with {command}`curl` and
          extracted before putting the file.
          - For `gopass`, the file will be cloned with {command}`gopass`.
          - For `custom`, the file will be passed with a user-given command.
          The `extraArgs` option is now assumed to be a list of a command and
          its arguments. To make executing commands possible with custom
          scripts, the URL and the path is stored in shell variables `$url` and
          `$path` respectively.

          The default type is `fetch`.
        '';
        default = "fetch";
        example = "git";
      };

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          A list of extra arguments to be included with the fetch command. Take
          note of the commands used for each type as documented from
          {option}`config.home.mutableFile.<name>.type`.
        '';
        default = [ ];
        example = [ "--depth" "1" ];
      };

      postScript = lib.mkOption {
        type = lib.types.lines;
        description = ''
          A shell script fragment to be executed after the download.
        '';
        default = "";
        example = lib.literalExpression ''
          ''${config.xdg.configHome}/emacs/bin/doom install --no-config --no-fonts --install --force
        '';
      };
    };
  };
in
{
  options.home.mutableFile = lib.mkOption {
    type = with lib.types; attrsOf (submodule (fileType config.home.homeDirectory));
    description = ''
      An attribute set of mutable files and directories to be declaratively put
      into the home directory. Take note this is not exactly pure (or
      idempotent) as it will only do its fetching when the designated file is
      missing.
    '';
    default = { };
    example = {
      "library/dotfiles" = {
        url = "https://github.com/foo-dogsquared/dotfiles.git";
        type = "git";
      };

      "library/projects/keys" = {
        url = "https://example.com/file.zip";
        type = "archive";
      };
    };
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
              (path: value: let
                url = lib.escapeShellArg value.url;
                path = lib.escapeShellArg value.path;
              in
              ''
                (
                  URL=${url}
                  PATH=${path}
                  DIRNAME=$(dirname ${path})
                  mkdir -p "$DIRNAME"
                  ${(fetchScript path value).${value.type}}
                )
              '')
              cfg;

            script = pkgs.writeShellApplication {
              name = "fetch-mutable-files";
              runtimeInputs = with pkgs; [ archiver curl git gopass ];
              text = lib.concatStringsSep "\n" mutableFilesCmds;
            };
          in
          "${script}/bin/fetch-mutable-files";

        ExecStartPost =
          let
            mutableFilesCmds = lib.mapAttrsToList
              (path: value: value.postScript)
              cfg;

            script = pkgs.writeShellApplication {
              name = "fetch-mutable-files-post-script";
              runtimeInputs = with pkgs; [ archiver curl git gopass ];
              text = lib.concatStringsSep "\n" mutableFilesCmds;
            };
          in
          "${script}/bin/fetch-mutable-files-post-script";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
