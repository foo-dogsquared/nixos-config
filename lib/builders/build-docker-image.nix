{ dockerTools, foodogsquaredLib }:

{ name, contents ? [ ], pathsToLink ? [ ], enableTypicalSetup ? true, ... }@attrs:

dockerTools.buildImage (attrs // {
  name = "fds-${name}";

  copyToRoot = foodogsquaredLib.buildFDSEnv {
    inherit pathsToLink;
    name = "fds-${name}-root";
    paths =
      contents
      ++ lib.optionals enableTypicalSetup (with dockerTools; [
        usrBinEnv
        binSh
        caCertificates
        fakeNss
      ]);
  };

  runAsRoot = ''
    ${lib.optionalString enableTypicalSetup ''
      mkdir -p /data
    ''}
    ${attrs.runAsRoot}
  '';

  config = attrs.config // lib.optionalAttrs enableTypicalSetup {
    Cmd = [ "/bin/bash" ];
    WorkingDir = "/data";
    Volumes."/data" = { };
  };
})
