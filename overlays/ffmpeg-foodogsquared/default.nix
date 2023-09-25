final: prev:

let
  ffmpegGLTransitions = prev.fetchFromGitHub {
    owner = "transitive-bullshit";
    repo = "ffmpeg-gl-transition";
    rev = "3639b521aafb30b185de281f94560f298a22d420";
    hash = "";
  };

  ffmpegShadertoyFilter = prev.fetchFromGitLab {
    owner = "kriwkrow";
    repo = "ffmpeg_shadertoy_filter";
    rev = "eb297df10a104cae2d4ef3f70188d1e84f104532";
    hash = "";
  };
in
{
  ffmpeg-foodogsquared = prev.ffmpeg-full.overrideAttrs (finalAttrs: prevAttrs: {
    pname = "ffmpeg-foodogsquared";
    patches = prevAttrs.patches ++ [
      ./add-custom-filters.patch
    ];
    postPatch = prevAttrs.postPatch + ''
      cp ${ffmpegGLTransitions}/vf_gltransition.c $src/libavfilter
      cp ${ffmpegShadertoyFilter}/vf_shadertoy.c $src/libavfilter
    '';
  });
}
