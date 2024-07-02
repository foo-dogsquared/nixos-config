{ config, lib, ... }:

let
  cfg = config.wrapper-manager;

  wrapperManagerModule = lib.types.submoduleWith {
    description = "wrapper-manager module";
    class = "wrapperManager";
    specialArgs = cfg.extraSpecialArgs // {
      modulesPath = builtins.toString ../wrapper-manager;
    };
    modules = [
      ({ lib, name, ... }: {
        imports = [ ../wrapper-manager ];
        config.executableName = lib.mkDefault name;
      })
    ] ++ cfg.sharedModules;
  };
in
{
  options.wrapper-manager = {
    sharedModules = lib.mkOption {
      type = with lib.types; listOf deferredModule;
      default = [ ];
      example = lib.literalExpression ''
        [
          {
            config.build = {
              variant = "package";
              isBinary = true;
            };
          }
        ]
      '';
      description = ''
        Extra modules to be added to all of the wrappers.
      '';
    };

    wrappers = lib.mkOption {
      type = lib.types.attrsOf wrapperManagerModule;
      description = ''
        A set of wrappers to be added into the environment configuration.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          neofetch = {
            arg0 = lib.getExe' pkgs.neofetch "neofetch";
            appendArgs = [
              "--ascii-distro" "guix"
              "--config" ./config/neofetch/config
            ];
          };

          yt-dlp-audio = {
            arg0 = lib.getExe' pkgs.yt-dlp "yt-dlp";
            prependArgs = [
              "--config-location" ./config/yt-dlp/audio.conf
            ];
          };

          asciidoctor-fds = {
            arg = lib.getExe' pkgs.asciidoctor-with-extensions "asciidoctor";
            executableName = "asciidoctor";
            prependArgs =
              builtins.map (v: "-r ''${v}") [
                "asciidoctor-diagram"
                "asciidoctor-bibtex"
              ];
          };
        }
      '';
    };

    extraSpecialArgs = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      description = ''
        Additional set of module arguments to be passed to `specialArgs` of
        the wrapper module evaluation.
      '';
      example = {
        yourMomName = "Joe Mama";
      };
    };
  };
}
