{ config, lib, pkgs, ... }:

let
  cfg = config.programs.distrobox;

  toDistroboxConf = lib.generators.toKeyValue {
    listsAsDuplicateKeys = false;
    mkKeyValue = lib.generators.mkKeyValueDefault {
      mkValueString = v:
        if v == true then "1"
        else if v == false then "0"
        else if lib.isString v then ''"${v}"''
        else if lib.isList v then lib.concatStringsSep " " v
        else lib.generators.mkValueStringDefault { } v;
    } "=";
  };

  distroboxConfFormat = { }: {
    type = with lib.types;
      let
        valueType = oneOf [
          bool
          float
          int
          path
          str
          (listOf valueType)
        ];
      in
      attrsOf valueType;

    generate = name: value: pkgs.writeText name (toDistroboxConf value);
  };

  settingsFormat = distroboxConfFormat { };

  settingsFile = settingsFormat.generate "distrobox-settings" cfg.settings;
in
{
  options.programs.distrobox = {
    enable = lib.mkEnableOption "Distrobox";
    package = lib.mkPackageOption pkgs "distrobox" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Settings to be included for Distrobox.

        ::: {.note}
        You don't have surround the string values with double quotes since the
        module will add them for you.
        :::
      '';
      example = lib.literalExpression ''
        {
          container_additional_volumes = [
            "/nix/store:/nix/store:r"
            "/etc/profiles/per-user:/etc/profiles/per-user:r"
          ];
          container_image_default = "registry.opensuse.org/opensuse/distrobox-packaging:latest";
          unshare_ipc = true;
          unshare_netns = true;
        }
      '';
    };

    settingsFile = lib.mkOption {
      type = lib.types.path;
      default = settingsFile;
      description = lib.mdDoc ''
        The path to the settings file for Distrobox to be put at
        {file}`/etc/distrobox/distrobox.conf`. By default, it will use a
        Nix-generated file configured with
        {option}`programs.distrobox.settings`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = config.virtualisation.podman.enable || config.virtualisation.docker.enable;
      message = ''
        Neither Podman nor Docker is enabled. You need to use enable either to
        be able to use this program.
      '';
    }];

    environment.systemPackages = [ cfg.package ];

    environment.etc."distrobox/distrobox.conf".source = settingsFile;
  };
}
