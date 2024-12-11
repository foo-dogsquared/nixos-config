# A private-use reverse proxy for certain system services.
{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.reverse-proxy;
in
{
  options.hosts.ni.services.reverse-proxy.enable =
    lib.mkEnableOption "private-use reverse proxy setup";

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
    };
  };
}
