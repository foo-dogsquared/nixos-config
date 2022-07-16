{ stdenv, lib, fetchFromGitHub, python310Packages }:

python310Packages.buildPythonApplication rec {
  pname = "auto-editor";
  version = "22w25a";
  doCheck = false;

  src = fetchFromGitHub {
    owner = "WyattBlue";
    repo = pname;
    rev = version;
    sha256 = "sha256-SKlAgGqowFvvenhbFiTWbVLYAB5CChQ+EdPXxsWxNgE=";
  };

  propagatedBuildInputs = with python310Packages; [ numpy yt-dlp av pillow ];

  meta = with lib; {
    description =
      "Command-line application for automating video and audio editing with a variety of methods";
    homepage = "https://auto-editor.com/cli";
    license = licenses.unlicense;
  };
}
