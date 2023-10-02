final: prev:

{
  blender-foodogsquared = prev.blender-with-packages {
    name = "foodogsquared-wrapped";
    packages = with prev.python3Packages; [
      pandas
      scipy
      imageio
      pillow
    ];
  };
}
