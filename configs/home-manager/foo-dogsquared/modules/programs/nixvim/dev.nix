# NixVim config for some light software development. This is where language
# support plugins mainly reside. Also formatters.
{ config, pkgs, lib, ... }:

{
  # Confirming these files are conforming.
  plugins.conform-nvim = {
    enable = true;
    formatters = rec {
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

  # Give language "support" through tree-sitter.
  plugins.treesitter.grammarPackages =
    with config.plugins.treesitter.package.builtGrammars; [
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
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore
      gdscript
      glsl
      go
      hcl
      janet-simple
      kotlin
      make
      nickel
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
    ]
    ++ (with pkgs.tree-sitter-grammars; [
      tree-sitter-elisp
      tree-sitter-nu
    ]);

  extraPlugins = with pkgs.vimPlugins; [
    vim-nickel
    vim-nix
    zig-vim
  ];
}
