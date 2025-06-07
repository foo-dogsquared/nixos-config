/*
  This is where all workflow-specific configuration should go (unless it's
  mainly composed of dconf settings).
*/
{ config, lib, pkgs, ... }@attrs:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.workflow-specific;
in
{
  options.users.foo-dogsquared.setups.workflow-specific.enable =
    lib.mkEnableOption "workflow-specific configuration for this user";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (lib.elem "one.foodogsquared.AHappyGNOME" attrs.nixosConfig.workflows.enable or []) (
      let
        additionalShellExtensions = with pkgs; [
          gnomeExtensions.quake-terminal
        ];
        inherit (attrs.nixosConfig.workflows) workflows;
      in {
        home.packages = additionalShellExtensions;

        dconf.settings = lib.mkMerge [
          {
            "org/gnome/shell".enabled-extensions =
              lib.map (p: p.extensionUuid) additionalShellExtensions
              ++ workflows."one.foodogsquared.AHappyGNOME".settings."org/gnome/shell".enabled-extensions or [ ];
          }

          (lib.mkIf userCfg.programs.terminal-emulator.enable {
            "org/gnome/shell/extensions/quake-terminal" = {
              terminal-id = "one.foodogsquared.WeztermDropDown.desktop";
              render-on-current-monitor = true;
              always-on-top = true;
            };
          })
        ];
      })
    )
  ]);
}
