# Trying to be creative with coding while endlessly referring to some tutorials
# on the internet.
{ mkShell
, supercollider
, bonzomatic
, processing
, puredata
, shaderc
}:

mkShell {
  packages = [
    supercollider # It's a super tool for music who compensates the lack of musical talent for coding instead.
    bonzomatic # Shadertoy for desktop bozos.
    processing # All aboard the creative coding train.
    puredata # Pure unadulterated data: all of them.
    shaderc # Tools to be a shady person.
  ];
}
