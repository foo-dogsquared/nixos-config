{ stdenv, lib, fetchFromGitHub, python310Packages }:

let
  pillow = python310Packages.pillow.overrideAttrs (super: rec {
    version = "9.0.1";
    src = python310Packages.fetchPypi {
      inherit version;
      pname = super.pname;
      sha256 = "sha256-bIvII4p9/a96dfXsWmY/QXP4w2flo5+H5yBJXh7tdfo=";
    };
  });

  av = python310Packages.av.overrideAttrs (super: rec {
    version = "9.0.1";
    src = python310Packages.fetchPypi {
      inherit version;
      pname = super.pname;
      sha256 = "sha256-IBbGImSg0Ars6w9Ati35+el2Bnyl86m9v1Mv5exTQZ8=";
    };
    buildInputs = super.buildInputs ++ [ python310Packages.cython ];
  });
in
python310Packages.buildPythonApplication rec {
  pname = "auto-editor";
  version = "22w12a";
  doCheck = false;

  src = fetchFromGitHub {
    owner = "WyattBlue";
    repo = pname;
    rev = version;
    sha256 = "sha256-mtVL/X6mh+0Paa6yuth9DGbqewsSBopV5/VXoC0DN4M=";
  };

  propagatedBuildInputs = with python310Packages; [
    numpy
    yt-dlp
  ] ++ [ av pillow ];

  meta = with lib; {
    description = "Command-line application for automating video and audio editing with a variety of methods";
    homepage = "https://auto-editor.com/cli";
    license = licenses.unlicense;
  };
}
