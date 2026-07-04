# Overlay aggregator - exports overlay sets for per-host selection
#
# This module provides named overlay sets for flexible per-host configuration.
# Each set can be selected in flake.nix via `nixpkgs.overlays = overlays.<set>`.
#
# Available sets:
#   - all:     Full set with NUR, gaming (xone), and custom packages
#   - minimal: Without gaming overlays - for non-gaming hosts or VMs
#   - gaming:  Gaming overlays only (xone Xbox controller support)
#
# Individual overlays can also be combined manually:
#   nixpkgs.overlays = [ overlays.nur overlays.customPackages ];
#
# Current overlays:
#   - nur: Nix User Repository packages
#   - xone: Xbox controller kernel module (nixpkgs-unstable v0.5.7)
#   - customPackages: Custom packages (bricolage-grotesque, qobuz-player, plymouthThemes)
{ inputs }:
let
  xone = import ./xone.nix { inherit inputs; };
  customPackages = import ./custom-packages.nix { inherit inputs; };
  nur = inputs.nur.overlays.default;
in
{
  inherit
    xone
    customPackages
    nur
    ;

  # Preset combinations for common use cases
  all = [
    nur
    xone
    customPackages
  ];

  # Without gaming overlays
  minimal = [
    nur
    customPackages
  ];

  # Gaming-only overlays
  gaming = [ xone ];
}
