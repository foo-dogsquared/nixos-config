# https://defold.com/open/
# It'sa game engine for cross-platform development.
{ stdenv, fetchFromGitHub,
autoconf,
automake,
cmake,
curl,
freeglut,
git,
jdk11,
libtool,
libuuid,
mesa_glu,
openalSoft,
python2,
rpm,
valgrind,
waf,
xorgproto,
libXi,
libXext,
}:

stdenv.mkDerivation rec {
  pname = "defold";
  version = "1.2.171";

  src = fetchFromGitHub {
    owner = "defold";
    repo = "defold";
    rev = "v1.2.171";
    sha256 = "1anpwxgai1qk6c97zslfvj5b6s66fyk459cfnxnqm7d8sq9d0qg2";
  };

  buildPhase = ''
    ./scripts/build.py shell --platform=${stdenv.system}
    ./scripts/build.py install_ext --platform=${stdenv.system}
    ./scripts/build.py build_engine --platform=${stdenv.system}
  '';

  enableParallelBuilding = true;
  doCheck = true;

  meta = with stdenv.lib; {
    description = "A free and open-source game engine for cross-platform development.";
    homepage = "https://defold.com/";
    license = licenses.free;
    maintainers = [ maintainers.foo-dogsquared ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
