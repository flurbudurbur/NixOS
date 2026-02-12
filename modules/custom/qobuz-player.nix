{ pkgs, lib ? pkgs.lib }:

pkgs.rustPlatform.buildRustPackage {
  pname = "qobuz-player-tui";
  version = "0.7.1";

  src = pkgs.fetchFromGitHub {
    owner = "SofusA";
    repo = "qobuz-player";
    rev = "v0.7.1";
    hash = "sha256-LStCoBr3BblXRpuno+QKxyJstvrNmP+wub61491NkPY=";
  };

  cargoHash = "sha256-6fUwZkXurjV9yM2Mur0lAkgFxTAEmt92DFKzbPj3Vo4=";

  cargoBuildFlags = [ "--package" "qobuz-player-tui" ];
  cargoTestFlags = [ "--package" "qobuz-player-tui" ];

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  buildInputs = [
    pkgs.alsa-lib  # audio via rodio → cpal → alsa
    pkgs.sqlite    # sqlx sqlite backend
    pkgs.dbus      # MPRIS integration
    pkgs.openssl   # reqwest HTTP client
  ];

  meta = with lib; {
    description = "TUI music player for Qobuz";
    homepage = "https://github.com/SofusA/qobuz-player";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
