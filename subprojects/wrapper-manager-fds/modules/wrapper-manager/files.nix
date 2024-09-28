{ config, lib, pkgs, ... }:

let
  cfg = config.files;

  filesModule = { name, lib, config, options, ... }: {
    options = {
      target = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = ''
          Path of the file relative to the derivation output path.
        '';
        default = name;
        example = "share/applications/org.example.App1.desktop";
      };

      source = lib.mkOption {
        type = lib.types.path;
        description = "Path of the file to be linked.";
      };

      text = lib.mkOption {
        type = with lib.types; nullOr lines;
        description = ''
          Text content of the given filesystem path.
        '';
        default = null;
        example = ''
          key=value
          hello=world
        '';
      };

      mode = lib.mkOption {
        type = lib.types.strMatching "[0-7]{0,4}";
        default = "0644";
        example = "0600";
        description = ''
          Permissions to be given to the file. By default, it is given with a
          symlink.
        '';
      };
    };

    config = {
      source = lib.mkIf (config.text != null) (
        let
          name' = "wrapper-manager-filesystem-${lib.replaceStrings ["/"] ["-"] name}";
        in lib.modules.mkDerivedConfig options.text (pkgs.writeText name')
      );
    };
  };
in
{
  options.files = lib.mkOption {
    type = with lib.types; attrsOf (submodule filesModule);
    description = ''
      Extra set of files to be exported within the derivation.

      ::: {.caution}
      Be careful when placing executables in `$out/bin` as it is handled by
      wrapper-manager build step. Any files in `$out/bin` that have a
      configured wrapper will be overwritten since building the wrapper comes
      after installing the files.
      :::
    '';
    default = { };
    example = lib.literalExpression ''
      {
        "share/example-app/docs".source = ./docs;
        "etc/xdg".source = ./config;

        "share/example-app/example-config".text = ''''
          hello=world
          location=INSIDE OF YOUR WALLS
        '''';
      }
    '';
  };

  config = lib.mkIf (cfg != { }) {
    build.extraSetup = let
      installFiles = acc: n: v: let
        source = lib.escapeShellArg v.source;
        target = lib.escapeShellArg v.target;
        target' = "$out/${target}";
        installFile = let
          type = lib.filesystem.pathType v.source;
          in
          if type == "directory" then ''
            mkdir -p $(basename ${target'}) && cp --recursive ${source} ${target'}
          '' else if type == "symlink" then ''
            ln --symbolic --force ${source} ${target'}
          '' else ''
            install -D --mode=${v.mode} ${source} ${target'}
          '';
      in ''
        ${acc}
        ${installFile}
      '';
    in lib.mkBefore ''
      ${lib.foldlAttrs installFiles "" cfg}
    '';
  };
}
