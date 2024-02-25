{ config, lib }:

{
  isStandalone =
    !config?hmConfig && !config?nixosConfig && !config?darwinConfig;
}
