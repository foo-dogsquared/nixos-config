{ lib, inputs, ... }:

let
  # Default system for our host configuration.
  sys = "x86_64-linux";
in rec {
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

  /* Create a NixOS system through a given host folder.
     It will automate some of the things such as making the last component
     of the path as the hostname.

     Signature:
       path -> attrset -> NixOS configuration
     Where:
       - `path` is a path to a Nix file for the host; the basename of the file
         is also used as the hostname
       - `attrset` is the attribute set to be included in the host configuration
     Returns:
       An attribute set from the `lib.nixosSystem` from `nixpkgs` flake.

     Example:
       mkHost ./hosts/june {}
       => { ... } # NixOS configuration attrset
  */
  mkHost = file:
    attrs@{ system ? sys, ... }:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit lib system inputs; };

      # We also set the following in order for priority.
      # Later modules will override previously imported modules.
      modules = [
        # Set the hostname.
        {
          networking.hostName = builtins.baseNameOf file;
        }

        # Put the given attribute set (except for the system).
        (lib.filterAttrs (n: v: !lib.elem n [ "system" ]) attrs)

        # The entry point of the module.
        file
      ]
      # Append with our custom modules from the modules folder.
        ++ (lib.mapAttrsToList (n: v: import v) (filesToAttr ../modules));
    };

    /* Return an attribute set of valid users from a given list of users.

      Signature:
        list -> attrset
      Where:
        - `list` is a list of usernames as strings
        - `attrset` is a set of valid users with the name as the key and the path as the value.
      Example:
        # Assuming only 'foo-dogsquared' is the existing user.
        getUsers [ "foo-dogsquared" "archie" "brad" ]
        => { foo-dogsquared = /home/foo-dogsquared/projects/nixos-config/users/foo-dogsquared; }
    */
    getUsers = users:
    let
      userModules = filesToAttr ../users;
      validUsers = lib.filter (user: lib.elem user (lib.attrNames userModules)) users;
    in lib.filterAttrs (n: _: lib.elem n validUsers) userModules;

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
  */
  countAttrs = pred: attrs:
    lib.count (attr: pred attr.name attr.value)
    (lib.mapAttrsToList lib.nameValuePair attrs);
}
