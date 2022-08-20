{ stdenv, lib, python3Packages, ... }:

python3Packages.buildPythonApplication rec {
  pname = "material-color-utilities-python";
  version = "0.1.3";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-3AWZICW0Cr/hCjjBpW/ZCyASG+sRR9eK3mwEa1JeZRY=";
  };

  propagatedBuildInputs = with python3Packages; [
    pillow
    regex
  ];

  meta = with lib; {
    description = "Python port of material-color-utilities used for Material You colors";
  };
}
