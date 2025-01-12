{ pkgs, lib, self }:

{
  isStandalone = config:
    !config ? hmConfig && !config ? nixosConfig && !config ? darwinConfig;
}
