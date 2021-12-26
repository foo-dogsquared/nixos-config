{ lib, ... }:

rec {
  /* Create an attribute set that represents the structure of the modules
     inside of a directory.  While it can recurse into directories, it will
     stop once it detects `default.nix` inside.

     Signature:
       path -> attrset
     Where:
       - `path` is the starting point.
     Returns:
       An attribute set. The keys are the basename of the file or the directory
       and the values are the filepath to the Nix file.

     !!! Implementation detail is based from
     https://github.com/divnix/digga/blob/main/src/importers.nix looking at it
     multiple times for the purpose of familiarizing myself to coding in Nix
     and functional programming shtick.

     Example:
       filesToAttr ./hosts
       => { ni = ./hosts/ni/default.nix; zilch = ./hosts/zilch/default.nix }
  */
  filesToAttr = dirPath:
    let
      isModule = file: type:
        (type == "regular" && lib.hasSuffix ".nix" file)
        || (type == "directory");

      collect = file: type: {
        name = lib.removeSuffix ".nix" file;
        value = let path = dirPath + "/${file}";
        in if (type == "regular")
        || (type == "directory" && lib.pathExists (path + "/default.nix")) then
          path
        else
          filesToAttr path;
      };

      files = lib.filterAttrs isModule (builtins.readDir dirPath);
    in lib.filterAttrs (name: value: value != { })
    (lib.mapAttrs' collect files);

  /* Like `filesToAttr` but does it recursively.  Those modules with
     `default.nix` are ignored and gives the full module directory this time.
     This is only suitable if you intend to use all of the modules in a given
     directory.

     Signature:
       path -> attrset
     Where:
       - `path` is the starting point of the scan.
     Returns:
       An attribute set. The keys are the basename for each Nix file/directory
       and the values are the path to the file.

     Examples:
       filesToAttrRec ./modules
       => { agenix = /home/foo-dogsquared/nixos-config/modules/agenix.nix; archiving = /home/foo-dogsquared/nixos-config/modules/archiving.nix; desktop = /home/foo-dogsquared/nixos-config/modules/desktop.nix; dev = /home/foo-dogsquared/nixos-config/modules/dev.nix; editors = /home/foo-dogsquared/nixos-config/modules/editors.nix; themes = { a-happy-gnome = /home/foo-dogsquared/nixos-config/modules/themes/a-happy-gnome; default = /home/foo-dogsquared/nixos-config/modules/themes/default.nix; }; }
  */
  filesToAttrRec = dir:
    let
      files = lib.filterAttrs (n: v: n != "default") (filesToAttr dir);

      collect = name: file: {
        inherit name;

        # Since `filesToAttr` has already filtered the files, we can be assured
        # it is only either a Nix file or a directory containing a
        # `default.nix`.
        value = if (lib.pathIsDirectory file) then filesToAttr file else file;
      };
    in lib.listToAttrs (lib.mapAttrsToList collect files);

  /* Collect all modules (results from `filesToAttr`) into a list.

     Signature:
       attrs -> [ function ]
     Where:
       - `attrs` is the set of modules and their path.
     Returns:
       - A list of imported modules.

     Example:
       modulesToList (filesToAttr ../modules)
       => [ <lambda> <lambda> <lambda> ]
  */
  modulesToList = attrs:
    let paths = lib.collect builtins.isPath attrs;
    in builtins.map (path: import path) paths;

  /* Return an attribute set of valid users from a given list of users.
     This is a convenience function for getting users from the `./users` directory.

     Signature:
       list -> attrset
     Where:
       - `list` is a list of usernames as strings
       - `attrset` is a set of valid users with the name as the key and the path as the value.
     Example:
       # Assuming only 'foo-dogsquared' is the existing user for 'home-manager'.
       getUsers "home-manager" [ "foo-dogsquared" "archie" "brad" ]
       => { foo-dogsquared = /home/foo-dogsquared/projects/nixos-config/users/foo-dogsquared; }
  */
  getUsers = type: users:
    let
      userModules = filesToAttr ../users/${type};
      invalidUsernames = [ "config" "modules" ];
    in lib.filterAttrs (n: _: !lib.elem n invalidUsernames && lib.elem n users) userModules;

  # Return the path of `secrets` from `../secrets`.
  getSecret = path: ../secrets/${path};

  /* Create an attribute set from two lists (or a zip).

     Examples:
       zipToAttrs [ "tails" "breed" ] [ 1 "Doggo" ]
       => { tails = 1; breed = "Doggo" }

       zipToAttrs [ "hello" "d" ] [ { r = 5; f = "dogs"; } { r = 532; f = "dogsso"; } ]
       => { d = { ... }; hello = { ... }; }
  */
  zipToAttrs = keys: values:
    lib.listToAttrs
    (lib.zipListsWith (name: value: { inherit name value; }) keys values);

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
}
