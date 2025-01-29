{ config, lib, ... }:

let
  nixvimCfg = config.nixvimConfigs.trovebelt;
  cfg = nixvimCfg.setups.lsp;
in {
  options.nixvimConfigs.trovebelt.setups.lsp.enable =
    lib.mkEnableOption "LSP setup alongside the preferred servers installation";

  config = lib.mkIf cfg.enable {
    plugins.lsp.enable = true;

    # Make all of the preferred language servers.
    plugins.lsp.servers = let
      servers = [
        "ansiblels" # For Ansible.
        "astro" # For Astro.
        "beancount" # For Beancount.
        "bashls" # For Bash.
        "clangd" # For C/C++.
        "clojure-lsp" # For Clojure.
        "cmake" # For CMake.
        "cssls" # For CSS.
        "dagger" # For Dagger.
        "dartls" # For Dart.
        "denols" # For Deno.
        "dhall-lsp-server" # For Dhall.
        "dockerls" # For Dockerfiles.
        "efm" # For whatever.
        "elixirls" # For Elixir.
        "elmls" # For Elm.
        "emmet-ls" # For Emmet support.
        "eslint" # For JavaScript.
        "gdscript" # For Godot.
        "gopls" # For Go.
        "graphql" # For GraphQL.
        "hls" # For Haskell.
        "html" # For HTML.
        "htmx" # For HTMX.
        "java-language-server" # For Java.
        "jsonls" # For JSON.
        "julials" # For Julia.
        "kotlin-language-server" # For Kotlin.
        "lemminx" # For XML.
        "lua-ls" # For Lua.
        "nil-ls" # For Nix.
        "nushell" # For Nushell.
        "perlpls" # For Perl.
        "phpactor" # For PHP.
        "pyright" # For Python.
        "rust-analyzer" # For Rust.
        "solargraph" # For Ruby.
        "svelte" # For Svelte.
        "taplo" # For TOML.
        "tailwindcss" # For Tailwind CSS.
        "terraformls" # For Terraform.
        "tsserver" # For TypeScript.
        "typst-lsp" # For Typst.
        "vls" # For V.
        "volar" # For Vue.
        "yamlls" # For YAML.
        "zls" # For Zig.
      ];

      mkEnableServerConfig = server:
        lib.nameValuePair server { enable = true; };
    in lib.listToAttrs (builtins.map mkEnableServerConfig servers);
  };
}
