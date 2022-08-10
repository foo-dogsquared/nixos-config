{ stdenv, lib, python3Packages, ... }:

with python3Packages;
buildPythonPackage rec {
  pname = "aiohttp-utils";
  version = "3.1.1";

  src = fetchPypi {
    inherit version;
    pname = "aiohttp_utils";
    sha256 = "sha256-CPLE3BWj/Rk6qQSiH0/zZfW64LE6Z2Tz59BaO7gC3BQ";
  };

  doCheck = false;

  propagatedBuildInputs = [
    aiohttp
    gunicorn
    python-mimeparse
  ];

  meta = with lib; {
    homepage = "https://github.com/sloria/aiohttp-utils";
    description = "Provides utilities for building aiohttp applications";
    license = licenses.mit;
  };
}
