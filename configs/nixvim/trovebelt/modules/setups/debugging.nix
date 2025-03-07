{ config, lib, ... }:

let
  nixvimCfg = config.nixvimConfigs.trovebelt;
  cfg = nixvimCfg.setups.debugging;
in {
  options.nixvimConfigs.trovebelt.setups.debugging.enable =
    lib.mkEnableOption "debugging setup";

  config = lib.mkIf cfg.enable {
    # The main star of the show.
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

    # Enable all of the debugging extensoins.
    plugins.dap-go.enable = true;
    plugins.dap-python.enable = true;
  };
}
