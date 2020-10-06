{ stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
  name = "veikk-linux-driver";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "jlam55555";
    repo = "veikk-linux-driver";
    rev = "v2.0";
    sha256 = "11mg74ds58jwvdmi3i7c4chxs6v9g09r9ll22pc2kbxjdnrp8zrn";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  patchPhase = ''
    sed -i Makefile -e 's/modprobe veikk//' -e 's/depmod//'
  '';

  INSTALL_MOD_PATH = "\${out}";

  makeFlags = [
    "BUILD_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  meta = with stdenv.lib; {
    description = "Linux device driver for supported VEIKK tablets (e.g., S640, A50, A30).";
    homepage = "https://github.com/jlam55555/veikk-linux-driver";
    licenses = licenses.free;
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = platforms.linux;
  };
}
