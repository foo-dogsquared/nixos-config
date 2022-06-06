{ stdenv, lib, fetchFromGitHub, python310Packages }:

python310Packages.buildPythonApplication rec {
  pname = "auto-editor";
  version = "22w22a";
  doCheck = false;

  src = fetchFromGitHub {
    owner = "WyattBlue";
    repo = pname;
    rev = version;
    sha256 = "sha256-SSdiBLyijed4bRqI4Y4vJ4HetNTGQgDMnXmbLRNspL0=";
  };

  postPatch = ''
    substituteInPlace ./setup.py --replace "pillow==9.1.1" "pillow==9.1.0"
  '';

  propagatedBuildInputs = with python310Packages;
    [ numpy yt-dlp av pillow ];

  meta = with lib; {
    description =
      "Command-line application for automating video and audio editing with a variety of methods";
    homepage = "https://auto-editor.com/cli";
    license = licenses.unlicense;
  };
}
