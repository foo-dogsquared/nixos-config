{ config, lib, pkgs, ... }:

let
  cfg = config.wrapper-manager;

  wrapperManagerModule = lib.types.submoduleWith {
    description = "wrapper-manager module";
    class = "wrapperManager";
    specialArgs = cfg.extraSpecialArgs // {
      inherit pkgs;
      modulesPath = builtins.toString ../wrapper-manager;
    };
    modules = [
      ../wrapper-manager
    ] ++ cfg.sharedModules;
  };
in
{
  imports = [
    # Bringing all of the arguments from the wrapper-manager environment for
    # convenience. It would also allow its users for full control without using
    # the integration module itself.
    ../wrapper-manager/extra-args.nix
  ];

  options.wrapper-manager = {
    sharedModules = lib.mkOption {
      type = with lib.types; listOf deferredModule;
      default = [ ];
      example = lib.literalExpression ''
        [
          {
            config.build = {
              isBinary = true;
            };
          }
        ]
      '';
      description = ''
        Extra modules to be added to all of the wrapper-manager configurations.
      '';
    };

    packages = lib.mkOption {
      type = lib.types.attrsOf wrapperManagerModule;
      description = ''
        A set of wrappers to be added into the environment configuration.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          custom-ricing = {
            wrappers.neofetch = {
              arg0 = lib.getExe' pkgs.neofetch "neofetch";
              appendArgs = [
                "--ascii-distro" "guix"
                "--config" ./config/neofetch/config
              ];
            };

            wrappers.fastfetch = {
              arg0 = lib.getExe' pkgs.fastfetch "fastfetch";
              appendArgs = [
                "--config" ./config/fastfetch/config
                "--logo" "Guix"
              ];
              env.NO_COLOR = 1;
            };
          };

          music-setup = {
            wrappers.yt-dlp-audio = {
              arg0 = lib.getExe' pkgs.yt-dlp "yt-dlp";
              prependArgs = [
                "--config-location" ./config/yt-dlp/audio.conf
              ];
            };

            wrappers.yt-dlp-video = {
              arg0 = lib.getExe' pkgs.yt-dlp "yt-dlp";
              prependArgs = [
                "--config-location" ./config/yt-dlp/video.conf
              ];
            };

            wrappers.beets-fds = {
              arg0 = lib.getExe' pkgs.beet "beet";
              prependArgs = [
                "--config" ./config/beets/config
              ];
            };
          };

          writing = {
            wrappers.asciidoctor-fds = {
              arg = lib.getExe' pkgs.asciidoctor-with-extensions "asciidoctor";
              executableName = "asciidoctor";
              prependArgs =
                builtins.map (v: "-r ''${v}") [
                  "asciidoctor-diagram"
                  "asciidoctor-bibtex"
                ];
            };
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
