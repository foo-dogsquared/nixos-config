# All of the custom functions used for this configuration.
{ lib }:

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
        value =
          let path = dirPath + "/${file}";
          in if (type == "regular")
            || (type == "directory" && lib.pathExists (path + "/default.nix")) then
            path
          else
            filesToAttr path;
      };

      files = lib.filterAttrs isModule (builtins.readDir dirPath);
    in
    lib.filterAttrs (name: value: value != { })
      (lib.mapAttrs' collect files);

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

  /* Get the secrets from a given sops file. This will set the individual
     attributes `sopsFile` with the given file to not interrupt as much as
     possible with your own sops-nix workflow.

     Examples:
      lib.getSecrets ./sops.yaml {
        ssh-key = { };
        "borg/ssh-key" = { };
        "wireguard/private-key" = {
          group = config.users.users.systemd-network.group;
          reloadUnits = [ "systemd-networkd.service" ];
          mode = "0640";
        };
      }
  */
  getSecrets = sopsFile: secrets:
    let
      getKey = key: { inherit key sopsFile; };
    in
    lib.mapAttrs
      (path: attrs:
        (getKey path) // attrs)
      secrets;

  /* Prepend a prefix for the given secrets. This allows a workflow for
     separate sops file.

     Examples:
       lib.getSecrets ./sops.yaml {
        ssh-key = { };
        "borg/ssh-key" = { };
      } //
      (lib.getSecrets ./wireguard.yaml
        (lib.attachSopsPathPrefix "wireguard" {
          "private-key" = {
            group = config.users.users.systemd-network.group;
            reloadUnits = [ "systemd-networkd.service" ];
            mode = "0640";
          };
        }))
  */
  attachSopsPathPrefix = prefix: secrets:
    lib.mapAttrs'
      (key: settings:
        lib.nameValuePair
          "${prefix}/${key}"
          ({ inherit key; } // settings))
      secrets;
}
