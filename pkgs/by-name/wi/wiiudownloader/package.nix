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
    hash = "sha256-CoM4HcnPRzM8Dx8DJRKSR5cEYcErm0P+XLZv5xQhnGc=";
    curlOptsList = [
      "-L"
      "-H"
      "User-Agent: NUSspliBuilder/2.1"
    ];
  };
in
buildGoModule (finalAttrs: {
  pname = "wiiudownloader";
  version = "2.104";

  src = fetchFromGitHub {
    owner = "Xpl0itU";
    repo = "WiiUDownloader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ce2l9+5HKvPlNSTHM3QzJQLLbL4NPDyYrVqJCzBna+0=";
  };

  vendorHash = "sha256-arYx1HsKiUqxHwSZ4KNnQFIROusT/PCfSjinDMryFjA=";

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
