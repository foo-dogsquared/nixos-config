final: prev:

let
  ffmpegGLTransitions = prev.fetchFromGitHub {
    owner = "transitive-bullshit";
    repo = "ffmpeg-gl-transition";
    rev = "3639b521aafb30b185de281f94560f298a22d420";
    hash = "sha256-py6NVXw3giiRAcVRzsgxU8aKJZInWrubIUT2vOhfuco=";
    name = "ffmpeg-gltransition";
  };

  ffmpegShadertoy = prev.fetchFromGitLab {
    owner = "kriwkrow";
    repo = "ffmpeg_shadertoy_filter";
    rev = "eb297df10a104cae2d4ef3f70188d1e84f104532";
    hash = "sha256-Qy5sZgNF/0uNCosj2NZEvyssXU9ln6ZsDjnt/orpt1k=";
    name = "ffmpeg-shadertoy";
  };
in {
  ffmpeg-foodogsquared = prev.ffmpeg-full.overrideAttrs
    (finalAttrs: prevAttrs: {
      pname = "ffmpeg-foodogsquared";
      srcs = [ prevAttrs.src ffmpegGLTransitions ffmpegShadertoy ];
      buildInputs = prevAttrs.buildInputs ++ (with prev; [ libGLU glew ]);
      sourceRoot = ".";
      patches = prevAttrs.patches ++ [
        ./add-custom-filters.patch
        ./update-ffmpeg-opengltransition.patch
      ];
      postUnpack = ''
        cd ./${ffmpegGLTransitions.name}
        cd ../

        cp --no-preserve=mode ./${ffmpegGLTransitions.name}/vf_gltransition.c ./ffmpeg/libavfilter
        cp --no-preserve=mode ./${ffmpegShadertoy.name}/vf_shadertoy.c ./ffmpeg/libavfilter

        cd ffmpeg
      '';
    });
}
