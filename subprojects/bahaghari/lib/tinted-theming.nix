{ pkgs, lib }:

# TODO: Remove the legacy scheme support once it is entirely removed in Tinted
# Theming standard.
let
  isBaseX = i: palette:
    let
      paletteNames = pkgs.lib.attrNames palette;
      maxDigitLength = pkgs.lib.lists.length (pkgs.lib.toBaseDigits 10 i);
      mkBaseAttr = hex: "base${lib.hex.pad maxDigitLength hex}";
      schemeNames = builtins.map mkBaseAttr (lib.hex.range 0 (i - 1));
    in
    (pkgs.lib.count (name: pkgs.lib.elem name schemeNames) paletteNames) == i;
in
rec {
  # TODO: Return a Nix object to generate a Tinted Theming color scheme from an
  # image.
  generateScheme = image: { };

  /* A very naive implementation of checking whether the given palette is a
     valid Base16 scheme. It simply checks if palette has `base00` to `base0F`
     is present as well as other required keys.

     Type: isBase16 :: Attrs -> Bool

     Example:
       isBase16 (bahaghariLib.tinted-theming.importScheme ./base16.yml)
       => true

       isBase16 (bahaghariLib.tinted-theming.importScheme ./base16-scheme-with-missing-base0F.yml)
       => false
  */
  isBase16 = isBaseX 16;

  /* Similar to `isBase16` but for Base24 schemes. It considers the scheme as
     valid if `base00` to `base17` from the palette are present.

     Type: isBase24 :: Attrs -> Bool

     Example:
       isBase24 (bahaghariLib.tinted-theming.importScheme ./base24.yml)
       => true

       isBase24 (bahaghariLib.tinted-theming.importScheme ./base24-scheme-with-missing-base0F.yml)
       => false
  */
  isBase24 = isBaseX 24;

  /* Given a scheme, checks if it's a valid Tinted Theming scheme format (e.g.,
     Base16, Base24). Take note it doesn't accept deprecated scheme formats.

     Type: isValidScheme :: Attrs -> Bool

     Example:
       isValidScheme (bahaghariLib.importYAML ./base24.yml).palette
       => true

       isValidScheme (bahaghariLib.importYAML ./base16.yml).palette
       => true
  */
  isValidScheme = scheme:
    scheme?palette && scheme?author && scheme?name;

  /* Checks if the given scheme is in the deprecated Base16 legacy schema.

     Type: isLegacyBase16 :: Attrs -> Bool

     Example:
       isLegacyBase16 {
         # Some old-ass scheme...
       }
       => true

       isLegacyBase16 {
         # Some new-ass scheme such as from the updated schemes repo...
       }
       => false
  */
  isLegacyScheme = scheme:
    scheme?scheme && scheme?author;

  /* Given a legacy BaseX scheme, update the scheme into the current iteration
     of the Tinted Theming scheme format.

     Type: modernizeLegacyBaseScheme :: Attrs -> Attrs

     Example:
       modernizeLegacyScheme (importYAML ./legacy-base16-scheme.yml)
       => {
         system = "base16";
         name = "Yo mama";
         author = "You";
         palette = {
           # All of the top-level keys except for author, description, and scheme.
         };
       }
  */
  modernizeLegacyScheme = scheme:
    let
      system =
        if isBase24 scheme
        then "base24"
        else if isBase16 scheme
        then "base16"
        else null;

      palette =
        pkgs.lib.attrsets.removeAttrs scheme [ "author" "description" "scheme" ];
    in
    {
      inherit (scheme) author;
      inherit palette;

      name = scheme.scheme;
    }
    // pkgs.lib.optionalAttrs (scheme?description) { inherit (scheme) description; }
    // pkgs.lib.optionalAttrs (system != null) { inherit system; };

  /* Imports a Base16 scheme. This also handles converting the legacy Base16
     schema into the new one if it's detected. Take note, every single token
     that is not part of the legacy proper is assumed to be part of the
     `palette` of the new schema.

     Type: importBase16Scheme :: Path -> Attrs

     Example:
       importScheme ./legacy-base16-scheme.yml
       => {
         system = "base16";
         name = "Scheme name";
         author = "Scheme author";
         palette = {
           # All legacy token that are not included in the old standard proper
           # are placed here. This is typically something like `background`,
           # `foreground`, and whatnot that are added for enriching the palette
           # or just for semantics for the theme designers.
         };
       }
  */
  importScheme = yamlpath:
    let
      scheme = lib.importYAML yamlpath;
    in
    assert pkgs.lib.assertMsg (isValidScheme scheme || isLegacyScheme scheme)
      "bahaghariLib.tinted-theming.importScheme: given data is not a valid Tinted Theming scheme";
    if isLegacyScheme scheme
    then modernizeLegacyScheme scheme
    else scheme;
}
