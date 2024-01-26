{ lib, ... }: {
  options = {
    fastConnection =
      lib.mkEnableOption "deploy-rs to assume the target machine is considered fast";
    autoRollback =
      lib.mkEnableOption "deploy-rs auto-rollback feature" // {
        default = true;
      };
    magicRollback =
      lib.mkEnableOption "deploy-rs magic rollback feature" // {
        default = true;
      };
    remoteBuild = lib.mkEnableOption "pass the build process to the remote machine";
  };
}
