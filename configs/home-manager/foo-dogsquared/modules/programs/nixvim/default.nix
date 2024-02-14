# Take note, this already assumes we're using on top of an already existing
# NixVim configuration. See the declarative users configuration for more
# details.
{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.nixvim;
  hmCfg = config;
in
{
  options.users.foo-dogsquared.programs.nixvim.enable =
    lib.mkEnableOption "NixVim setup";

  config = lib.mkIf cfg.enable {
    programs.nixvim = { ... }: {
      imports =
        [
          ./colorschemes.nix
          ./misc.nix
          ./note-taking.nix
        ]
        ++ lib.optionals userCfg.setups.development.enable [
          ./dev.nix
          ./lsp.nix
          ./dap.nix
        ];
      config = {
        enable = true;

        # Inherit all of the schemes.
        inherit (hmCfg) tinted-theming;
      };
    };
  };
}
