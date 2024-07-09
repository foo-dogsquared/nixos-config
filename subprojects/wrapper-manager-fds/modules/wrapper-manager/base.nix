{ config, lib, ... }:

{
  options = {
    wrappers = lib.mkOption {
      type = with lib.types; attrsOf (submoduleWith {
        modules = [ ./shared/wrappers.nix ];
        specialArgs.envConfig = config;
        shorthandOnlyDefinesConfig = true;
      });
      description = ''
        A set of wrappers to be included in the resulting derivation from
        wrapper-manager evaluation.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          yt-dlp-audio = {
            arg0 = lib.getExe' pkgs.yt-dlp "yt-dlp";
            prependArgs = [
              "--config-location" ./config/yt-dlp/audio.conf
            ];
          };
        }
      '';
    };

    basePackages = lib.mkOption {
      type = with lib.types; listOf package;
      description = ''
        A list of packages to be included in the wrapper package.

        ::: {note}
        If the list is not empty, this can override some of the binaries
        included in this list which is typically intended to be used as a
        wrapped package.
        :::
      '';
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          yt-dlp
        ]
      '';
    };
  };
}
