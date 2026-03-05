# Override xone to use dlundqvist fork v0.5.7 for extra button support
# Uses linuxKernel.packagesFor override to apply to ALL kernel package sets
final: prev: {
  linuxKernel = prev.linuxKernel // {
    packagesFor =
      kernel:
      (prev.linuxKernel.packagesFor kernel).extend (
        lpFinal: lpPrev: {
          xone = lpPrev.xone.overrideAttrs (old: {
            version = "0.5.7";
            src = prev.fetchFromGitHub {
              owner = "dlundqvist";
              repo = "xone";
              rev = "v0.5.7";
              hash = "sha256-9bflLH4lPGM7Ziv6w0+HC56jMU0IchL/9udbIqTIMd8=";
            };
          });
        }
      );
  };
}
