{ stdenv, lib, ffmpeg, fetchFromGitHub, python310Packages }:

python310Packages.buildPythonApplication rec {
  pname = "auto-editor";
  version = "22w35c";
  doCheck = false;

  src = fetchFromGitHub {
    owner = "WyattBlue";
    repo = pname;
    rev = version;
    sha256 = "sha256-Vgia61kswKJhqd906Y3x+ddxvM1BZDdKdG9VBiUaafg=";
  };

  postPatch = ''
    sed ./setup.py -i -E \
      -e "/ae-ffmpeg/d"
  '';

  propagatedBuildInputs = with python310Packages; [ numpy yt-dlp av pillow ];
  runtimeDependencies = [ ffmpeg ];

  meta = with lib; {
    description =
      "Command-line application for automating video and audio editing with a variety of methods";
    homepage = "https://auto-editor.com/cli";
    license = licenses.unlicense;
  };
}
