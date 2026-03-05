# Overlay aggregator - exports overlay sets for per-host selection
{ inputs }:
let
  xone = import ./xone.nix;
  customPackages = import ./custom-packages.nix;
  nur = inputs.nur.overlays.default;
in
{
  inherit xone customPackages nur;

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
