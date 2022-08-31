{ stdenv, lib, ffmpeg, fetchFromGitHub, python310Packages }:

python310Packages.buildPythonApplication rec {
  pname = "auto-editor";
  version = "22w32a";
  doCheck = false;

  src = fetchFromGitHub {
    owner = "WyattBlue";
    repo = pname;
    rev = version;
    sha256 = "sha256-VbEr3/8PmV9mShoyv2hsc0rX8RUM39lgVk5HGe5DKYY=";
  };

  postPatch = ''
    sed ./setup.py -i -E \
      -e "/ae-ffmpeg==1.0.0/d"
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
