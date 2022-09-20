{ stdenv, lib, python3Packages, ... }:

python3Packages.buildPythonApplication rec {
  pname = "material-color-utilities-python";
  version = "0.1.5";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-PG8C585wWViFRHve83z3b9NijHyV+iGY2BdMJpyVH64=";
  };

  propagatedBuildInputs = with python3Packages; [
    pillow
    regex
  ];

  meta = with lib; {
    description = "Python port of material-color-utilities used for Material You colors";
  };
}
