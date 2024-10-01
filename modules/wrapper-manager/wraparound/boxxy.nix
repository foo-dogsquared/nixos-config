{ lib, pkgs, config, ... }:

let
  cfg = config.wraparound.boxxy;

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

    # TODO: Perhaps, consider creating a PR to upstream repo to pass a config file?
    # Boxxy doesn't have a way to pass a custom configuration file so we're
    # settling with this. Besides, Boxxy-launched programs can inherit the
    # environment anyways so a custom config file is not needed for now.
    rules = lib.mkOption {
      type = with lib.types; attrsOf (submodule boxxyRuleModule);
      default = { };
      description = if isGlobal then ''
        Global set of rules to be applied per-wrapper.
      '' else ''
        Set of rules to be applied to the wrapper.
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
      description = if isGlobal then ''
        Global list of arguments to be appended to each Boxxy-enabled wrappers.
      '' else ''
        List of arguments to the {command}`boxxy` executable.
      '';
      default = [ ];
      example = [ "--immutable" "--daemon" ];
    };
  };
in
{
  options.wraparound.boxxy = boxxyModuleFactory { isGlobal = true; };

  options.wrappers =
    let
      boxxySandboxModule = { name, lib, config, pkgs, ... }:
        let
          submoduleCfg = config.wraparound.boxxy;
        in
        {
          options.wraparound.variant = lib.mkOption {
            type = with lib.types; nullOr (enum [ "boxxy" ]);
          };

          options.wraparound.boxxy = boxxyModuleFactory { isGlobal = false; };

          config = lib.mkIf (config.wraparound.variant == "boxxy") {
            wraparound.boxxy.rules = cfg.rules;

            wraparound.boxxy.extraArgs =
              cfg.extraArgs
              ++ (lib.mapAttrsToList
                (_: metadata:
                  let
                    inherit (metadata) source destination mode;
                    ruleArg =
                      if mode != null
                        then "${source}:${destination}:${mode}"
                        else "${source}:${destination}";
                  in
                  "--rule ${ruleArg}")
                submoduleCfg.rules);

            arg0 = lib.getExe' submoduleCfg.package "boxxy";
            prependArgs = lib.mkBefore
              (submoduleCfg.extraArgs
                ++ [ "--" config.wraparound.subwrapper.arg0 ]
                ++ config.wraparound.subwrapper.extraArgs);
          };
        };
    in
    lib.mkOption {
      type = with lib.types; attrsOf (submodule boxxySandboxModule);
    };
}
