# Take note, this already assumes we're using on top of an already existing
# NixVim configuration. See the declarative users configuration for more
# details.
{ config, lib, pkgs, firstSetupArgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.nixvim;
  hmCfg = config;

  createNixvimFlavor = module:
    pkgs.nixvim.makeNixvimWithModule {
      inherit pkgs;
      module.imports = firstSetupArgs.baseNixvimModules ++ [ module ];
      extraSpecialArgs.hmConfig = config;
    };
in {
  options.users.foo-dogsquared.programs.nixvim.enable =
    lib.mkEnableOption "NixVim setup";

  config = lib.mkIf cfg.enable {
    # Basically, we're creating Neovim flavors with NixVim so no need for it.
    #
    # Also another reason we're forcibly disabling that it is heavily assumed
    # that it is using the Neovim configuration found from the dotfiles repo.
    programs.nixvim.enable = lib.mkForce false;

    wrapper-manager.packages.neovim-flavors = {
      wrappers.nvim-fiesta.arg0 = let
        nvimPkg = createNixvimFlavor {
          imports = [
            ./colorschemes.nix
            ./fuzzy-finding.nix
            ./misc.nix
            ./note-taking.nix
          ] ++ lib.optionals userCfg.setups.development.enable [
            ./dev.nix
            ./lsp.nix
            ./dap.nix
          ];

          config = {
            # Inherit all of the schemes.
            bahaghari.tinted-theming.schemes =
              hmCfg.bahaghari.tinted-theming.schemes;
          };
        };
      in lib.getExe' nvimPkg "nvim";
    };
  };
}
