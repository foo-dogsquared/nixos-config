{ stdenv, lib, python3Packages, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "attrs_strict";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-YybB5RxP0v/8ndYH3sBsMa3WTu29N6ZR6oj2Y6N8Pxg";
  };

  propagatedBuildInputs = [ setuptools-scm attrs ];

  meta = with lib; {
    homepage = "https://github.com/bloomberg/attrs-strict";
    description = "Runtime validators for attrs";
    license = licenses.asl20;
  };
}
