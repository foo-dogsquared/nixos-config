{ buildEnv, extendedStdenv }:

{ paths ? [ ], pathsToLink ? [ ], ... }@args:

buildEnv (args // {
  paths = extendedStdenv ++ paths;
  pathsToLink = [ "/bin" "/etc" "/share" "/lib" "/libexec" ] ++ pathsToLink;
})
