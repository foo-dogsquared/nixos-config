# The entrypoint for our custom library set.
{ pkgs }:

pkgs.lib.makeExtensible
  (self:
    rec {
      /* Count the attributes with the given predicate.

         Examples:
           countAttrs (name: value: value) { d = true; f = true; a = false; }
           => 2

           countAttrs (name: value: value.enable) { d = { enable = true; }; f = { enable = false; package = [ ]; }; }
           => 1
      */
      countAttrs = pred: attrs:
        pkgs.lib.count (attr: pred attr.name attr.value)
          (pkgs.lib.mapAttrsToList pkgs.lib.nameValuePair attrs);

      /* Returns the file path of the given config of the given environment.

         Type: getConfig :: String -> String -> Path

         Example:
           getConfig "home-manager" "foo-dogsquared"
           => ../configs/home-manager/foo-dogsquared
      */
      getConfig = type: config: ../configs/${type}/${config};


      /* Returns the file path of the given user subpart of the given
         environment. Only certain environments such as NixOS have this type of
         setup.

         Type: getConfig :: String -> String -> Path

         Example:
           getUser "nixos" "foo-dogsquared"
           => ../configs/nixos/_users/foo-dogsquared
      */
      getUser = type: user: ../configs/${type}/_users/${user};
    })
