{ lib, dotnet-runtime, dotnet-sdk, mkShell }:

mkShell {
  packages = [
    dotnet-runtime
    dotnet-sdk
  ];

  inputsFrom = [ dotnet-sdk ];
}
