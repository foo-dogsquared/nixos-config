{ config, lib, ... }:

let
  nixvimCfg = config.nixvimConfigs.trovebelt;
  cfg = nixvimCfg.setups.lsp;
in {
  options.nixvimConfigs.trovebelt.setups.lsp.enable =
    lib.mkEnableOption "LSP setup alongside the preferred servers installation";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      plugins.lsp.enable = true;

      # Make all of the preferred language servers.
      plugins.lsp.servers = let
        servers = [
          "ansiblels" # For Ansible.
          "astro" # For Astro.
          "beancount" # For Beancount.
          "bashls" # For Bash.
          "clangd" # For C/C++.
          "clojure_lsp" # For Clojure.
          "cmake" # For CMake.
          "cssls" # For CSS.
          "dagger" # For Dagger.
          "dartls" # For Dart.
          "denols" # For Deno.
          "dhall_lsp_server" # For Dhall.
          "dockerls" # For Dockerfiles.
          "efm" # For whatever.
          "elixirls" # For Elixir.
          "elmls" # For Elm.
          "emmet_ls" # For Emmet support.
          "eslint" # For JavaScript.
          "gdscript" # For Godot.
          "gopls" # For Go.
          "graphql" # For GraphQL.
          "hls" # For Haskell.
          "html" # For HTML.
          "htmx" # For HTMX.
          "java_language_server" # For Java.
          "jsonls" # For JSON.
          "julials" # For Julia.
          "kotlin_language_server" # For Kotlin.
          "lemminx" # For XML.
          "lua_ls" # For Lua.
          "nil_ls" # For Nix.
          "nushell" # For Nushell.
          "perlpls" # For Perl.
          "phpactor" # For PHP.
          "pyright" # For Python.
          "rust_analyzer" # For Rust.
          "solargraph" # For Ruby.
          "svelte" # For Svelte.
          "taplo" # For TOML.
          "tailwindcss" # For Tailwind CSS.
          "terraformls" # For Terraform.
          "ts_ls" # For TypeScript.
          "typst_lsp" # For Typst.
          "vls" # For V.
          "volar" # For Vue.
          "yamlls" # For YAML.
          "zls" # For Zig.
        ];

        mkEnableServerConfig = server:
          lib.nameValuePair server { enable = true; };
      in lib.listToAttrs (lib.map mkEnableServerConfig servers);
    }

    {
      plugins.lsp.servers.rust_analyzer = {
        installCargo = lib.mkDefault true;
        installRustc = lib.mkDefault true;
      };

      plugins.lsp.servers.hls = {
        installGhc = lib.mkDefault true;
      };
    }
  ]);
}
