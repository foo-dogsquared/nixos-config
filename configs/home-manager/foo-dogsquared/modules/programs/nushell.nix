{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.nushell;

  nushellAutoloadScriptDir = "${config.xdg.dataHome}/nushell/vendor/autoload";
in {
  options.users.foo-dogsquared.programs.nushell.enable =
    lib.mkEnableOption "Nushell setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.nushell = {
        enable = true;
        plugins = with pkgs.nushellPlugins; [
          query
          polars
          formats
        ];
        extraConfig = ''
          $env.config = $env.config | merge deep --strategy=append {
            show_banner: false

            shell_integration: {
              osc7: true
              osc133: true
              osc633: true
            }
          }
        '';
        environmentVariables.NU_LIB_DIRS = lib.concatStringsSep ":" [
          "${config.xdg.cacheHome}/nushell/modules"
          "${config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR}/nushell"
        ];
        environmentVariables.NIX_PATH = config.nix.nixPath;
      };
    }

    # Configuring our own completion thingy instead.
    # Based from https://www.nushell.sh/cookbook/external_completers.html#multiple-completer.
    (lib.mkIf config.programs.carapace.enable {
      programs.carapace.enableNushellIntegration = lib.mkForce false;

      programs.nushell.extraConfig = lib.mkMerge [
        (lib.mkIf config.programs.zoxide.enable ''
          let zoxide_completer = {|spans|
              $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
          }
        '')

        (lib.mkAfter ''
          let carapace_completer = {|spans: list<string>|
            carapace $spans.0 nushell ...$spans
            | from json
            | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
          }

          let external_completers = {|spans|
            let expanded_alias = scope aliases
              | where name == $spans.0
              | get -i 0.expansion

            let spans = if $expanded_alias != null {
              $spans
              | skip 1
              | prepend ($expanded_alias | split row ' ' | take 1)
            } else {
              $spans
            }

            match $spans.0 {
              ${
                lib.optionalString config.programs.zoxide.enable ''
                  __zoxide_z | __zoxide_zi => $zoxide_completer
                ''
              }
              _ => $carapace_completer
            } | do $in $spans
          }

          $env.config.completions.external = $env.config.completions.external | merge deep --strategy=append {
            enable: true
            completer: $external_completers
          }
        '')
      ];
    })
  ]);
}
