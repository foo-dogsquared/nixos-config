{ pkgs, lib, self }:

rec {
  /* Force a numerical value to be a floating value.

     Example:
       toFloat 5698
       => 5698.0

       toFloat 9859.55
       => 9859.55
  */
  toFloat = x: x / 1.0;

  /* Count the attributes with the given predicate.

     Examples:
       countAttrs (name: value: value) { d = true; f = true; a = false; }
       => 2

       countAttrs (name: value: value.enable) { d = { enable = true; }; f = { enable = false; package = [ ]; }; }
       => 1
  */
  countAttrs = pred: attrs:
    lib.count (attr: pred attr.name attr.value)
    (lib.mapAttrsToList lib.nameValuePair attrs);

  /* Filters and groups the attribute set into two separate attribute where it
     either accepted or denied from a given predicate function.

     Example:
       filterAttrs' (n: v: v == 4) { a = 4; b = 2; c = 6; }
       => { ok = { a = 4; }; notOk = { b = 2; c = 6; }; }
  */
  filterAttrs' = f: attrs:
    lib.foldlAttrs (acc: name: value:
      let isOk = f name value;
      in {
        ok = acc.ok // lib.optionalAttrs isOk { ${name} = value; };
        notOk = acc.notOk // lib.optionalAttrs (!isOk) { ${name} = value; };
      }) {
        ok = { };
        notOk = { };
      } attrs;

  /* Convenient function for converting bits to bytes.

     Example:
       bitsToBytes 1600
       => 200
  */
  bitsToBytes = x: x / 8.0;

  /* Gives the exponent with the associated SI prefix.

     Example:
       SIPrefixExponent "M"
       => 6

       SIPrefixExponent "Q"
       => 30
  */
  SIPrefixExponent = c:
    let
      prefixes = {
        Q = 30;
        R = 27;
        Y = 24;
        Z = 21;
        E = 18;
        P = 15;
        T = 12;
        G = 9;
        M = 6;
        k = 3;
        h = 2;
        da = 1;
        d = -1;
        c = -2;
        m = -3;
        "μ" = -6;
        n = -9;
        p = -12;
        f = -15;
        a = -18;
        z = -21;
        y = -24;
        r = -27;
        q = -30;
      };
    in prefixes.${c};

  /* Gives the multiplier for the metric units.

     Example:
      metricPrefixMultiplier "M"
      => 1000000

      metricPrefixMultiplier "G"
      => 1000000000
  */
  metricPrefixMultiplier = c: self.math.pow 10 (SIPrefixExponent c);

  /* Gives the exponent with the associated binary prefix.

     As an implementation detail, we don't follow the proper IEC unit prefixes
     and instead mapping this to the SI prefix for convenience.

     Example:
       SIPrefixExponent "M"
       => 6

       SIPrefixExponent "Q"
       => 30
  */
  binaryPrefixExponent = c:
    let
      prefixes = {
        Y = 80;
        Z = 70;
        E = 60;
        P = 50;
        T = 40;
        G = 30;
        M = 20;
        K = 10;
      };
    in prefixes.${c};

  /* Gives the multiplier for the given byte unit. Essentially returns the
     value in number of bytes.

     Example:
       binaryPrefixMultiplier "M"
       => 1048576

       binaryPrefixMultiplier "G"
       => 1.099511628×10¹²
  */
  binaryPrefixMultiplier = c: self.math.pow 2 (binaryPrefixExponent c);

  /* Parse the given string containing the size into its appropriate value.
     Returns the value in number of bytes.

     Example:
      parseBytesSizeIntoInt "4GiB"
      => 4294967296

      parseBytesSizeIntoInt "2 MB"
      => 2000000

      parseBytesSizeIntoInt "2 Mb"
      => 250000
  */
  parseBytesSizeIntoInt = str:
    let
      matches =
        builtins.match "([[:digit:]]+)[[:space:]]*([[:alpha:]]{1})(i?[B|b])"
        str;
      numeral = lib.toInt (lib.lists.head matches);
      prefix = lib.lists.elemAt matches 1;
      suffix = lib.lists.last matches;
      isBinary = lib.hasPrefix "i" suffix;

      multiplier = let
        multiplierFn =
          if isBinary then binaryPrefixMultiplier else metricPrefixMultiplier;
      in multiplierFn prefix;
      bitDivider = if lib.hasSuffix "b" suffix then 8 else 1;
    in numeral * multiplier / bitDivider;

  /* Given an attrset of unit size object, return the size in bytes.

     Example:
       unitsToInt { size = 4; prefix = "G"; type = "binary"; }
       => 4294967296

       unitsToInt { size = 4; prefix = "G"; type = "metric"; }
       => 4000000000
  */
  unitsToInt = { size, prefix, type ? "binary" }:
    let
      multiplierFn = if type == "binary" then
        binaryPrefixMultiplier
      else if type == "metric" then
        metricPrefixMultiplier
      else
        builtins.throw "no multiplier type ${type}";
    in size * (multiplierFn prefix);
}
