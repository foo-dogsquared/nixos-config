{ stdenv, lib, python3Packages, swh-core, ... }:

with python3Packages;

buildPythonPackage rec {
  pname = "swh-auth";
  version = "0.7.2";

  src = fetchPypi {
    inherit version;
    pname = "swh.auth";
    sha256 = "sha256-f0++AuyJggoc19kPA/7UChbFjF/EoR+FztF00r5csLo=";
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
      version = "3.3.0";
      src = pkgs.fetchPypi {
        inherit version;
        pname = "python_keycloak";
        hash = "sha256-zIaBJvU1qk8yDcnqsk5GrzgcE7zIjZsHAbBCk+p1zSQ=";
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
