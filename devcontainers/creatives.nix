{ dockerTools, foodogsquaredLib, puredata-with-plugins, processing, zexy, shader-slang, shaderc }:

foodogsquaredLib.buildDockerImage rec {
  name = "fds-creatives";
  tag = name;
  contents = [
    (puredata-with-plugins [ zexy ])
    shader-slang
    processing
    shaderc
  ];
}
