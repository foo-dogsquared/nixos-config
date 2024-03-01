{ pkgs, lib }:

{
  isStandalone = config:
    !config?hmConfig && !config?nixosConfig && !config?darwinConfig;
}
