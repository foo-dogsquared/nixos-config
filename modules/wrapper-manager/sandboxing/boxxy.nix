{ lib, pkgs, config, ... }:

let
  cfg = config.sandboxing.boxxy;

  boxxyRuleModule = { name, lib, ... }: {
    options = {
      source = lib.mkOption {
        type = lib.types.str;
        description = ''
          The path of the file to be remounted.
        '';
        example = "~/.tmux.conf";
      };

      destination = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = ''
          The path where the source will be remounted to.
        '';
        example = "~/.config/tmux/tmux.conf";
      };

      mode = lib.mkOption {
        type = with lib.types; nullOr (enum [ "file" "dir" ]);
        description = ''
          Mode indicating the behavior for remounting.
        '';
        default = null;
        example = "dir";
      };
    };
  };

  boxxyModuleFactory = { isGlobal ? false }: {
    package = lib.mkPackageOption pkgs "boxxy" { } // lib.optionalAttrs (!isGlobal) {
      default = cfg.package;
    };

    rules = lib.mkOption {
      type = with lib.types; attrsOf (submodule boxxyRuleModule);
      default = if isGlobal then { } else cfg.rules;
      description = ''
        Global set of rules to be applied per-wrapper.
      '';
      example = lib.literalExpression ''
        {
          "~/.config/tmux/tmux.conf".source = "~/.tmux.conf";
          "~/.config/bash/bashrc".source = "~/.bashrc";
          "~/.config/vscode" = {
            source = "~/.vscode";
            mode = "dir";
          };
        }
      '';
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        List of arguments to the {program}`boxxy` executable.
      '';
      default = if isGlobal then [ ] else cfg.extraArgs;
      example = [ "--immutable" "--daemon" ];
    };
  };
in
{
  options.sandboxing.boxxy = boxxyModuleFactory { isGlobal = true; };

  options.wrappers =
    let
      boxxySandboxModule = { name, lib, config, pkgs, ... }:
        let
          submoduleCfg = config.sandboxing.boxxy;
        in
        {
          options.sandboxing.variant = lib.mkOption {
            type = with lib.types; nullOr (enum [ "boxxy" ]);
          };

          options.sandboxing.boxxy = boxxyModuleFactory { isGlobal = false; };

          config = lib.mkIf (config.sandboxing.variant == "boxxy") {
            sandboxing.boxxy.extraArgs =
              lib.mapAttrsToList
                (_: metadata:
                  let
                    inherit (metadata) source destination mode;
                  in
                  if mode != null
                  then "--rule ${source}:${destination}:${mode}"
                  else "--rule ${source}:${destination}")
                submoduleCfg.rules;

            arg0 = lib.getExe submoduleCfg.package;
            prependArgs = lib.mkBefore
              (submoduleCfg.extraArgs
                ++ [ "--" config.sandboxing.wraparound.executable ]
                ++ config.sandboxing.wraparound.extraArgs);
          };
        };
    in
    lib.mkOption {
      type = with lib.types; attrsOf (submodule boxxySandboxModule);
    };
}
