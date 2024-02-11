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
          ./note-taking.nix
        ]
        ++ lib.optionals userCfg.setups.development.enable [
          ./lsp.nix
          ./dap.nix
        ];
      config = {
        enable = true;
        inherit (hmCfg) tinted-theming;
      };
    };
  };
}
