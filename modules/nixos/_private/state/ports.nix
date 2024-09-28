{ config, lib, ... }:

let
  cfg = config.state;

  supportedProtocols = [ "tcp" "udp" ];

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

  portModule = { lib, ... }: {
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

      openFirewall = lib.mkEnableOption "opening the ports to firewall";
    };
  };
in
{
  options.state =
    let
      portsModule = { lib, ... }: {
        options = {
          ports = lib.mkOption {
            type = with lib.types; attrsOf (submodule portModule);
            description = ''
              A set of ports indicating what goes where in the NixOS system.
            '';
            default = { };
            example = lib.literalExpression ''
              rec {
                gonic = {
                  value = 5757;
                  protocols = [ "tcp" ];
                  openFirewall = true;
                };
                uxplay = {
                  value = 7864;
                  openFirewall = true;
                };
                uxplayClients.value = {
                  from = uxplay.value + 1;
                  to = uxplay.value + 20;
                };
              }
            '';
          };
        };
      };
    in lib.mkOption {
      type = lib.types.submodule portsModule;
    };

  config = lib.mkIf (cfg.ports != { }) {
    networking.firewall =
      let
        allPortsToBeOpened = lib.filterAttrs (_: v: v.openFirewall) cfg.ports;
        hasProtocol = protocol: v: lib.elem protocol v.protocols;
        mkFirewallEntry = protocol: v:
          let
            inherit (v) value;
          in
          if lib.isAttrs value then {
            ${if protocol == "tcp"
              then "allowedTCPPortRanges"
              else "allowedUDPPortRanges"} = [ value ];
          } else {
            ${if protocol == "tcp"
              then "allowedTCPPorts"
              else "allowedUDPPorts"} = [ value ];
          };

        mkFirewallEntryModule = _: v:
          lib.optionalAttrs (hasProtocol "udp" v) (mkFirewallEntry "udp" v)
          // lib.optionalAttrs (hasProtocol "tcp" v) (mkFirewallEntry "tcp" v);
      in
      lib.mkMerge
        (lib.mapAttrsToList mkFirewallEntryModule allPortsToBeOpened);
  };
}
