{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "bricolage-grotesque";
  version = "2024-12-19";

  src = pkgs.fetchFromGitHub {
    owner = "flurbudurbur";
    repo = "bricolage";
    rev = "main";
    hash = "sha256-K79ojosZqVg3S9cfBzI3d7ny+90cLCJq7W4XNotsP14=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 fonts/variable/*.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "An expressive variable font with weight, width and optical size axis";
    homepage = "https://github.com/flurbudurbur/bricolage";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
