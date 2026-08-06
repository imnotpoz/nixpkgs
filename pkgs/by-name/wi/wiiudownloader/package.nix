{
  buildGoModule,
  fetchurl,
  fetchFromGitHub,
  gdk-pixbuf,
  glib,
  gtk3,
  lib,
  pkg-config,
  wrapGAppsHook3,
}:
let
  db = fetchurl {
    # TODO: versioning? web archive can't do it and IDK what else to do
    url = "https://napi.v10lator.de/db?t=go";
    hash = "sha256-Z1rW+fXDMe3O8mCuPfORKBGwJ/Z/ceWS8RrUeANqfkQ=";
    curlOptsList = [
      "-L"
      "-H"
      "User-Agent: NUSspliBuilder/2.1"
      # TODO: https://github.com/V10lator/NUSspli/issues/473
      "--insecure"
    ];
  };
in
buildGoModule (finalAttrs: {
  pname = "wiiudownloader";
  version = "2.102";

  src = fetchFromGitHub {
    owner = "Xpl0itU";
    repo = "WiiUDownloader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Y0Afg2+Xn3cPhm0aowOJ/nKTxFaCuDp4JE8TI7bU2o8=";
  };

  vendorHash = "sha256-OO8gS79J2T+vI0aKjHYoXN0gbn+Le35gw+DyzIHibQ8=";

  __structuredAttrs = true;
  strictDeps = true;

  # https://github.com/Xpl0itU/WiiUDownloader/blob/main/.github/workflows/linux.yml
  patchPhase = ''
    runHook prePatch

    cp ${db} db.go
    chmod u+w db.go

    if grep -q 'var titleEntry =' db.go; then
      if grep -q 'type TitleEntry struct' db.go; then
        sed -i '/type TitleEntry struct/,/}/d' db.go
      fi
      sed -i 's/var titleEntry =/funct init() { TitleDatabase =/' db.go
      echo '}' >> db.go
    fi

    runHook postPatch
  '';

  modRoot = "cmd/WiiUDownloader";

  buildInputs = [
    gdk-pixbuf
    glib
    gtk3
  ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  postInstall = ''
    ln -s ./WiiUDownloader $out/bin/wiiudownloader
  '';

  meta = {
    description = "Downloader for encrypted WiiU files from Nintendo's official servers";
    homepage = "https://github.com/Xpl0itU/WiiUDownloader";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ poz ];
    mainProgram = "WiiUDownloader";
  };
})
