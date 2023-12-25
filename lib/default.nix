# All of the custom functions used for this configuration.
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
