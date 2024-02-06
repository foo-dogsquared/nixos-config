{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.nixvim;
in
{
  options.users.foo-dogsquared.programs.nixvim.enable =
    lib.mkEnableOption "NixVim setup";

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      imports =
        [
          ./note-taking.nix
        ]
        ++ lib.optionals userCfg.setups.development.enable [
          ./lsp.nix
          ./dap.nix
        ];
    };
  };
}
