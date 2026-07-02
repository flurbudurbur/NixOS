{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation {
  pname = "nova-mono";
  version = "unstable";

  src = fetchurl {
    url = "https://github.com/google/fonts/raw/main/ofl/novamono/NovaMono.ttf";
    hash = "sha256-ZI6ttmSMCAGxhtPc72DuaqhKeRseCccmk1wHElCLSAc=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/fonts/truetype/NovaMono-Regular.ttf

    runHook postInstall
  '';

  meta = with lib; {
    description = "Monospace font with a distinctive stenciled look";
    homepage = "https://fonts.google.com/specimen/Nova+Mono";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
