{ config, lib, options, pkgs, ... }:

let
  cfg = config.nixgl;

  nixgl = variant: src:
    let nixgl = import src { inherit pkgs; };
    in lib.getAttrFromPath variant nixgl;
in {
  options.nixgl = {
    enableAll = lib.mkEnableOption "wrapping all wrappers with NixGL";

    src = lib.mkOption {
      type = lib.types.pathInStore;
      description = ''
        The source code of NixGL to be used for all NixGL-enabled wrappers
        (unless overridden with their own).
      '';
      default = builtins.fetchGit {
        url = "https://github.com/nix-community/nixGL.git";
        ref = "main";
      };
      defaultText = ''
        The current revision of NixGL.

        ::: {.note}
        It is recommended to fetch with your own NixGL source (either from
        flakes, builtin fetchers, or however you manage your Nix dependencies).
        :::
      '';
    };

    variant = lib.mkOption {
      type = with lib.types; listOf nonEmptyStr;
      description = ''
        The variant to be used for NixGL listed as a attrpath. The default
        wrapper to be used is `auto.nixGLDefault`.
      '';
      default = [ "auto" "nixGLDefault" ];
      example = [ "nixGLIntel" ];
    };

    executable = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = lib.getExe (nixgl cfg.variant cfg.src);
      description = ''
        The path of the NixGL executable. By default, it will get
        `meta.mainProgram` of the variant from the `src` instead.
      '';
      example = lib.literalExpression ''
        let
          src = builtins.fetchGit {
            url = "https://github.com/nix-community/nixGL.git";
            ref = "main";
            rev = "310f8e49a149e4c9ea52f1adf70cdc768ec53f8a";
          };
          nixgl = import src { inherit pkgs; };
        in
          lib.getExe' nixgl.auto.nixGLDefault "nixGL"
      '';
    };
  };

  options.wrappers = let
    nixglWrapperModule = { config, lib, name, ... }:
      let submoduleCfg = config.nixgl;
      in {
        options.nixgl = {
          enable = lib.mkEnableOption "wrapping NixGL for this wrapper" // {
            default = cfg.enableAll;
          };

          src = options.nixgl.src // { default = cfg.src; };

          executable = options.nixgl.executable // {
            default = lib.getExe (nixgl config.nixgl.variant config.nixgl.src);
          };

          variant = options.nixgl.variant // { default = cfg.variant; };

          wraparound = {
            arg0 = lib.mkOption {
              type = lib.types.nonEmptyStr;
              description = ''
                The executable to be wrapped around.
              '';
              example = lib.literalExpression ''
                lib.getExe' pkgs.wezterm "wezterm"
              '';
            };

            extraArgs = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              description = ''
                List of arguments associated to the wraparound.
              '';
              example = lib.literalExpression ''
                [
                  "--config-file" ./config/wezterm/config.lua
                ]
              '';
            };
          };
        };

        config = lib.mkIf config.nixgl.enable {
          arg0 = if submoduleCfg.executable == null then
            lib.getExe (nixgl config.nixgl.variant config.nixgl.src)
          else
            submoduleCfg.executable;
          prependArgs = lib.mkBefore ([ submoduleCfg.wraparound.arg0 ]
            ++ submoduleCfg.wraparound.extraArgs);
        };
      };
  in lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule nixglWrapperModule);
  };
}
