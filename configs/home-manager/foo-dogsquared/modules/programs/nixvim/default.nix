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

  # The main NixVim flavor and also where the extra files in the environment
  # will come from.
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

  nixvimManpage = pkgs.runCommand "get-main-nixvim-manpage" { } ''
    mkdir -p $out/share && cp -r "${nvimPkg}/share/man" $out/share
  '';
in {
  options.users.foo-dogsquared.programs.nixvim.enable =
    lib.mkEnableOption "editors made with NixVim";

  config = lib.mkIf cfg.enable {
    home.packages = [ nixvimManpage ];

    # Basically, we're creating Neovim flavors with NixVim so no need for it.
    wrapper-manager.packages.neovim-flavors = {
      wrappers.nvim-fiesta-fds.arg0 = lib.getExe' nvimPkg "nvim";
    };
  };
}
