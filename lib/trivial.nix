{ pkgs, lib, self }:

{
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
    lib.foldlAttrs (acc: name: value: let
      isOk = f name value;
    in {
      ok = acc.ok // lib.optionalAttrs isOk { ${name} = value; };
      notOk = acc.notOk // lib.optionalAttrs (!isOk) { ${name} = value; };
    })
    { ok = { }; notOk = { }; }
    attrs;
}
