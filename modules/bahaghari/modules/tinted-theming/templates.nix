# A set of Tinted Theming templates to be applied somewhere. At its current
# state, this module is useless itself that it only holds a global set of
# templates for now.
{ lib, ... }:

{
  options.bahaghari.tinted-theming = {
    templates = lib.mkOption {
      type = with lib.types; attrsOf path;
      default = { };
      example = lib.literalExpression ''
        {
          vim = pkgs.fetchFromGitHub {
            owner = "tinted-theming";
            repo = "base16-vim";
            rev = "tinted-theming/base16-vim";
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          helix = ./templates/helix;
        }
      '';
      description = ''
        A set of Tinted Theming templates to be applied for the schemes.
      '';
    };
  };
}
