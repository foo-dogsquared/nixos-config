# A library specifically for environments with sops-nix.
{ pkgs, lib, self }:

let
  inferFormat = sopsFile:
    let endsWith = ext: lib.hasSuffix ext sopsFile;
    in
      if (endsWith ".env") then "dotenv"
      else if (endsWith ".yaml" || endsWith ".yml") then "yaml"
      else if (endsWith ".json") then "json"
      else if (endsWith ".ini") then "ini"
      else if (endsWith ".bin") then "binary"
      # The fallback format.
      else "yaml";
in
rec {
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
    let getKey = key: {
      inherit key sopsFile;
      format = inferFormat sopsFile;
    };
    in lib.mapAttrs (path: attrs: (getKey path) // attrs) secrets;

  getAsOneSecret = sopsFile:
    {
      inherit sopsFile;
      format = inferFormat sopsFile;

      # This value basically means it's the whole file.
      key = "";
    };

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
    lib.mapAttrs' (key: settings:
      lib.nameValuePair "${prefix}/${key}" ({ inherit key; } // settings))
    secrets;
}
