# All of the custom functions suitable for all environments.
{ lib }:

rec {
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

  getConfig = type: config: ../configs/${type}/${config};

  getUser = type: user: ../configs/${type}/_users/${user};
}
