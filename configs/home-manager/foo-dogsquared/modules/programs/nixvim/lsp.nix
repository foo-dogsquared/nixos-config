{ config, lib, pkgs, ... }:

{
  plugins.lsp.enable = true;
  plugins.lsp.inlayHints = true;

  # Enable all of the LSP servers that I'll likely use.
  plugins.lsp.servers = {
    bashls.enable = true; # For Bash.
    clangd.enable = true; # For C/C++.
    cmake.enable = true; # For CMake.
    cssls.enable = true; # For CSS.
    denols.enable = true; # For Deno runtime.
    dockerls.enable = true; # For Dockerfiles.
    emmet_ls.enable = true; # For emmet support.
    eslint.enable = true; # For JavaScript.
    html.enable = true; # For HTML.
    jsonls.enable = true; # There's one for JSON?
    lemminx.enable = true; # And for XML?
    ltex.enable = true; # And for LanguageTool, too?
    lua_ls.enable = true; # For Lua.
    nixd.enable = true; # For Nix.
    nushell.enable = true; # For Nushell.
    pyright.enable = true; # For Python.

    # For Rust (even though I barely use it).
    rust_analyzer = {
      enable = true;
      installRustc = false;
      installCargo = false;
    };

    solargraph.enable = true; # For Ruby.
    tailwindcss.enable = true; # For Tailwind CSS.
    terraformls.enable = true; # For Terraform.
    ts_ls.enable = true; # For TypeScript.
  };
}
