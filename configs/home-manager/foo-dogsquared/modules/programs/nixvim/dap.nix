{ config, lib, pkgs, ... }:

let
  nixvimCfgs = config.nixvimConfigs.fiesta-fds;
  cfg = nixvimCfgs.setups.dap;
in
{
  options.nixvimConfigs.fiesta-fds.setups.dap.enable =
    lib.mkEnableOption "DAP integration within NixVim";

  config = lib.mkIf cfg.enable {
    # Enable the main star of the show.
    plugins.dap.enable = true;

    # All of the configurations that we typically/rarely needed.
    plugins.dap.adapters.executables = {
      gdb = {
        command = "gdb";
        args = [ "-i" "dap" ];
      };

      lldb = { command = "lldb-dap"; };

      dart = {
        command = "dart";
        args = [ "debug_adapter" ];
      };

      flutter = {
        command = "flutter";
        args = [ "debug_adapter" ];
      };
    };

    # Enable a bunch of pre-configured configurations.
    plugins.dap-go.enable = true;
    plugins.dap-python.enable = true;
    plugins.rustaceanvim.enable = false;
  };
}
