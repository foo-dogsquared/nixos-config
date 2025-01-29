# A deploy-rs submodule to be shared among other deploy-rs-related options in
# different environments. Take note this is supposed to be imported inside of a
# deploy-rs-related option, not in the top-level `configs` option.
{ lib, ... }: {
  options = {
    fastConnection = lib.mkEnableOption
      "deploy-rs to assume the target machine is considered fast";
    autoRollback = lib.mkEnableOption "deploy-rs auto-rollback feature" // {
      default = true;
    };
    magicRollback = lib.mkEnableOption "deploy-rs magic rollback feature" // {
      default = true;
    };
    remoteBuild =
      lib.mkEnableOption "pass the build process to the remote machine";
  };
}
