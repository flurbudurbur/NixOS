# Use nixpkgs-unstable's xone built against the current system kernel
# Uses linuxKernel.packagesFor override to apply to ALL kernel package sets
{ inputs }:
_final: prev:
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
        _lpFinal: _lpPrev: {
          inherit ((unstablePkgs.linuxKernel.packagesFor kernel)) xone;
        }
      );
  };
}
