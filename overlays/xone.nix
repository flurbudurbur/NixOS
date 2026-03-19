# Use nixpkgs-unstable's xone (v0.5.7) built against the current system kernel
# Uses linuxKernel.packagesFor override to apply to ALL kernel package sets
{ inputs }:
final: prev:
let
  unstablePkgs = import inputs.nixpkgs-unstable {
    system = prev.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  linuxKernel = prev.linuxKernel // {
    packagesFor =
      kernel:
      (prev.linuxKernel.packagesFor kernel).extend (
        lpFinal: lpPrev: {
          xone = (unstablePkgs.linuxKernel.packagesFor kernel).xone;
        }
      );
  };
}
