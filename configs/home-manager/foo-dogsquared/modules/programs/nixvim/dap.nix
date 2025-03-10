{ config, lib, pkgs, ... }:

{
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
}
