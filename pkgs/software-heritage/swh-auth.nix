{ stdenv, lib, python3Packages, swh-core, ... }:

with python3Packages;

buildPythonPackage rec {
  pname = "swh-auth";
  version = "0.7.1";

  src = fetchPypi {
    inherit version;
    pname = "swh.auth";
    sha256 = "sha256-tmHyDSUDIWLNRTgPquyYaeIg2wZdYMJWpK9Gy8h1B6k=";
  };

  # Tests require network access.
  doCheck = false;

  propagatedBuildInputs = [
    django
    djangorestframework
    sentry-sdk
    click
    pyyaml
    (python-keycloak.overrideAttrs (final: prev: rec {
      version = "2.16.1";
      src = pkgs.fetchPypi {
        inherit version;
        pname = "python_keycloak";
        hash = "sha256-LyJwC274wWcoSoLCNzb2/ryQW9CrhZgdyhIXGt82Z68=";
      };
      propagatedBuildInputs = prev.propagatedBuildInputs ++ [ setuptools deprecation ];
    }))

    swh-core
  ];

  meta = with lib; {
    homepage = "https://forge.softwareheritage.org/source/swh-auth/";
    description = "Authentication utilities for Software Heritage";
    license = licenses.gpl3Only;
  };
}
