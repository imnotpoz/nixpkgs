{
  fetchFromGitHub,
  lib,
  stdenv,
}: let
  # TODO: wait for new tag to hit so that we get aarch64-linux support
  version = "2025.3";
in stdenv.mkDerivation {
  pname = "smlnj-unstable";
  inherit version;

  src = fetchFromGitHub {
    owner = "smlnj";
    repo = "smlnj";
    fetchSubmodules = true;
    tag = "v${version}";
    hash = "";
  };

  buildPhase = ''
    runHook preBuild

    ./build.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -pv $out
    cp -rv bin $out

    runHook postInstall
  '';

  meta = {
    description = "Standard ML of New Jersey";
    homepage = "http://smlnj.org";
    license = lib.licenses.bsd3;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with lib.maintainers; [ poz ];
    mainProgram = "sml";
  };
}
