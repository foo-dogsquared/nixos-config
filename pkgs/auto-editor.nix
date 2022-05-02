{ stdenv, lib, fetchFromGitHub, python310Packages }:

let
  av = python310Packages.av.overrideAttrs (super: rec {
    version = "9.2.0";
    src = python310Packages.fetchPypi {
      inherit version;
      pname = super.pname;
      sha256 = "sha256-8qfCJnJNf3dFs3a0WcUA2dF72NBHO36mv43bT3lXxp0=";
    };
    buildInputs = super.buildInputs ++ [ python310Packages.cython ];
    pytestFlagsArray = super.pytestFlagsArray ++ [
      "--deselect=tests/test_python_io.py::TestPythonIO::test_writing_to_custom_io_dash"
      "--deselect=tests/test_python_io.py::TestPythonIO::test_writing_to_custom_io_image2"
    ];
  });
in python310Packages.buildPythonApplication rec {
  pname = "auto-editor";
  version = "22w17a";
  doCheck = false;

  src = fetchFromGitHub {
    owner = "WyattBlue";
    repo = pname;
    rev = version;
    sha256 = "sha256-zXKmmJk7QDeHFJemhabTNhcMfP+FdOvfqEkh7+Hs2z8=";
  };

  propagatedBuildInputs = with python310Packages;
    [ numpy yt-dlp pillow ] ++ [ av ];

  meta = with lib; {
    description =
      "Command-line application for automating video and audio editing with a variety of methods";
    homepage = "https://auto-editor.com/cli";
    license = licenses.unlicense;
  };
}
