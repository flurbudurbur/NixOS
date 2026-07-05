{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gcc-unwrapped,
}:

stdenv.mkDerivation rec {
  pname = "fluxer-tui";
  version = "0.7.5";

  src = fetchurl {
    url = "https://github.com/dogbonewish/fluxer-tui/releases/download/v${version}/fluxer-tui-v${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-PXLyBwjkOvsTLg31oWObCYMkiMY7hEv/30phMMnezB0=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ gcc-unwrapped.lib ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 fluxer-tui $out/bin/fluxer-tui
    runHook postInstall
  '';

  meta = {
    description = "TUI chat client for the Fluxer messaging platform";
    homepage = "https://github.com/dogbonewish/fluxer-tui";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "fluxer-tui";
  };
}
