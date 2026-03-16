# Overlay aggregator - exports overlay sets for per-host selection
#
# This module provides named overlay sets for flexible per-host configuration.
# Each set can be selected in flake.nix via `nixpkgs.overlays = overlays.<set>`.
#
# Available sets:
#   - all:     Full set with NUR, gaming (xone), rust-overlay, and custom packages
#   - minimal: Without gaming overlays - for non-gaming hosts or VMs
#   - gaming:  Gaming overlays only (xone Xbox controller support)
#
# Individual overlays can also be combined manually:
#   nixpkgs.overlays = [ overlays.nur overlays.customPackages ];
#
# Current overlays:
#   - nur: Nix User Repository packages
#   - xone: Xbox controller kernel module (dlundqvist fork v0.5.7)
#   - rustOverlay: Rust toolchain overlay (rust-bin.stable, nightly, etc.)
#   - customPackages: Custom packages (bricolage-grotesque, qobuz-player)
{ inputs }:
let
  xone = import ./xone.nix;
  customPackages = import ./custom-packages.nix;
  nur = inputs.nur.overlays.default;
  rustOverlay = inputs.rust-overlay.overlays.default;
in
{
  inherit
    xone
    customPackages
    nur
    rustOverlay
    ;

  # Preset combinations for common use cases
  all = [
    nur
    xone
    rustOverlay
    customPackages
  ];

  # Without gaming overlays
  minimal = [
    nur
    rustOverlay
    customPackages
  ];

  # Gaming-only overlays
  gaming = [ xone ];
}
