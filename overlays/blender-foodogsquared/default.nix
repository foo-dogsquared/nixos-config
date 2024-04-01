final: prev:

{
  blender-foodogsquared = prev.blender.withPackages (p:
    with p; [
      pandas
      scipy
      pillow
    ]);
}
