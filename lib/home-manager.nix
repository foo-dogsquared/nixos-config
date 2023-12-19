# Custom libraries for home-manager library.
{ lib }:

{
  /*
    Checks if there is the `osConfig` attribute and get the attribute path from
    its system configuration.
  */
  getOSConfigPath =
    # The configuration attribute set of the home-manager configuration.
    attrs:

    # A list of strings representing the attribute path.
    attrPath:

    # The default value when `attrPath` is missing.
    default:
    attrs ? osConfig && lib.attrByPath attrPath default attrs;
}
