# Custom libraries for home-manager library.
{ pkgs, lib, self }:

rec {
  /*
    Checks if there is the `osConfig` attribute and get the attribute path from
    its system configuration.
  */
  hasNixOSConfigAttr =
    # The configuration attribute set of the home-manager configuration.
    attrs:

    # A list of strings representing the attribute path.
    attrPath:

    # The default value when `attrPath` is missing.
    default:
    attrs ? nixosConfig && lib.attrByPath attrPath default attrs;

  hasDarwinConfigAttr =
    # The configuration attribute set of the home-manager configuration.
    attrs:

    # A list of strings representing the attribute path.
    attrPath:

    # The default value when `attrPath` is missing.
    default:
    attrs ? darwinConfig && pkgs.lib.attrByPath attrPath default attrs;

  /*
    A quick function to check if the optional NixOS system module is enabled.
  */
  hasOSModuleEnabled =
    # The configuration attribute set of the home-manager configuration.
    attrs:

    # A list of strings representing the attribute path.
    attrPath:
    hasNixOSConfigAttr attrs attrPath false;
}
