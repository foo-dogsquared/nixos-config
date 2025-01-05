{ dockerTools, ruby, bundix, foodogsquaredLib }:

let name = s: "fds-ruby-on-rails-${ruby.version}${s}";
in dockerTools.buildImage {
  name = name "";

  copyToRoot = foodogsquaredLib.buildFDSEnv {
    name = name "root";
    paths = [ ruby bundix ];
  };

  runAsRoot = ''
    mkdir -p /data
  '';

  config = {
    Cmd = [ "/bin/bash" ];
    WorkingDir = "/data";
    Volumes."/data" = { };
  };
}
