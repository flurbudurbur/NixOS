# Rust toolchain with Dioxus development support
#
# Provides:
#   - Rust stable toolchain with cross-compilation targets
#   - rust-analyzer and rust-src for IDE support
#   - Dioxus CLI for building/serving apps
#   - GTK/WebKit dependencies for desktop builds
#   - cargo-ndk for Android builds
#
# Targets:
#   - wasm32-unknown-unknown: Web (WASM)
#   - aarch64-linux-android: Android ARM64
#   - armv7-linux-androideabi: Android ARM32
#   - x86_64-linux-android: Android emulator
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Rust toolchain with all targets
    (rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"
        "rust-analyzer"
      ];
      targets = [
        "wasm32-unknown-unknown" # Web
        "aarch64-linux-android" # Android ARM64
        "armv7-linux-androideabi" # Android ARM32
        "x86_64-linux-android" # Android emulator
      ];
    })

    # Dioxus CLI
    dioxus-cli

    # Build essentials
    pkg-config
    openssl

    # Desktop dependencies (GTK/WebKit)
    webkitgtk_4_1
    glib
    gtk3
    libsoup_3
    cairo
    pango
    gdk-pixbuf
    atk

    # Android build tools
    cargo-ndk
  ];
}
