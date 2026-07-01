{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation {
  pname = "autour-one";
  version = "unstable";

  src = fetchurl {
    url = "https://github.com/google/fonts/raw/main/ofl/autourone/AutourOne-Regular.ttf";
    hash = "sha256-aj9b8n6TmMJb2MTtrui9UD2AdFU1N6K/Ox1yQ1OqslI=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/fonts/truetype/AutourOne-Regular.ttf

    runHook postInstall
  '';

  meta = with lib; {
    description = "Single-weight display font inspired by handwritten Ludwig Hohlwein poster lettering";
    homepage = "https://fonts.google.com/specimen/Autour+One";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
