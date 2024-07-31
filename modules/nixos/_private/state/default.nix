{ lib, ... }:

{
  imports = [
    ./paths.nix
    ./ports.nix
  ];

  options.state = lib.mkOption {
    type = lib.types.submodule {
      freeformType = with lib.types; attrsOf anything;
      default = { };
    };
    description = ''
      A set of values referring to the system state for use in other parts of
      the NixOS system. Useful for consistent values and referring to a single
      source of truth for different parts (e.g., services, program) of the
      system.
    '';
    example = {
      services = {
        postgresql.directory = "/var/lib/postgresql";
        backup.ignoreDirectories = [
          "node_modules"
          ".direnv"
        ];
      };
    };
  };
}
