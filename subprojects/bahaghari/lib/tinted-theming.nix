{ pkgs, lib, self }:

# TODO: Remove the legacy scheme support once it is entirely removed in Tinted
# Theming standard.
let
  isBaseX = i: palette:
    let
      paletteNames = lib.attrNames palette;
      maxDigitLength = lib.lists.length (lib.toBaseDigits 10 i);
      mkBaseAttr = hex: "base${self.hex.pad maxDigitLength hex}";
      schemeNames = builtins.map mkBaseAttr (self.hex.range 0 (i - 1));
    in
    (lib.count (name: lib.elem name schemeNames) paletteNames) == i;
in
rec {
  /* Imports a Base16 scheme. This also handles converting the legacy Base16
     schema into the new one if it's detected. Take note, every single token
     that is not part of the legacy proper is assumed to be part of the
     `palette` of the new schema.

     :::{.note}
     This is the main entrypoint of the Bahaghari library Tinted Theming
     subset. It is expected that most users will use this.
     :::

     Type: importScheme :: Path -> Attrs

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
      scheme = self.importYAML yamlpath;
    in
    assert lib.assertMsg (isValidScheme scheme || isLegacyScheme scheme)
      "bahaghariLib.tinted-theming.importScheme: Given data is not a valid Tinted Theming scheme";
    if isLegacyScheme scheme
    then modernizeLegacyScheme scheme
    else scheme;

  # TODO: Return a Nix object to generate a Tinted Theming color scheme from an
  # image.
  generateScheme = image: { };

  /* A very naive implementation of checking whether the given palette is a
     valid Base16 scheme. It simply checks if palette has `base00` to `base0F`
     is present as well as other required keys.

     Type: isBase16 :: Attrs -> Bool

     Example:
       isBase16 (bahaghariLib.tinted-theming.importScheme ./base16.yml).palette
       => true

       isBase16 (bahaghariLib.tinted-theming.importScheme ./base16-scheme-with-missing-base0F.yml).palette
       => false
  */
  isBase16 = isBaseX 16;

  /* Similar to `isBase16` but for Base24 schemes. It considers the scheme as
     valid if `base00` to `base17` from the palette are present.

     Type: isBase24 :: Attrs -> Bool

     Example:
       isBase24 (bahaghariLib.tinted-theming.importScheme ./base24.yml).palette
       => true

       isBase24 (bahaghariLib.tinted-theming.importScheme ./base24-scheme-with-missing-base0F.yml).palette
       => false
  */
  isBase24 = isBaseX 24;

  /* Given a scheme, checks if it's a valid Tinted Theming scheme format (e.g.,
     Base16, Base24). Take note it doesn't accept deprecated scheme formats.

     Type: isValidScheme :: Attrs -> Bool

     Example:
       isValidScheme (bahaghariLib.tinted-theming.importScheme ./base24.yml)
       => true

       isValidScheme (bahaghariLib.tinted-theming.importScheme ./base16.yml)
       => true
  */
  isValidScheme = scheme:
    scheme?palette && scheme?author && scheme?name;

  /* Checks if the given scheme is in the deprecated Base16 legacy schema.

     Type: isLegacyBase16 :: Attrs -> Bool

     Example:
       isLegacyBase16 (bahaghariLib.tinted-theming.importScheme ./legacy-base16-scheme.yml)
       => true

       isLegacyBase16 (bahaghariLib.tinted-theming.importScheme ./modern-base16-scheme.yml)
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
        lib.attrsets.removeAttrs scheme [ "author" "description" "scheme" ];
    in
    {
      inherit (scheme) author;
      inherit palette;

      name = scheme.scheme;
    }
    // lib.optionalAttrs (scheme?description) { inherit (scheme) description; }
    // lib.optionalAttrs (system != null) { inherit system; };
}
