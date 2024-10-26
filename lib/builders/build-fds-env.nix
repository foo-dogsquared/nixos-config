{ buildEnv, extendedStdenv }:

{ paths ? [ ], pathsToLink ? [ ], }@args:

buildEnv (args // {
  paths = paths ++ [ extendedStdenv ];
  pathsToLink = pathsToLink ++ [ "/bin" "/etc" "/share" "/lib" ];
})
