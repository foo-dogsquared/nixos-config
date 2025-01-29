{ lib, ... }:

let supportedProtocols = [ "tcp" "udp" ];
in {
  options.state = let
    portRangeType = {
      options = {
        from = lib.mkOption {
          type = lib.types.port;
          description = ''
            The start of the range of TCP/UDP ports to be taken over.
          '';
        };

        to = lib.mkOption {
          type = lib.types.port;
          description = ''
            The end of the range of TCP/UDP ports to be taken over.
          '';
        };
      };
    };

    portValueModule = { lib, ... }: {
      options = {
        protocols = lib.mkOption {
          type = with lib.types; listOf (enum supportedProtocols);
          description = ''
            Indicates the type of protocol of the service.
          '';
          default = [ "tcp" "udp" ];
          example = [ "tcp" ];
        };

        value = lib.mkOption {
          type = with lib.types; either port (submodule portRangeType);
          description = ''
            The port number itself.
          '';
        };
      };
    };

    portsSubmodule = { lib, ... }: {
      options = {
        ports = lib.mkOption {
          type = with lib.types; attrsOf (submodule portValueModule);
          default = { };
          example = lib.literalExpression ''
            {
              gonic.value = 4629;
              mopidy.value = 6034;
            }
          '';
        };
      };
    };
  in lib.mkOption { type = lib.types.submodule portsSubmodule; };
}
