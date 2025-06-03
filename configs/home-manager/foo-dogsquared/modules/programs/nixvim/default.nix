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
  nvimPkg = createNixvimFlavor ({ config, ... }: {
    imports = [
      ./colorschemes.nix
      ./fuzzy-finding.nix
      ./misc.nix
      ./note-taking.nix
      ./dev.nix
      ./lsp.nix
      ./dap.nix
      ./qol.nix
    ];

    config = {
      nixvimConfigs.fiesta-fds.setups = {
        colorschemes.enable = true;
        fuzzy-finding.enable = true;
        note-taking.enable = true;
        qol.enable = true;
        misc.enable = true;
        dev.enable = userCfg.setups.development.enable;
        lsp.enable = userCfg.setups.development.enable;
        dap.enable = userCfg.setups.development.enable;
      };

      # Inherit all of the schemes.
      bahaghari.tinted-theming.schemes =
        hmCfg.bahaghari.tinted-theming.schemes;

      # Install ALL OF THEM tree-sitter grammers instead.
      plugins.treesitter.grammarPackages =
        lib.mkForce config.plugins.treesitter.package.passthru.allGrammars;
    };
  });

  nixvimManpage = pkgs.runCommand "get-main-nixvim-manpage" { } ''
    mkdir -p $out/share && cp -r "${nvimPkg}/share/man" $out/share
  '';
in {
  options.users.foo-dogsquared.programs.nixvim.enable =
    lib.mkEnableOption "editors made with NixVim";

  config = lib.mkIf cfg.enable {
    home.packages = [ nixvimManpage ];

    # Basically, we're creating Neovim flavors with NixVim so no need for it.
    wrapper-manager.packages.neovim-flavors = { config, ... }: {
      wrappers.nvim-fiesta-fds = {
        arg0 = lib.getExe' nvimPkg "nvim";
        xdg.desktopEntry = {
          enable = true;
          settings = {
            desktopName = "Neovim (nvim-fiesta-fds)";
            tryExec = config.wrappers.nvim-fiesta-fds.executableName;
            exec = lib.mkForce "${config.wrappers.nvim-fiesta-fds.executableName} %F";
            terminal = true;
            categories = [ "Utility" "TextEditor" ];
            icon = "nvim";
            comment = "Edit text files with nvim-fiesta-fds configuration";
            genericName = "Text Editor";
            mimeTypes = [ "text/plain" ];
          };
        };
      };
    };
  };
}
