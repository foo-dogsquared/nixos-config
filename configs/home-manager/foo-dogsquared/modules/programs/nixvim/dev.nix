# NixVim config for some light software development. This is where language
# support plugins mainly reside. Also formatters.
{ config, pkgs, lib, hmConfig, ... }:

let
  inherit (config.plugins.treesitter.package) builtGrammars;
  nixvimCfg = config.nixvimConfigs.fiesta-fds;
  cfg = nixvimCfg.setups.dev;
in
{
  options.nixvimConfigs.fiesta-fds.setups.dev.enable =
    lib.mkEnableOption "development utilities integration within fiesta-fds";

  config = lib.mkIf cfg.enable {
    plugins.conjure.enable = true;

    # Confirming these files are conforming.
    plugins.conform-nvim = {
      enable = true;
      settings.formatters = rec {
        bash = [ "shfmt" ];
        c = lib.singleton [ "clang_format" ];
        cpp = c;
        javascript = lib.singleton [ "prettierd" "prettier" ];
        lua = [ "stylua" ];
        nix = lib.singleton [ "nixpkgs-fmt" "alejandra" ];
        python = [ "isort" "black" ];
        ruby = lib.singleton [ "rubocop" "rufo" ];
        typescript = javascript;
        typst = [ "typstfmt" ];
      };
    };

    plugins.gitsigns = {
      enable = true;
    };

    # Give language "support" through tree-sitter.
    plugins.treesitter.grammarPackages =
      with builtGrammars;
      [
        agda
        arduino
        astro
        awk
        blueprint
        cairo
        cmake
        commonlisp
        csv
        cue
        dart
        devicetree
        diff
        elixir
        elm
        erlang
        fennel
        fish
        gdscript
        glsl
        go
        hcl
        janet-simple
        kotlin
        make
        nickel
        nix
        perl
        ruby
        rust
        scheme
        sparql
        sql
        supercollider
        wgsl
        wgsl_bevy
        zig
      ] ++ (with pkgs.tree-sitter-grammars; [ tree-sitter-elisp tree-sitter-nu ])
      ++ lib.optionals hmConfig.programs.git.enable (with builtGrammars; [
        git_config
        git_rebase
        gitattributes
        gitcommit
        gitignore
      ]);

    extraPlugins = with pkgs.vimPlugins; [ vim-nickel vim-nix zig-vim ];
  };
}
