# A bunch of custom overlays. This is more suitable for larger and more
# established packages that needed extensive customization. Take note each of
# the values in the attribute set is a separate overlay function so you'll
# simply have to append them as a list (i.e., `lib.attrValues`).
{
  ffmpeg-foodogsquared = import ./ffmpeg-foodogsquared;
  firefox-foodogsquared = import ./firefox-foodogsquared;
  blender-foodogsquared = import ./blender-foodogsquared;
}
