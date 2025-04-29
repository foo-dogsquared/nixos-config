# This is simply to make using my flake modules a bit easier for my private
# configurations.
{ inputs, ... }:

{
  flake.flakeModules = {
    inherit (inputs.fds-core.flakeModules) default baseSetupConfig;
  };
}
