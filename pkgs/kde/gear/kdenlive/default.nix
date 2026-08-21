{
  mkKdeDerivation,
  replaceVars,
  mlt,
  glaxnimate,
  ffmpeg-full,
  ffmpegthumbs,
  pkg-config,
  shared-mime-info,
  qtsvg,
  qtmultimedia,
  qtnetworkauth,
  kddockwidgets,
  qqc2-desktop-style,
  v4l-utils,
  kio-extras,
  opentimelineio,
  frei0r,
  qtimageformats,
}:
mkKdeDerivation {
  pname = "kdenlive";

  patches = [
    (replaceVars ./dependency-paths.patch {
      inherit mlt glaxnimate;
      ffmpeg = ffmpeg-full;
    })
    ./no-qmllint.patch
  ];

  extraCmakeFlags = [
    "-DFETCH_OTIO=0"
  ];

  extraNativeBuildInputs = [
    pkg-config
    shared-mime-info
  ];

  extraBuildInputs = [
    qtsvg
    qtmultimedia
    qtnetworkauth
    qtimageformats # UI uses webp images

    kddockwidgets
    qqc2-desktop-style
    kio-extras

    ffmpeg-full
    ffmpegthumbs
    v4l-utils.lib
    mlt
    opentimelineio
  ];

  qtWrapperArgs = [
    "--set FREI0R_PATH ${frei0r}/lib/frei0r-1"
  ];

  meta.mainProgram = "kdenlive";
}
