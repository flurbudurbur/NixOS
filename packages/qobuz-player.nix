{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  protobuf,
  alsa-lib,
  sqlite,
  dbus,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "qobuz-player";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "SofusA";
    repo = "qobuz-player";
    rev = "v0.7.1";
    hash = "sha256-LStCoBr3BblXRpuno+QKxyJstvrNmP+wub61491NkPY=";
  };

  cargoHash = "sha256-6fUwZkXurjV9yM2Mur0lAkgFxTAEmt92DFKzbPj3Vo4=";

  cargoBuildFlags = [
    "--package"
    "qobuz-player"
  ];
  cargoTestFlags = [
    "--package"
    "qobuz-player"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 target/x86_64-unknown-linux-gnu/release/qobuz-player $out/bin/qobuz-player
    runHook postInstall
  '';

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [
    alsa-lib # audio via rodio → cpal → alsa
    sqlite # sqlx sqlite backend
    dbus # MPRIS integration
    openssl # reqwest HTTP client
  ];

  meta = with lib; {
    description = "TUI music player for Qobuz";
    homepage = "https://github.com/SofusA/qobuz-player";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
