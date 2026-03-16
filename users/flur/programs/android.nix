# Android SDK/NDK for Dioxus mobile development
#
# Provides:
#   - Android SDK with platform tools and build tools
#   - NDK for native compilation (required for Rust cross-compilation)
#   - Android emulator with system images
#   - adb and fastboot via android-tools
#
# Environment variables set:
#   - ANDROID_HOME / ANDROID_SDK_ROOT
#   - ANDROID_NDK_ROOT
#
# Note: First build downloads ~10GB of Android SDK components
{ pkgs, ... }:
let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    cmdLineToolsVersion = "8.0";
    platformToolsVersion = "35.0.1";
    buildToolsVersions = [ "34.0.0" ];
    platformVersions = [ "34" ];

    includeNDK = true;
    ndkVersions = [ "26.1.10909125" ];

    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis_playstore" ];
    abiVersions = [
      "arm64-v8a"
      "x86_64"
    ];

    cmakeVersions = [ "3.22.1" ];

    extraLicenses = [
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "android-sdk-license"
      "android-sdk-preview-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };

  androidSdk = androidComposition.androidsdk;
in
{
  home.packages = [
    androidSdk
    pkgs.android-tools # adb, fastboot
  ];

  home.sessionVariables = {
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    ANDROID_NDK_ROOT = "${androidSdk}/libexec/android-sdk/ndk-bundle";
  };
}
